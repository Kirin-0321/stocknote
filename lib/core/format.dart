import 'time/market_clock.dart';

const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

String _two(int n) => n.toString().padLeft(2, '0');

/// 时间戳（UTC 毫秒）→ 上海时间 `HH:mm`。
String formatTime(int tsMs) {
  final m = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(tsMs, isUtc: true));
  return '${_two(m.hour)}:${_two(m.minute)}';
}

/// 时间戳 → `M月d日 HH:mm`。
String formatDateTime(int tsMs) {
  final m = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(tsMs, isUtc: true));
  return '${m.month}月${m.day}日 ${_two(m.hour)}:${_two(m.minute)}';
}

/// 日期 → `11月13日 周五`（跨年时带年份）。
String formatDateTitle(DateTime date, {DateTime? today}) {
  final sameYear = today == null || today.year == date.year;
  final prefix = sameYear ? '' : '${date.year}年';
  return '$prefix${date.month}月${date.day}日 ${_weekdays[date.weekday - 1]}';
}

/// yyyyMMdd → `2026年11月13日 周五`。
String formatTradeDate(String tradeDate) {
  final d = TradeDate.parse(tradeDate);
  return '${d.year}年${d.month}月${d.day}日 ${_weekdays[d.weekday - 1]}';
}
