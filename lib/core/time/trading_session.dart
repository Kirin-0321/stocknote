import 'market_clock.dart';

/// 交易时段。日记条目按时段自动分组（spec 3.2.1）。
enum TradingSession {
  preMarket('pre', '盘前'),
  callAuction('auction', '集合竞价'),
  morning('morning', '早盘'),
  noonBreak('noon', '午间'),
  afternoon('afternoon', '午盘'),
  closingAuction('closing', '尾盘'),
  afterMarket('after', '盘后'),

  /// 非交易日（周末 / 节假日）的记录。
  holiday('holiday', '周末/假日复盘');

  const TradingSession(this.code, this.label);

  /// 存库用的稳定编码。
  final String code;
  final String label;

  static TradingSession fromCode(String code) =>
      values.firstWhere((s) => s.code == code,
          orElse: () => throw ArgumentError('Unknown session code: $code'));

  /// 交易日内按上海时间判断时段。非交易日请直接使用 [holiday]。
  static TradingSession ofTradingDay(DateTime instant) {
    final m = MarketClock.toMarket(instant);
    final minutes = m.hour * 60 + m.minute;
    if (minutes < _t(9, 15)) return preMarket;
    if (minutes < _t(9, 30)) return callAuction;
    if (minutes < _t(11, 30)) return morning;
    if (minutes < _t(13, 0)) return noonBreak;
    if (minutes < _t(14, 57)) return afternoon;
    if (minutes < _t(15, 0)) return closingAuction;
    return afterMarket;
  }

  static int _t(int h, int m) => h * 60 + m;

  /// 是否处于连续竞价或集合竞价（行情轮询需要的时段）。
  bool get isMarketOpen =>
      this == callAuction ||
      this == morning ||
      this == afternoon ||
      this == closingAuction;
}
