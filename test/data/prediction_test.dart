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
import 'package:stocknote/data/service/verification_service.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
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
      );
    });

    test('未到期不验证；到期日 15:30 后按日 K 判定；手动判定不被覆盖', () async {
      final e = await judge();
      final p = (await preds.syncFromEntry(e))!;
      source.klines['600519.SH'] = [
        bar('20261112', 1400),
        bar('20261113', 1410, h: 1415, l: 1395),
        bar('20261116', 1430, h: 1440, l: 1405),
      ];

      expect((await svc.runDue()).verified, 0);

      clock = MarketClock.fromMarket(2026, 11, 16, 15, 0);
      expect((await svc.runDue()).verified, 0, reason: '15:30 前不判定');

      clock = MarketClock.fromMarket(2026, 11, 16, 16, 0);
      final r = await svc.runDue();
      expect(r.verified, 1);
      final v = (await preds.view(p.id))!;
      // 无快照：盘中记录基准取前一交易日收盘 1400；到期收盘 1430 → +2.14% ≥ 个股阈值 1%
      expect(v.prediction.basePrice, 1400);
      expect(v.status, VerifyStatus.correct);
      expect(v.result!.changePct, closeTo(2.142857, 1e-4));

      await preds.setManualStatus(p.id, VerifyStatus.wrong);
      await preds.clearAutoResults();
      expect((await preds.view(p.id))!.status, VerifyStatus.wrong);
    });

    test('到期日 K 线尚未更新时稍后重试', () async {
      final e = await judge();
      await preds.syncFromEntry(e);
      source.klines['600519.SH'] = [bar('20261112', 1400), bar('20261113', 1410)];
      clock = MarketClock.fromMarket(2026, 11, 16, 16, 0);
      final r = await svc.runDue();
      expect((r.verified, r.waiting), (0, 1));
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
