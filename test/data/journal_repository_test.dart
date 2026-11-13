import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/core/time/trading_session.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/repo/calendar_repository.dart';
import 'package:stocknote/data/repo/journal_repository.dart';

void main() {
  late AppDatabase db;
  late JournalRepository repo;
  late DateTime clock;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);
    repo = JournalRepository(db, TradingCalendar(), now: () => clock);
  });

  tearDown(() => db.close());

  test('创建条目时自动分配交易日、时段与设备 ID', () async {
    final e = await repo.create(content: '放量突破，看多', stance: 'bull', tags: ['突破']);
    expect(e.tradeDate, '20261113');
    expect(e.session, TradingSession.morning.code);
    expect(e.tags, ['突破']);
    expect(e.revisionCount, 0);
    expect(e.deviceId, await db.deviceId());
  });

  test('修改记录历史：保存修改前快照与变动字段', () async {
    final e = await repo.create(content: 'v1', stance: 'bull');

    clock = clock.add(const Duration(minutes: 30));
    final e2 = await repo.update(e.id, content: 'v2', stance: const Value('bear'));
    expect(e2.content, 'v2');
    expect(e2.stance, 'bear');
    expect(e2.revisionCount, 1);
    expect(e2.updatedAt, greaterThan(e.updatedAt));

    await repo.update(e.id, tags: ['复盘']);

    final history = await repo.history(e.id);
    expect(history, hasLength(2));
    expect(history[0].revisionNo, 1);
    expect(history[0].changedFields, ['content', 'stance']);
    expect(history[0].before['content'], 'v1');
    expect(history[1].changedFields, ['tags']);
    expect(history[1].before['content'], 'v2');
    expect((await repo.get(e.id))!.revisionCount, 2);
  });

  test('无实际变化的修改不产生历史', () async {
    final e = await repo.create(content: 'same');
    final e2 = await repo.update(e.id, content: 'same');
    expect(e2.revisionCount, 0);
    expect(await repo.history(e.id), isEmpty);
  });

  test('修改时间会重新计算交易日与时段', () async {
    final e = await repo.create(content: 'x');
    final e2 = await repo.update(e.id, at: MarketClock.fromMarket(2026, 11, 14, 9, 0));
    expect(e2.tradeDate, '20261116'); // 周六 → 下周一
    expect(e2.session, TradingSession.holiday.code);
    expect((await repo.history(e.id)).single.changedFields,
        containsAll(['ts', 'tradeDate', 'session']));
  });

  test('按交易日查询，排除软删除，按时间排序', () async {
    final a = await repo.create(content: 'a', at: MarketClock.fromMarket(2026, 11, 13, 14, 0));
    await repo.create(content: 'b', at: MarketClock.fromMarket(2026, 11, 13, 9, 20));
    await repo.create(content: 'other day', at: MarketClock.fromMarket(2026, 11, 12, 10, 0));
    final c = await repo.create(content: 'c', at: MarketClock.fromMarket(2026, 11, 13, 15, 30));
    await repo.delete(c.id);

    final list = await repo.watchDay(DateTime.utc(2026, 11, 13)).first;
    expect(list.map((e) => e.content), ['b', 'a']);
    expect(list.last.id, a.id);
  });

  test('交易日历持久化往返', () async {
    final calRepo = CalendarRepository(db);
    await calRepo.upsertAll({'20261001': false, '20261009': true});
    await calRepo.upsertAll({'20261001': false});
    final cal = await calRepo.load();
    expect(cal.hasData, isTrue);
    expect(cal.isTradingDay(DateTime.utc(2026, 10, 1)), isFalse);
  });

  test('schema 可创建全部表（含 Agent 表）', () async {
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(tables, containsAll([
      'journal_entries', 'predictions', 'revisions', 'trades',
      'agent_threads', 'agent_messages', 'agent_memories',
    ]));
  });
}
