import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/repo/threshold_repository.dart';
import 'package:stocknote/data/market/snapshot_service.dart';
import 'package:stocknote/data/repo/market_snapshot_repository.dart';
import 'package:stocknote/data/service/journal_service.dart';
import 'package:stocknote/data/service/verification_service.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/verify/checkpoints.dart';
import 'package:stocknote/domain/verify/threshold.dart';
import 'package:stocknote/domain/verify/verifier.dart';

import '../helpers/fake_market.dart';

KBar bar(String d, double c, {double? h, double? l}) =>
    KBar(date: d, open: c, high: h ?? c, low: l ?? c, close: c);

void main() {
  late AppDatabase db;
  late DateTime clock;
  late JournalRepository journal;
  late PredictionRepository preds;
  final cal = TradingCalendar();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = MarketClock.fromMarket(2026, 11, 13, 10, 5); // 周五盘中
    journal = JournalRepository(db, cal, now: () => clock);
    preds = PredictionRepository(db, cal, now: () => clock);
  });
  tearDown(() => db.close());

  Future<JournalEntry> judge({String stance = 'bull', String? horizon = 't1', List<String> codes = const ['600519.SH'], String? sub}) =>
      journal.create(
        content: '判断',
        instrumentCodes: codes,
        classification: EntryClass(category: 'judge', subcategory: sub, stance: stance, horizon: horizon),
      );

  group('由日记生成判断', () {
    test('判断类日记生成判断：目标、方向、到期日', () async {
      final e = await judge();
      final p = (await preds.syncFromEntry(e))!;
      expect(p.targetCode, '600519.SH');
      expect(p.direction, 'up');
      expect(p.horizonType, 't1');
      expect(p.dueDate, '20261116'); // 周五 T+1 = 下周一
      expect(p.basePrice, isNull);
    });

    test('大盘判断未关联标的时默认上证指数；未选周期默认 T+1', () async {
      final e = await judge(codes: const [], sub: 'market', horizon: null, stance: 'bear');
      final p = (await preds.syncFromEntry(e))!;
      expect(p.targetCode, '000001.SH');
      expect(p.direction, 'down');
      expect(p.horizonType, 't1');
    });

    test('非判断类或缺少方向 / 目标时不生成；改成观察后判断被移除', () async {
      final obs = await journal.create(content: 'x', classification: const EntryClass(category: 'observe'));
      expect(await preds.syncFromEntry(obs), isNull);
      final noTarget = await judge(codes: const []);
      expect(await preds.syncFromEntry(noTarget), isNull);

      final e = await judge();
      await preds.syncFromEntry(e);
      final changed = await journal.update(e.id, classification: const EntryClass(category: 'observe'));
      await preds.syncFromEntry(changed);
      expect(await preds.forEntry(e.id), isNull);
    });

    test('快照补全基准价不算修改；到期前改方向记录历史并标记', () async {
      final e = await judge();
      await preds.syncFromEntry(e);
      final snap = await db.into(db.marketSnapshots).insertReturning(MarketSnapshotsCompanion.insert(
            id: 's1', createdAt: 0, updatedAt: 0, deviceId: 'd', ts: 0,
            indices: const {},
            extra: const Value({'instruments': {'600519.SH': {'name': '贵州茅台', 'price': 1420.5, 'pct': 0.7}}}),
          ));
      var p = (await preds.syncFromEntry(e, snapshot: snap))!;
      expect(p.basePrice, 1420.5);
      expect(p.revisionCount, 0);
      expect(p.modifiedBeforeDue, isFalse);

      final e2 = await journal.update(e.id,
          classification: const EntryClass(category: 'judge', stance: 'bear', horizon: 't1'));
      p = (await preds.syncFromEntry(e2))!;
      expect(p.direction, 'down');
      expect(p.basePrice, 1420.5, reason: '基准价保持录入时的值');
      expect(p.revisionCount, 1);
      expect(p.modifiedBeforeDue, isTrue);
      expect((await preds.history(p.id)).single.changedFields, ['direction']);
    });
  });

  group('到期验证', () {
    late FakeSource source;
    late VerificationService svc;

    setUp(() {
      source = FakeSource(SourceId.tushare);
      svc = VerificationService(
        repo: preds,
        market: MarketService(MarketRouter([source], now: () => clock)),
        calendar: cal,
        thresholds: () async => const ThresholdConfig(),
        now: () => clock,
      );
    });

    test('多时点依次判定：当日收盘 → 次日开盘 / 收盘；主时点为 T+1 收盘；手动判定不被覆盖', () async {
      final e = await judge(); // 11/13 周五 10:05，看多 T+1
      final p = (await preds.syncFromEntry(e))!;
      source.klines['600519.SH'] = [
        bar('20261112', 1400),
        bar('20261113', 1410, h: 1415, l: 1395),
        KBar(date: '20261116', open: 1420, high: 1440, low: 1405, close: 1430),
      ];

      expect((await svc.runDue()).verified, 0, reason: '盘中没有到期时点');

      clock = MarketClock.fromMarket(2026, 11, 13, 16, 0);
      expect((await svc.runDue()).verified, 1, reason: '当日收盘');
      var v = (await preds.view(p.id))!;
      // 无快照：盘中记录基准取前一交易日收盘 1400；当日收盘 1410 → +0.71%，看多但未达个股阈值 1%
      expect(v.prediction.basePrice, 1400);
      expect(v.statusAt(Checkpoint.c0), VerifyStatus.partial);
      expect(v.status, isNull, reason: '主时点（次日收盘）尚未判定');

      clock = MarketClock.fromMarket(2026, 11, 16, 9, 20);
      expect((await svc.runDue()).verified, 0, reason: '开盘前');

      clock = MarketClock.fromMarket(2026, 11, 16, 16, 0);
      expect((await svc.runDue()).verified, 2, reason: '次日开盘 + 次日收盘');
      v = (await preds.view(p.id))!;
      expect(v.results[Checkpoint.o1]!.actualClose, 1420);
      expect(v.statusAt(Checkpoint.o1), VerifyStatus.correct); // +1.43%
      expect(v.status, VerifyStatus.correct);
      expect(v.result!.changePct, closeTo(2.142857, 1e-4));
      expect(v.allDone, isFalse, reason: 'T+3 / T+5 未到');

      await preds.setManualStatus(p.id, Checkpoint.c1, VerifyStatus.wrong);
      await preds.clearAutoResults();
      v = (await preds.view(p.id))!;
      expect(v.status, VerifyStatus.wrong);
      expect(v.results.containsKey(Checkpoint.c0), isFalse);
    });

    test('时点日 K 线尚未更新时稍后重试', () async {
      final e = await judge();
      await preds.syncFromEntry(e);
      source.klines['600519.SH'] = [bar('20261112', 1400), bar('20261113', 1410)];
      clock = MarketClock.fromMarket(2026, 11, 17, 10, 0);
      final r = await svc.runDue();
      expect((r.verified, r.waiting), (1, 2), reason: '当日收盘可判；次日开盘 / 收盘缺 11/16 K 线');
    });

    test('当天的时点用实时行情补 K 线：开盘后判次日开盘，收盘后判收盘', () async {
      final e = await judge();
      final p = (await preds.syncFromEntry(e))!;
      source.klines['600519.SH'] = [bar('20261112', 1400), bar('20261113', 1410)];
      source.quoteOverride = (code) =>
          const Quote(code: '600519.SH', name: '贵州茅台', price: 1390, preClose: 1410, open: 1425, high: 1426, low: 1388);
      clock = MarketClock.fromMarket(2026, 11, 16, 10, 0);
      await svc.runDue();
      var v = (await preds.view(p.id))!;
      expect(v.results[Checkpoint.o1]!.actualClose, 1425);
      expect(v.results.containsKey(Checkpoint.c1), isFalse);

      clock = MarketClock.fromMarket(2026, 11, 16, 15, 10);
      await svc.runDue();
      v = (await preds.view(p.id))!;
      expect(v.result!.actualClose, 1390);
      expect(v.status, VerifyStatus.wrong);
    });

    test('复盘笔记与视图', () async {
      final e = await judge();
      final p = (await preds.syncFromEntry(e))!;
      await preds.saveReview(p.id, content: '逻辑对但时机错', reasons: ['时机']);
      await preds.saveReview(p.id, content: '更新', reasons: ['时机', '消息面']);
      final v = (await preds.view(p.id))!;
      expect(v.reviewed, isTrue);
      expect(v.review!.content, '更新');
      expect(v.entry!.id, e.id);
      expect((await preds.all()), hasLength(1));
    });
  });

  test('补建：功能上线前的判断类日记补生成判断，已有的不重复', () async {
    final e1 = await judge();
    final e2 = await judge(codes: const [], sub: 'market');
    await journal.create(content: 'x', classification: const EntryClass(category: 'observe'));
    final svc = JournalService(
      journal: journal,
      predictions: preds,
      snapshots: SnapshotService(
          market: MarketService(MarketRouter(const [])),
          repo: MarketSnapshotRepository(db),
          latestOverview: () => null),
    );
    expect(await svc.backfillPredictions(), 2);
    expect(await svc.backfillPredictions(), 0);
    expect(await preds.forEntry(e1.id), isNotNull);
    expect((await preds.forEntry(e2.id))!.targetCode, '000001.SH');
  });

  test('阈值配置持久化', () async {
    final repo = ThresholdRepository(db);
    expect((await repo.load()).resolve(InstrumentType.stock, 't1'), 1.0);
    await repo.save(const ThresholdConfig(
      global: 0.6,
      byType: {InstrumentType.stock: 1.5},
      byTypeHorizon: {(InstrumentType.stock, 'mid'): 3.0},
    ));
    final cfg = await repo.load();
    expect(cfg.global, 0.6);
    expect(cfg.resolve(InstrumentType.stock, 't1'), 1.5);
    expect(cfg.resolve(InstrumentType.stock, 'mid'), 3.0);
    expect(cfg.resolve(InstrumentType.marketIndex, 't1'), 0.3, reason: '未保存的类型保留默认');
  });
}


