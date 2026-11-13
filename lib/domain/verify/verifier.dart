import 'dart:math' as math;

import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../core/time/trading_session.dart';
import '../../data/market/models.dart';

/// 判定结果状态（spec 3.3.2）。
enum VerifyStatus {
  correct('correct', '正确'),
  wrong('wrong', '错误'),
  partial('partial', '部分正确'),
  pendingManual('pending_manual', '待手动判定');

  const VerifyStatus(this.code, this.label);
  final String code;
  final String label;

  static VerifyStatus? fromCode(String? code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

/// 判定周期 → 交易日数。
int horizonDays(String horizon) => switch (horizon) {
      'close' => 0,
      't1' => 1,
      't3' => 3,
      't5' => 5,
      'mid' => 20,
      _ => 1,
    };

const horizonLabels = {
  'close': '今日',
  't1': 'T+1',
  't3': 'T+3',
  't5': '一周',
  'mid': '中期',
};

/// 一条判断的时间窗口：基准日、观察区间起点、到期日。
class PredictionWindow {
  const PredictionWindow({
    required this.dueDate,
    required this.windowStart,
    required this.baseFromPrevClose,
  });

  /// 到期交易日（以该日收盘价判定）
  final DateTime dueDate;

  /// 观察区间第一个交易日（用于目标价 / 止损触发、MFE / MAE）
  final DateTime windowStart;

  /// 缺少录入时快照时，基准价取前一交易日收盘（true）还是记录当日收盘（false）
  final bool baseFromPrevClose;

  /// 计算窗口：
  /// - 盘前 / 盘中记录：T 为当天，今日 = 当天收盘
  /// - 盘后记录：基准为当天收盘，"今日"顺延到下一交易日
  /// - 周末 / 假日记录：所属交易日即第一个交易日，T+1 = 该日
  static PredictionWindow of(
      TradingCalendar cal, DateTime tradeDate, TradingSession session, String horizon) {
    final n = horizonDays(horizon);
    return switch (session) {
      TradingSession.afterMarket => PredictionWindow(
          dueDate: cal.addTradingDays(tradeDate, math.max(n, 1)),
          windowStart: cal.next(tradeDate),
          baseFromPrevClose: false,
        ),
      TradingSession.holiday => PredictionWindow(
          dueDate: cal.addTradingDays(tradeDate, math.max(n - 1, 0)),
          windowStart: tradeDate,
          baseFromPrevClose: true,
        ),
      _ => PredictionWindow(
          dueDate: cal.addTradingDays(tradeDate, n),
          windowStart: tradeDate,
          baseFromPrevClose: true,
        ),
    };
  }
}

/// 判定输入。
class VerifyInput {
  const VerifyInput({
    required this.direction,
    required this.basePrice,
    required this.thresholdPct,
    required this.windowStart,
    required this.dueDate,
    this.targetPrice,
    this.stopPrice,
    this.rangeLow,
    this.rangeHigh,
  });

  /// up | down | range（与日记方向 bull | bear | range 对应）
  final String direction;
  final double basePrice;
  final double thresholdPct;
  final DateTime windowStart;
  final DateTime dueDate;
  final double? targetPrice;
  final double? stopPrice;
  final double? rangeLow;
  final double? rangeHigh;
}

class VerifyOutcome {
  const VerifyOutcome({
    required this.status,
    required this.actualClose,
    required this.changePct,
    required this.mfe,
    required this.mae,
    this.reason,
  });

  final VerifyStatus status;
  final double actualClose;
  final double changePct;

  /// 最大有利波动（%）
  final double mfe;

  /// 最大不利波动（%，负数）
  final double mae;
  final String? reason;
}

/// 判定引擎（纯函数，可单测）。
///
/// 规则（spec 3.3.2）：
/// - 仅方向：到期收盘 vs 基准价。看多：涨幅 ≥ 阈值正确，0~阈值部分正确，≤0 错误；看空对称；
///   震荡：|涨跌幅| < 阈值正确，否则错误（若设了区间，以到期收盘是否在区间内为准）。
/// - 有目标价 / 止损价：在观察区间内逐日看最高 / 最低价先触及哪个；同一天都触及 → 待手动；
///   都未触及则按方向规则，原本"正确"降为"部分正确"（方向对但未达目标）。
class Verifier {
  Verifier._();

  /// 返回 null 表示数据不足（到期日 K 线尚未生成）。
  static VerifyOutcome? verify(VerifyInput input, List<KBar> bars) {
    final start = TradeDate.format(input.windowStart);
    final due = TradeDate.format(input.dueDate);
    final window = bars.where((b) => b.date.compareTo(start) >= 0 && b.date.compareTo(due) <= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (window.isEmpty || window.last.date != due) return null;

    final base = input.basePrice;
    final close = window.last.close;
    final change = (close - base) / base * 100;
    final hi = window.map((b) => b.high).reduce(math.max);
    final lo = window.map((b) => b.low).reduce(math.min);
    final up = (hi - base) / base * 100;
    final down = (lo - base) / base * 100;
    final dir = input.direction;
    final mfe = dir == 'down' ? -down : up;
    final mae = dir == 'down' ? -up : down;
    final th = input.thresholdPct;

    VerifyOutcome out(VerifyStatus s, [String? reason]) => VerifyOutcome(
          status: s,
          actualClose: close,
          changePct: change,
          mfe: dir == 'range' ? math.max(up.abs(), down.abs()) : mfe,
          mae: dir == 'range' ? 0 : mae,
          reason: reason,
        );

    // 目标价 / 止损价
    if (dir != 'range' && (input.targetPrice != null || input.stopPrice != null)) {
      for (final b in window) {
        final hitTarget = input.targetPrice != null &&
            (dir == 'up' ? b.high >= input.targetPrice! : b.low <= input.targetPrice!);
        final hitStop = input.stopPrice != null &&
            (dir == 'up' ? b.low <= input.stopPrice! : b.high >= input.stopPrice!);
        if (hitTarget && hitStop) return out(VerifyStatus.pendingManual, '${b.date} 同日触及目标价与止损价');
        if (hitTarget) return out(VerifyStatus.correct, '${b.date} 触及目标价');
        if (hitStop) return out(VerifyStatus.wrong, '${b.date} 触及止损价');
      }
      final s = _byDirection(dir, change, th);
      if (input.targetPrice != null && s == VerifyStatus.correct) {
        return out(VerifyStatus.partial, '方向正确但未达目标价');
      }
      return out(s);
    }

    if (dir == 'range' && input.rangeLow != null && input.rangeHigh != null) {
      final inRange = close >= input.rangeLow! && close <= input.rangeHigh!;
      return out(inRange ? VerifyStatus.correct : VerifyStatus.wrong,
          inRange ? '收盘在区间内' : '收盘超出区间');
    }
    return out(_byDirection(dir, change, th));
  }

  static VerifyStatus _byDirection(String dir, double change, double th) => switch (dir) {
        'up' => change >= th
            ? VerifyStatus.correct
            : (change > 0 ? VerifyStatus.partial : VerifyStatus.wrong),
        'down' => change <= -th
            ? VerifyStatus.correct
            : (change < 0 ? VerifyStatus.partial : VerifyStatus.wrong),
        _ => change.abs() < th ? VerifyStatus.correct : VerifyStatus.wrong,
      };

  /// 日记方向 → 判断方向。
  static String directionOf(String stance) => switch (stance) {
        'bull' => 'up',
        'bear' => 'down',
        _ => 'range',
      };
}
