import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../domain/verify/checkpoints.dart';
import '../../domain/verify/threshold.dart';
import '../../domain/verify/verifier.dart';
import '../market/code_util.dart';
import '../market/market_service.dart';
import '../market/models.dart';
import '../repo/prediction_repository.dart';

class VerifyRunResult {
  const VerifyRunResult({this.verified = 0, this.waiting = 0, this.errors = const []});

  /// 本次判定的时点数
  final int verified;

  /// 已到时点但行情数据尚未更新，稍后重试
  final int waiting;
  final List<String> errors;
}

/// 多时点自动验证（spec 3.3.2）。
///
/// 历史时点用日 K；当天的时点用实时行情补一根当日 K 线（开盘后可判"次日开盘"，15:05 后可判"收盘"），
/// 不必等日线入库。
class VerificationService {
  VerificationService({
    required this.repo,
    required this.market,
    required this.calendar,
    required this.thresholds,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PredictionRepository repo;
  final MarketService market;
  final TradingCalendar calendar;
  final Future<ThresholdConfig> Function() thresholds;
  final DateTime Function() _now;

  Future<VerifyRunResult> runDue() async {
    final pending = await repo.pendingCheckpoints();
    if (pending.isEmpty) return const VerifyRunResult();
    final cfg = await thresholds();
    var verified = 0, waiting = 0;
    final errors = <String>[];

    // 同一标的只拉一次 K 线
    final byTarget = <String, List<(PredictionView, List<Checkpoint>)>>{};
    for (final item in pending) {
      (byTarget[item.$1.prediction.targetCode] ??= []).add(item);
    }
    for (final MapEntry(key: code, value: items) in byTarget.entries) {
      try {
        final earliest = items
            .map((i) => calendar.previous(i.$1.plan.refDay))
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final bars = [
          ...await market.dailyKline(code, from: TradeDate.format(earliest.subtract(const Duration(days: 7)))),
        ];
        await _appendTodayBar(code, bars);

        for (final (v, checkpoints) in items) {
          final p = v.prediction;
          final base = p.basePrice ?? _baseFromBars(bars, v.plan);
          if (base == null) {
            waiting += checkpoints.length;
            continue;
          }
          if (p.basePrice == null) await repo.setBasePrice(p.id, base);
          for (final cp in checkpoints) {
            final outcome = Verifier.verify(
              VerifyInput(
                direction: p.direction,
                basePrice: base,
                thresholdPct:
                    cfg.resolve(Codes.guessType(code), cp.thresholdHorizon, override: p.thresholdPct),
                windowStart: v.plan.windowStart,
                dueDate: v.plan.points[cp]!,
                atOpen: cp.atOpen,
                targetPrice: p.targetPrice,
                stopPrice: p.stopPrice,
                rangeLow: p.rangeLow,
                rangeHigh: p.rangeHigh,
              ),
              bars,
            );
            if (outcome == null) {
              waiting++;
              continue;
            }
            await repo.saveResult(p.id, cp, outcome);
            verified++;
          }
        }
      } catch (e) {
        errors.add('$code：$e');
      }
    }
    return VerifyRunResult(verified: verified, waiting: waiting, errors: errors);
  }

  /// 日线里还没有今天时，用实时报价补一根：收盘后为完整 K 线，盘中仅含开盘价。
  Future<void> _appendTodayBar(String code, List<KBar> bars) async {
    final now = MarketClock.toMarket(_now());
    final todayDate = DateTime.utc(now.year, now.month, now.day);
    final today = TradeDate.format(todayDate);
    if (!calendar.isTradingDay(todayDate) || bars.any((b) => b.date == today)) return;
    final minutes = now.hour * 60 + now.minute;
    if (minutes < 9 * 60 + 26) return;
    try {
      final q = (await market.quotes([code])).where((x) => x.code == code).firstOrNull;
      if (q == null || q.approx) return;
      if (minutes >= 15 * 60 + 5) {
        bars.add(KBar(
            date: today,
            open: q.open ?? q.price,
            high: q.high ?? q.price,
            low: q.low ?? q.price,
            close: q.price));
      } else if (q.open != null && q.open! > 0) {
        final o = q.open!;
        bars.add(KBar(date: today, open: o, high: o, low: o, close: o));
      }
    } catch (_) {
      // 实时报价失败：等日线入库后再判
    }
  }

  /// 缺少录入快照的基准价：盘后 / 假日记录取参考日收盘，盘前 / 盘中取参考日前一交易日收盘。
  double? _baseFromBars(List<KBar> bars, CheckpointPlan plan) {
    final ref = TradeDate.format(plan.baseIsRefClose ? plan.refDay : calendar.previous(plan.refDay));
    for (final b in bars.reversed) {
      if (b.date.compareTo(ref) <= 0) return b.close;
    }
    return null;
  }
}
