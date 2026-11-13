@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/trade_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';
import 'package:stocknote/data/sync/cloud_sync.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/trade/trade_rules.dart';

/// 端到端：启动本地同步服务器（server/.venv），两台"设备"通过它同步。
void main() {
  final python = File('server/.venv/Scripts/python.exe').existsSync()
      ? 'server/.venv/Scripts/python.exe'
      : 'server/.venv/bin/python';
  final hasServer = File(python).existsSync();
  late Process server;
  late String url;
  late Directory tmp;

  setUpAll(() async {
    if (!hasServer) return;
    tmp = await Directory.systemTemp.createTemp('sn_sync');
    final port = 18000 + DateTime.now().millisecond;
    url = 'http://127.0.0.1:$port';
    server = await Process.start(
      File(python).absolute.path,
      ['-m', 'uvicorn', 'app.main:create_app', '--factory', '--port', '$port', '--log-level', 'warning'],
      workingDirectory: 'server',
      environment: {'STOCKNOTE_DB': '${tmp.path}/t.db', 'STOCKNOTE_JWT_SECRET': 'k' * 40},
    );
    server.stderr.transform(utf8.decoder).listen((l) => stderr.write(l));
    for (var i = 0; i < 50; i++) {
      try {
        await Dio().get('$url/api/health');
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
    fail('同步服务器未启动');
  });

  tearDownAll(() async {
    if (!hasServer) return;
    server.kill();
    await server.exitCode;
  });

  CloudSync device(AppDatabase db) {
    final s = CloudSync(db: db, settings: SettingsStore(db), secrets: MemorySecretStore());
    return s;
  }

  test('两台设备通过服务器同步：新增、修改、删除与冲突', () async {
    final cal = TradingCalendar();
    final dbA = AppDatabase(NativeDatabase.memory());
    final dbB = AppDatabase(NativeDatabase.memory());
    final a = device(dbA), b = device(dbB);
    await a.setServer(url);
    await b.setServer(url);

    // A：离线记了日记和交易，注册后上传
    final journalA = JournalRepository(dbA, cal);
    final e = await journalA.create(content: '离线记录', classification: const EntryClass(category: 'observe'));
    final acc = await AccountRepository(dbA).ensureDefault();
    await TradeRepository(dbA).add(TradeDraft(
        accountId: acc.id, code: '600519.SH', side: TradeSide.buy, ts: 1, price: 1400, qty: 100));
    expect(await a.hasLocalData(), isTrue);
    final email = 'e2e${DateTime.now().microsecondsSinceEpoch}@test.dev';
    await a.register(email, 'password123');
    final (pushed, _) = await a.sync();
    expect(pushed, greaterThanOrEqualTo(3));

    // B：登录同一账户，拉到全部数据
    await b.login(email, 'password123');
    await b.sync();
    final journalB = JournalRepository(dbB, cal);
    expect((await journalB.get(e.id))!.content, '离线记录');
    expect(await TradeRepository(dbB).all(), hasLength(1));
    expect((await AccountRepository(dbB).all()).single.id, acc.id);

    // B 修改 → A 同步后看到
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await journalB.update(e.id, content: 'B 改过');
    await b.sync();
    await a.sync();
    expect((await journalA.get(e.id))!.content, 'B 改过');

    // A 删除 → B 同步后也软删除
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await journalA.delete(e.id);
    await a.sync();
    await b.sync();
    expect((await journalB.get(e.id))!.deletedAt, isNotNull);

    // 冲突：两边都改，后改的赢；被覆盖的一方写入修改历史
    await journalA.restore(e.id);
    await a.sync();
    await b.sync();
    await journalB.update(e.id, content: 'B 先改'); // B 离线修改，尚未同步
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await journalA.update(e.id, content: 'A 后改');
    await a.sync(); // A 先同步
    await b.sync(); // B 的推送被拒（服务器更新），拉到 A 的版本，B 的版本进修改历史
    expect((await journalB.get(e.id))!.content, 'A 后改');
    final conflicts = await (dbB.select(dbB.revisions)..where((r) => r.entityId.equals(e.id))).get();
    expect(conflicts.any((r) => r.changedFields.contains('sync_conflict') && r.before['content'] == 'B 先改'), isTrue);

    // 退出登录后不能同步，数据保留
    await b.logout();
    expect(await b.user(), isNull);
    await expectLater(b.sync(), throwsA(isA<SyncException>()));
    expect((await journalB.get(e.id))!.content, 'A 后改');

    // 错误密码
    await expectLater(b.login(email, 'wrong-password'), throwsA(isA<SyncException>()));

    await dbA.close();
    await dbB.close();
  }, skip: hasServer ? null : '需要 server/.venv（见 server/README.md）');
}
