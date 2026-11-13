import '../time/market_clock.dart';
import '../time/trading_session.dart';

/// A 股交易日历。
///
/// 权威数据来自 Tushare `trade_cal`（存于 trading_day 表）。表中没有的日期
/// 退化为"周一至周五开市"规则，保证离线或首次启动时也能工作。
class TradingCalendar {
  TradingCalendar([Map<String, bool> days = const {}])
      : _days = Map.unmodifiable(days);

  /// key: yyyyMMdd，value: 是否开市。
  final Map<String, bool> _days;

  /// 最多向前 / 向后搜索的自然日数，防止数据异常时死循环。
  static const int _maxScan = 60;

  bool get hasData => _days.isNotEmpty;

  bool isTradingDay(DateTime date) {
    final known = _days[TradeDate.format(date)];
    if (known != null) return known;
    return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
  }

  /// [date] 本身若是交易日则返回它，否则返回其后第一个交易日。
  DateTime onOrAfter(DateTime date) {
    var d = _dateOnly(date);
    for (var i = 0; i <= _maxScan; i++) {
      if (isTradingDay(d)) return d;
      d = d.add(const Duration(days: 1));
    }
    throw StateError('No trading day within $_maxScan days after $date');
  }

  /// [date] 之后（不含）的第一个交易日。
  DateTime next(DateTime date) =>
      onOrAfter(_dateOnly(date).add(const Duration(days: 1)));

  /// [date] 之前（不含）的最后一个交易日。
  DateTime previous(DateTime date) {
    var d = _dateOnly(date).subtract(const Duration(days: 1));
    for (var i = 0; i <= _maxScan; i++) {
      if (isTradingDay(d)) return d;
      d = d.subtract(const Duration(days: 1));
    }
    throw StateError('No trading day within $_maxScan days before $date');
  }

  /// T+N：以 [date] 所在交易日（非交易日取其后第一个交易日）为 T，向后数 N 个交易日。
  DateTime addTradingDays(DateTime date, int n) {
    if (n < 0) throw ArgumentError.value(n, 'n', 'must be >= 0');
    var d = onOrAfter(date);
    for (var i = 0; i < n; i++) {
      d = next(d);
    }
    return d;
  }

  /// 一个时刻所属的交易日与时段。
  ///
  /// 非交易日的记录归入"周末/假日复盘"，并关联到下一个交易日（spec 3.2.1）。
  ({DateTime tradeDate, TradingSession session}) locate(DateTime instant) {
    final date = MarketClock.marketDate(instant);
    if (isTradingDay(date)) {
      return (tradeDate: date, session: TradingSession.ofTradingDay(instant));
    }
    return (tradeDate: onOrAfter(date), session: TradingSession.holiday);
  }

  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}
