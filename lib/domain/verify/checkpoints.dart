import '../../core/calendar/trading_calendar.dart';
import '../../core/time/trading_session.dart';

/// 验证时点（spec 3.3.2 v0.4）：每条判断默认在多个时点各判定一次。
enum Checkpoint {
  c0('c0', '当日收盘', '当收', 0, false, 'close'),
  o1('o1', '次日开盘', '次开', 1, true, 'close'),
  c1('c1', '次日收盘', '次收', 1, false, 't1'),
  c3('c3', 'T+3 收盘', 'T+3', 3, false, 't3'),
  c5('c5', 'T+5 收盘', 'T+5', 5, false, 't5'),
  c20('c20', 'T+20 收盘', 'T+20', 20, false, 'mid');

  const Checkpoint(this.code, this.label, this.short, this.offset, this.atOpen, this.thresholdHorizon);

  final String code;
  final String label;
  final String short;

  /// 相对参考日 R 的交易日偏移
  final int offset;

  /// 用开盘价判定（否则用收盘价）
  final bool atOpen;

  /// 取阈值时对应的周期
  final String thresholdHorizon;

  static Checkpoint? fromCode(String? code) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

/// 一条判断的验证计划：参考日、观察起点、各时点日期、主时点、基准价取法。
class CheckpointPlan {
  const CheckpointPlan({
    required this.refDay,
    required this.windowStart,
    required this.points,
    required this.primary,
    required this.baseIsRefClose,
  });

  /// 参考日 R：其收盘即"当日收盘"。
  final DateTime refDay;

  /// 观察区间第一个交易日（记录之后的第一个交易时段所在日）
  final DateTime windowStart;

  /// 各时点及其交易日
  final Map<Checkpoint, DateTime> points;

  /// 主时点：由用户选的周期决定，作为判断的主结论
  final Checkpoint primary;

  /// 缺少录入快照时的基准价：true = R 日收盘（盘后 / 假日记录），false = R 前一交易日收盘（盘前 / 盘中记录）
  final bool baseIsRefClose;

  DateTime get primaryDate => points[primary]!;

  /// 规划：
  /// - 盘前 / 盘中记录：R = 当天，含"当日收盘"
  /// - 盘后记录：R = 当天（当日收盘已过，作为基准），从次日开盘开始验证
  /// - 周末 / 假日记录：R = 上一交易日，从下一交易日开盘开始验证
  static CheckpointPlan of(
      TradingCalendar cal, DateTime tradeDate, TradingSession session, String horizon) {
    final (ref, start, canC0) = switch (session) {
      TradingSession.afterMarket => (tradeDate, cal.next(tradeDate), false),
      TradingSession.holiday => (cal.previous(tradeDate), tradeDate, false),
      _ => (tradeDate, tradeDate, true),
    };
    final points = <Checkpoint, DateTime>{
      for (final c in Checkpoint.values)
        if ((c != Checkpoint.c0 || canC0) && (c != Checkpoint.c20 || horizon == 'mid'))
          c: cal.addTradingDays(ref, c.offset),
    };
    final primary = switch (horizon) {
      'close' => canC0 ? Checkpoint.c0 : Checkpoint.c1,
      't3' => Checkpoint.c3,
      't5' => Checkpoint.c5,
      'mid' => Checkpoint.c20,
      _ => Checkpoint.c1,
    };
    return CheckpointPlan(
      refDay: ref,
      windowStart: start,
      points: points,
      primary: primary,
      baseIsRefClose: !canC0,
    );
  }
}
