import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/backup/backup_service.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/repo/agent_repository.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/trade_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/trade/trade_rules.dart';

void main() {
  final cal = TradingCalendar();
  var clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);

  test('导出后导入到另一台设备：数据与偏好一致；重复导入跳过；不导出密钥', () async {
    final a = AppDatabase(NativeDatabase.memory());
    final b = AppDatabase(NativeDatabase.memory());
    final journalA = JournalRepository(a, cal, now: () => clock);
    final e = await journalA.create(
        content: '半导体放量', tags: const ['突破'], classification: const EntryClass(category: 'observe'));
    final acc = await AccountRepository(a).ensureDefault();
    await TradeRepository(a).add(TradeDraft(accountId: acc.id, code: '600519.SH', side: TradeSide.buy, ts: 1, price: 1400, qty: 100));
    await AgentRepository(a).addMemory(kind: MemoryKind.rule, content: '不追涨停');
    await SettingsStore(a).setRaw('ai.settings', '{"schedule":false}');
    await SettingsStore(a).setRaw('sync.user', '{"id":"secret"}');
    await MemorySecretStore().write('tushare_token', 'tok');

    final bytes = await BackupService(a, now: () => clock).exportBytes();
    final text = utf8.decode(bytes);
    expect(text, isNot(contains('sync.user')));
    expect((jsonDecode(text)['settings'] as Map).keys, ['ai.settings'], reason: '只导出白名单内的偏好，不含设备 id 与登录信息');

    final r = await BackupService(b).importBytes(bytes);
    expect(r.applied, greaterThanOrEqualTo(4));
    final got = (await JournalRepository(b, cal).get(e.id))!;
    expect((got.content, got.category), ('半导体放量', 'observe'));
    expect(got.tags, ['突破']);
    expect(await TradeRepository(b).all(), hasLength(1));
    expect((await AgentRepository(b).activeMemories()).single.content, '不追涨停');
    expect(await SettingsStore(b).raw('ai.settings'), '{"schedule":false}');
    expect(await SettingsStore(b).raw('sync.user'), isNull);

    // 再次导入：全部跳过
    expect((await BackupService(b).importBytes(bytes)).applied, 0);

    // 本机较新的修改不会被旧备份覆盖
    clock = clock.add(const Duration(minutes: 5));
    await JournalRepository(b, cal, now: () => clock).update(e.id, content: '本机新内容');
    await BackupService(b).importBytes(bytes);
    expect((await JournalRepository(b, cal).get(e.id))!.content, '本机新内容');

    await a.close();
    await b.close();
  });

  test('非备份文件给出明确提示', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final svc = BackupService(db);
    await expectLater(svc.importBytes(utf8.encode('not json')), throwsA(isA<BackupFormatException>()));
    await expectLater(svc.importBytes(utf8.encode('{"format":"x"}')), throwsA(isA<BackupFormatException>()));
    await db.close();
  });

  test('导出 Markdown：按日期分组', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await JournalRepository(db, cal, now: () => MarketClock.fromMarket(2026, 11, 13, 10, 5))
        .create(content: '早盘观察', classification: const EntryClass(category: 'observe'));
    final md = await BackupService(db).exportMarkdown();
    expect(md, contains('## 2026-11-13'));
    expect(md, contains('- **10:05** [观察] 早盘观察'));
    await db.close();
  });
}
