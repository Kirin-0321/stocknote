import 'dart:math' as math;

import '../../core/time/market_clock.dart';
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

/// 判定输入。
class VerifyInput {
  const VerifyInput({
    required this.direction,
    required this.basePrice,
    required this.thresholdPct,
    required this.windowStart,
    required this.dueDate,
    this.atOpen = false,
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
  /// 判定时点所在交易日
  final DateTime dueDate;

  /// 用该日开盘价判定（当日只计入开盘价，不含盘中高低点）
  final bool atOpen;
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
    if (input.atOpen) {
      final o = window.last.open;
      window[window.length - 1] = KBar(date: due, open: o, high: o, low: o, close: o);
    }

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


