import 'models.dart';

/// 数据源能力（spec 5.3）。每个能力可单独配置数据源优先级。
enum Capability {
  quotes('实时报价'),
  intraday('分时'),
  dailyKline('日 K'),
  breadth('涨跌家数'),
  limitStats('涨停跌停'),
  turnover('两市成交额'),
  sectorRank('板块排行'),
  sectorMembers('板块成分'),
  etfRank('ETF 排行'),
  instruments('代码表'),
  calendar('交易日历');

  const Capability(this.label);
  final String label;
}

enum SourceId {
  tushare('tushare', 'Tushare Pro'),
  eastmoney('eastmoney', '东方财富'),
  tencent('tencent', '腾讯财经');

  const SourceId(this.code, this.label);
  final String code;
  final String label;

  static SourceId? fromCode(String code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

/// 数据源不支持某个请求（如腾讯不支持板块代码），路由器会直接尝试下一个源，不计入失败。
class UnsupportedRequest implements Exception {
  const UnsupportedRequest(this.message);
  final String message;
  @override
  String toString() => 'UnsupportedRequest: $message';
}

class SourceError implements Exception {
  const SourceError(this.source, this.message);
  final SourceId source;
  final String message;
  @override
  String toString() => '${source.label}: $message';
}

/// 数据源基类。具体能力通过下列方法实现，未实现的抛 [UnsupportedRequest]。
abstract class MarketSource {
  SourceId get id;
  Set<Capability> get capabilities;

  /// 是否可用（如 Tushare 需要 token）。
  bool get isAvailable => true;

  Future<List<Quote>> quotes(List<String> codes) => _unsupported();
  Future<Intraday> intraday(String code) => _unsupported();

  /// [from]/[to] 为 yyyyMMdd（含）。
  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) =>
      _unsupported();
  Future<Breadth> breadth() => _unsupported();
  Future<LimitStats> limitStats(String tradeDate) => _unsupported();
  Future<Turnover> turnover() => _unsupported();
  Future<List<RankItem>> sectorRank(SectorKind kind, {required bool ascending, int limit = 10}) =>
      _unsupported();
  Future<List<RankItem>> sectorMembers(String sectorCode, {int limit = 50}) => _unsupported();
  Future<List<RankItem>> etfRank({int limit = 10}) => _unsupported();
  Future<List<InstrumentInfo>> instruments() => _unsupported();

  /// 返回 yyyyMMdd → 是否开市。
  Future<Map<String, bool>> calendar({required String from, required String to}) =>
      _unsupported();

  Future<T> _unsupported<T>() =>
      Future.error(UnsupportedRequest('${id.label} 不支持该请求'));
}
