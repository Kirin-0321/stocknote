import 'dart:async';

import 'market_router.dart';
import 'models.dart';
import 'sources.dart';
import 'tencent_source.dart';

/// 看板一次刷新的结果。各部分独立获取，单项失败不影响其他部分。
class MarketOverview {
  const MarketOverview({
    required this.fetchedAt,
    this.indices = const [],
    this.breadth,
    this.limits,
    this.turnover,
    this.industryTop = const [],
    this.industryBottom = const [],
    this.conceptTop = const [],
    this.conceptBottom = const [],
    this.hotEtfs = const [],
    this.errors = const {},
  });

  final DateTime fetchedAt;
  final List<Quote> indices;
  final Breadth? breadth;
  final LimitStats? limits;
  final Turnover? turnover;
  final List<RankItem> industryTop;
  final List<RankItem> industryBottom;
  final List<RankItem> conceptTop;
  final List<RankItem> conceptBottom;
  final List<RankItem> hotEtfs;

  /// 部分名 → 错误信息
  final Map<String, String> errors;

  /// 用新结果覆盖，新结果中失败的部分保留旧值（避免闪烁）。
  MarketOverview mergeOnto(MarketOverview? old) {
    if (old == null) return this;
    return MarketOverview(
      fetchedAt: fetchedAt,
      indices: indices.isNotEmpty ? indices : old.indices,
      breadth: breadth ?? old.breadth,
      limits: limits ?? old.limits,
      turnover: turnover ?? old.turnover,
      industryTop: industryTop.isNotEmpty ? industryTop : old.industryTop,
      industryBottom: industryBottom.isNotEmpty ? industryBottom : old.industryBottom,
      conceptTop: conceptTop.isNotEmpty ? conceptTop : old.conceptTop,
      conceptBottom: conceptBottom.isNotEmpty ? conceptBottom : old.conceptBottom,
      hotEtfs: hotEtfs.isNotEmpty ? hotEtfs : old.hotEtfs,
      errors: errors,
    );
  }

  /// 写入行情快照的 JSON（spec 3.2.1）。
  Map<String, dynamic> indicesJson() =>
      {for (final q in indices) q.code: q.toSnapshotJson()};
}

/// 面向 UI 的行情服务。
class MarketService {
  MarketService(this.router, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  final MarketRouter router;

  /// 报价。首选源未覆盖的代码（如 Tushare 不支持板块）再交给下一个源补齐。
  Future<List<Quote>> quotes(List<String> codes) async {
    final first = await router.call(Capability.quotes, (s) => s.quotes(codes));
    final got = {for (final q in first) q.code};
    final missing = codes.where((c) => !got.contains(c)).toList();
    if (missing.isEmpty || missing.length == codes.length) return first;
    try {
      final rest = await router.call(Capability.quotes, (s) async {
        final r = await s.quotes(missing);
        if (r.isEmpty) throw const UnsupportedRequest('无数据');
        return r;
      });
      return [...first, ...rest];
    } catch (_) {
      return first;
    }
  }

  Future<Intraday> intraday(String code) =>
      router.call(Capability.intraday, (s) => s.intraday(code));

  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) =>
      router.call(Capability.dailyKline, (s) => s.dailyKline(code, from: from, to: to));

  Future<List<RankItem>> sectorMembers(String code) =>
      router.call(Capability.sectorMembers, (s) => s.sectorMembers(code));

  /// 只取指数（高频刷新）。
  Future<MarketOverview> indicesOnly(List<String> indexCodes) async {
    final errors = <String, String>{};
    final idx = await _try('indices', errors, () => quotes(indexCodes));
    return MarketOverview(
      fetchedAt: DateTime.now(),
      indices: _ordered(idx ?? const [], indexCodes),
      errors: errors,
    );
  }

  /// Tushare 没有昨日同一时刻的累计成交额，用腾讯 5 日分时补齐（失败则保持为空）。
  Future<Turnover?> _withPreviousSameTime(Turnover? t) async {
    if (t == null || t.yesterdaySameTime != null) return t;
    final tencent = router.sources.whereType<TencentSource>().firstOrNull;
    if (tencent == null) return t;
    try {
      final prev = await tencent.previousSameTimeTurnover(_now()).timeout(const Duration(seconds: 6));
      return prev == null ? t : Turnover(today: t.today, yesterdaySameTime: prev, yesterdayTotal: t.yesterdayTotal);
    } catch (_) {
      return t;
    }
  }

  /// 完整看板（低频刷新）。请求串行执行，降低被限流的概率。
  Future<MarketOverview> overview(List<String> indexCodes, String tradeDate) async {
    final errors = <String, String>{};
    final idx = await _try('indices', errors, () => quotes(indexCodes));
    final breadth = await _try(
        'breadth', errors, () => router.call(Capability.breadth, (s) => s.breadth()));
    final limits = await _try('limits', errors,
        () => router.call(Capability.limitStats, (s) => s.limitStats(tradeDate)));
    var turnover = await _try(
        'turnover', errors, () => router.call(Capability.turnover, (s) => s.turnover()));
    turnover = await _withPreviousSameTime(turnover);
    Future<List<RankItem>?> rank(String key, SectorKind k, bool asc) => _try(key, errors,
        () => router.call(Capability.sectorRank, (s) => s.sectorRank(k, ascending: asc)));
    final it = await rank('industry', SectorKind.industry, false);
    final ib = await rank('industry', SectorKind.industry, true);
    final ct = await rank('concept', SectorKind.concept, false);
    final cb = await rank('concept', SectorKind.concept, true);
    final etfs = await _try(
        'etf', errors, () => router.call(Capability.etfRank, (s) => s.etfRank()));
    return MarketOverview(
      fetchedAt: DateTime.now(),
      indices: _ordered(idx ?? const [], indexCodes),
      breadth: breadth,
      limits: limits,
      turnover: turnover,
      industryTop: it ?? const [],
      industryBottom: ib ?? const [],
      conceptTop: ct ?? const [],
      conceptBottom: cb ?? const [],
      hotEtfs: etfs ?? const [],
      errors: errors,
    );
  }

  static List<Quote> _ordered(List<Quote> quotes, List<String> order) {
    final byCode = {for (final q in quotes) q.code: q};
    return [for (final c in order) ?byCode[c]];
  }

  static Future<T?> _try<T>(
      String key, Map<String, String> errors, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      errors[key] = e.toString();
      return null;
    }
  }
}
