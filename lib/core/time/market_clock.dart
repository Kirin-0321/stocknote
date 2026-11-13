/// A 股市场时间工具。
///
/// 数据库统一存 UTC 毫秒；业务判断（时段、交易日）一律按 Asia/Shanghai 墙上时间。
/// 中国无夏令时，固定 UTC+8，避免引入时区库。
class MarketClock {
  MarketClock._();

  static const Duration offset = Duration(hours: 8);

  /// 把任意时刻转换为上海墙上时间。返回值是一个 `isUtc == true` 的 DateTime，
  /// 其年月日时分秒字段等于上海当地时间（仅用于读取字段，不要再当作真实 UTC 使用）。
  static DateTime toMarket(DateTime instant) => instant.toUtc().add(offset);

  /// 上海墙上时间 → 真实时刻（UTC）。
  static DateTime fromMarket(int year, int month, int day,
          [int hour = 0, int minute = 0, int second = 0]) =>
      DateTime.utc(year, month, day, hour, minute, second).subtract(offset);

  /// 上海当地日期（时分秒归零），`isUtc == true`。
  static DateTime marketDate(DateTime instant) {
    final m = toMarket(instant);
    return DateTime.utc(m.year, m.month, m.day);
  }
}

/// 交易日期字符串，格式 `yyyyMMdd`（与 Tushare 一致），便于存储与比较。
class TradeDate {
  TradeDate._();

  static String format(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  static DateTime parse(String s) {
    if (s.length != 8) {
      throw FormatException('Invalid trade date: $s');
    }
    return DateTime.utc(
      int.parse(s.substring(0, 4)),
      int.parse(s.substring(4, 6)),
      int.parse(s.substring(6, 8)),
    );
  }
}
