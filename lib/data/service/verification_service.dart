import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../core/time/trading_session.dart';
import '../../domain/verify/threshold.dart';
import '../../domain/verify/verifier.dart';
import '../db/app_database.dart';
import '../market/code_util.dart';
import '../market/market_service.dart';
import '../market/models.dart';
import '../repo/prediction_repository.dart';

class VerifyRunResult {
  const VerifyRunResult({this.verified = 0, this.waiting = 0, this.errors = const []});
  final int verified;

  /// 已到期但 K 线尚未更新，稍后重试
  final int waiting;
  final List<String> errors;
}

/// 到期判断的自动验证（spec 3.3.2）：拉取日 K，按规则判定并保存结果。
class VerificationService {
  VerificationService({
    required this.repo,
    required this.market,
    required this.calendar,
    required this.thresholds,
  });

  final PredictionRepository repo;
  final MarketService market;
  final TradingCalendar calendar;
  final Future<ThresholdConfig> Function() thresholds;

  Future<VerifyRunResult> runDue() async {
    final due = await repo.dueUnverified();
    if (due.isEmpty) return const VerifyRunResult();
    final cfg = await thresholds();
    var verified = 0, waiting = 0;
    final errors = <String>[];

    // 同一标的只拉一次 K 线
    final byTarget = <String, List<Prediction>>{};
    for (final p in due) {
      (byTarget[p.targetCode] ??= []).add(p);
    }
    for (final entry in byTarget.entries) {
      final code = entry.key;
      final preds = entry.value;
      try {
        final ctx = <Prediction, (PredictionWindow, JournalEntry?)>{};
        DateTime? earliest;
        for (final p in preds) {
          final view = await repo.view(p.id);
          final w = _windowOf(p, view?.entry);
          ctx[p] = (w, view?.entry);
          final start = calendar.previous(w.windowStart);
          if (earliest == null || start.isBefore(earliest)) earliest = start;
        }
        final bars = await market.dailyKline(code,
            from: TradeDate.format(earliest!.subtract(const Duration(days: 7))));
        for (final p in preds) {
          final (w, entry) = ctx[p]!;
          final base = p.basePrice ?? _baseFromBars(bars, w, entry);
          if (base == null) {
            waiting++;
            continue;
          }
          if (p.basePrice == null) await repo.setBasePrice(p.id, base);
          final outcome = Verifier.verify(
            VerifyInput(
              direction: p.direction,
              basePrice: base,
              thresholdPct: cfg.resolve(Codes.guessType(code), p.horizonType, override: p.thresholdPct),
              windowStart: w.windowStart,
              dueDate: w.dueDate,
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
          await repo.saveResult(p.id, outcome);
          verified++;
        }
      } catch (e) {
        errors.add('$code：$e');
      }
    }
    return VerifyRunResult(verified: verified, waiting: waiting, errors: errors);
  }

  PredictionWindow _windowOf(Prediction p, JournalEntry? e) {
    if (e != null) {
      return PredictionWindow.of(
          calendar, TradeDate.parse(e.tradeDate), TradingSession.fromCode(e.session), p.horizonType);
    }
    // 无日记（如 AI 判断）：以创建时刻定位
    final created = DateTime.fromMillisecondsSinceEpoch(p.createdAt, isUtc: true);
    final loc = calendar.locate(created);
    return PredictionWindow.of(calendar, loc.tradeDate, loc.session, p.horizonType);
  }

  /// 缺少录入时快照的基准价：盘前 / 盘中 / 假日取前一交易日收盘，盘后取当日收盘。
  double? _baseFromBars(List<KBar> bars, PredictionWindow w, JournalEntry? e) {
    final ref = w.baseFromPrevClose
        ? TradeDate.format(calendar.previous(w.windowStart))
        : TradeDate.format(e == null ? calendar.previous(w.windowStart) : TradeDate.parse(e.tradeDate));
    for (final b in bars.reversed) {
      if (b.date.compareTo(ref) <= 0) return b.close;
    }
    return null;
  }
}
