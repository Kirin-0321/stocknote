import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/trading_session.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/domain/verify/checkpoints.dart';
import 'package:stocknote/domain/verify/threshold.dart';
import 'package:stocknote/domain/verify/verifier.dart';

KBar bar(String d, double c, {double? h, double? l, double? o}) =>
    KBar(date: d, open: o ?? c, high: h ?? c, low: l ?? c, close: c);

void main() {
  DateTime d(int m, int day) => DateTime.utc(2026, m, day);

  group('验证时点规划', () {
    final cal = TradingCalendar(); // 工作日规则；11/13 周五

    test('盘中记录：当日收盘 / 次日开盘 / 次日收盘 / T+3 / T+5，主时点随周期', () {
      final p = CheckpointPlan.of(cal, d(11, 13), TradingSession.morning, 't1');
      expect(p.points, {
        Checkpoint.c0: d(11, 13),
        Checkpoint.o1: d(11, 16),
        Checkpoint.c1: d(11, 16),
        Checkpoint.c3: d(11, 18),
        Checkpoint.c5: d(11, 20),
      });
      expect(p.primary, Checkpoint.c1);
      expect(p.windowStart, d(11, 13));
      expect(p.baseIsRefClose, isFalse);
      expect(CheckpointPlan.of(cal, d(11, 13), TradingSession.morning, 'close').primary, Checkpoint.c0);
      expect(CheckpointPlan.of(cal, d(11, 13), TradingSession.morning, 't5').primary, Checkpoint.c5);
    });

    test('中期判断额外加 T+20', () {
      final p = CheckpointPlan.of(cal, d(11, 13), TradingSession.morning, 'mid');
      expect(p.primary, Checkpoint.c20);
      expect(p.points[Checkpoint.c20], d(12, 11));
    });

    test('盘后记录：没有当日收盘，"今日"即次日收盘，基准为当日收盘', () {
      final p = CheckpointPlan.of(cal, d(11, 13), TradingSession.afterMarket, 'close');
      expect(p.points.containsKey(Checkpoint.c0), isFalse);
      expect(p.points[Checkpoint.o1], d(11, 16));
      expect(p.primary, Checkpoint.c1);
      expect(p.windowStart, d(11, 16));
      expect(p.baseIsRefClose, isTrue);
    });

    test('周末记录：参考日为上一交易日，从下一交易日开盘起验证', () {
      // 周六记录的 tradeDate 已是下周一
      final p = CheckpointPlan.of(cal, d(11, 16), TradingSession.holiday, 't1');
      expect(p.refDay, d(11, 13));
      expect(p.points[Checkpoint.o1], d(11, 16));
      expect(p.primaryDate, d(11, 16));
      expect(p.points[Checkpoint.c5], d(11, 20));
    });
  });

  test('开盘时点只看开盘价', () {
    final o = Verifier.verify(
      VerifyInput(
          direction: 'up', basePrice: 100, thresholdPct: 1, windowStart: d(11, 13), dueDate: d(11, 16), atOpen: true),
      [bar('20261113', 100, h: 100.5, l: 99.5), bar('20261116', 99, o: 101.5, h: 103, l: 98)],
    )!;
    expect(o.actualClose, 101.5);
    expect(o.status, VerifyStatus.correct);
    expect(o.mfe, closeTo(1.5, 1e-9), reason: '当日盘中高点 103 不计入');
  });

  group('仅方向', () {
    VerifyOutcome? run(String dir, double close, {double th = 1.0}) => Verifier.verify(
          VerifyInput(
              direction: dir, basePrice: 100, thresholdPct: th, windowStart: d(11, 13), dueDate: d(11, 16)),
          [bar('20261113', 100.5, h: 101, l: 99), bar('20261116', close, h: close + 1, l: close - 2)],
        );

    test('看多', () {
      expect(run('up', 101.5)!.status, VerifyStatus.correct);
      expect(run('up', 100.4)!.status, VerifyStatus.partial);
      expect(run('up', 99)!.status, VerifyStatus.wrong);
    });

    test('看空', () {
      expect(run('down', 98)!.status, VerifyStatus.correct);
      expect(run('down', 99.8)!.status, VerifyStatus.partial);
      expect(run('down', 100.2)!.status, VerifyStatus.wrong);
    });

    test('震荡', () {
      expect(run('range', 100.6)!.status, VerifyStatus.correct);
      expect(run('range', 102)!.status, VerifyStatus.wrong);
    });

    test('涨跌幅与 MFE / MAE', () {
      final o = run('up', 102)!;
      expect(o.changePct, closeTo(2, 1e-9));
      expect(o.actualClose, 102);
      expect(o.mfe, closeTo(3, 1e-9)); // 最高 103
      expect(o.mae, closeTo(-1, 1e-9)); // 最低 99（首日）
    });

    test('到期日 K 线尚未生成时返回 null', () {
      final o = Verifier.verify(
        VerifyInput(direction: 'up', basePrice: 100, thresholdPct: 1, windowStart: d(11, 13), dueDate: d(11, 16)),
        [bar('20261113', 101)],
      );
      expect(o, isNull);
    });
  });

  group('目标价 / 止损价', () {
    VerifyOutcome run(List<KBar> bars, {double? target, double? stop, String dir = 'up'}) => Verifier.verify(
          VerifyInput(
            direction: dir,
            basePrice: 100,
            thresholdPct: 1,
            windowStart: d(11, 13),
            dueDate: d(11, 17),
            targetPrice: target,
            stopPrice: stop,
          ),
          bars,
        )!;

    final bars = [
      bar('20261113', 101, h: 102, l: 99),
      bar('20261116', 104, h: 106, l: 100),
      bar('20261117', 100, h: 101, l: 95),
    ];

    test('先触及目标价 → 正确（即使到期收盘回落）', () {
      expect(run(bars, target: 105, stop: 96).status, VerifyStatus.correct);
    });

    test('先触及止损价 → 错误', () {
      expect(run(bars, target: 110, stop: 99.5).status, VerifyStatus.wrong);
    });

    test('同日触及两者 → 待手动', () {
      expect(run(bars, target: 101.5, stop: 99.5).status, VerifyStatus.pendingManual);
    });

    test('均未触及：方向对但未达目标 → 部分正确', () {
      final up = [bar('20261113', 101), bar('20261116', 102), bar('20261117', 103, h: 103.5)];
      final o = run(up, target: 110, stop: 90);
      expect(o.status, VerifyStatus.partial);
      expect(o.reason, contains('未达目标'));
    });

    test('看空的目标价看最低价', () {
      final dn = [bar('20261113', 99, l: 97), bar('20261116', 96, l: 94), bar('20261117', 97)];
      expect(run(dn, target: 95, stop: 103, dir: 'down').status, VerifyStatus.correct);
    });
  });

  test('震荡区间：以到期收盘是否在区间内为准', () {
    final o = Verifier.verify(
      VerifyInput(
        direction: 'range',
        basePrice: 100,
        thresholdPct: 0.5,
        windowStart: d(11, 13),
        dueDate: d(11, 13),
        rangeLow: 98,
        rangeHigh: 103,
      ),
      [bar('20261113', 102.5)],
    )!;
    expect(o.status, VerifyStatus.correct);
  });

  test('阈值优先级：单条 > 类型+周期 > 类型 > 全局', () {
    const cfg = ThresholdConfig(
      global: 0.8,
      byType: {InstrumentType.stock: 1.0},
      byTypeHorizon: {(InstrumentType.stock, 't5'): 2.0},
    );
    expect(cfg.resolve(InstrumentType.stock, 't1'), 1.0);
    expect(cfg.resolve(InstrumentType.stock, 't5'), 2.0);
    expect(cfg.resolve(InstrumentType.etf, 't1'), 0.8);
    expect(cfg.resolve(InstrumentType.stock, 't5', override: 0.3), 0.3);
    expect(const ThresholdConfig().resolve(InstrumentType.marketIndex, 't1'), 0.3);
  });
}

