import 'dart:async';

import '../db/app_database.dart';
import '../repo/market_snapshot_repository.dart';
import 'market_service.dart';
import 'models.dart';

/// 记录日记时抓取当时的行情快照（spec 3.2.1）。
///
/// 优先复用看板最近一次的数据（60 秒内），否则现拉指数报价；关联标的单独拉报价。
/// 任何失败都不影响日记保存，返回 null 表示"快照缺失"。
class SnapshotService {
  SnapshotService({
    required this.market,
    required this.repo,
    required this.latestOverview,
    this.indexCodes = defaultBoardIndices,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MarketService market;
  final MarketSnapshotRepository repo;
  final MarketOverview? Function() latestOverview;
  final List<String> indexCodes;
  final DateTime Function() _now;

  static const freshness = Duration(seconds: 60);
  static const fetchTimeout = Duration(seconds: 4);

  Future<MarketSnapshot?> capture(List<String> instrumentCodes) async {
    final now = _now();
    var overview = latestOverview();
    if (overview == null || now.difference(overview.fetchedAt) > freshness) {
      overview = null;
    }

    final targets = instrumentCodes.where((c) => c.contains('.')).toList();
    final toFetch = <String>{
      if (overview == null || overview.indices.isEmpty) ...indexCodes,
      ...targets,
    }.toList();

    var fetched = <Quote>[];
    if (toFetch.isNotEmpty) {
      try {
        fetched = await market.quotes(toFetch).timeout(fetchTimeout);
      } catch (_) {
        // 网络失败：仍保存已有部分
      }
    }
    final byCode = {for (final q in fetched) q.code: q};

    final indices = overview != null && overview.indices.isNotEmpty
        ? overview.indicesJson()
        : {for (final c in indexCodes) if (byCode[c] case final q?) c: q.toSnapshotJson()};
    final instruments = {
      for (final c in targets) if (byCode[c] case final q?) c: q.toSnapshotJson(),
    };
    if (indices.isEmpty && instruments.isEmpty) return null;

    return repo.create(
      ts: now,
      indices: indices,
      breadth: overview?.breadth?.toJson(),
      turnover: overview?.turnover?.today,
      extra: {
        if (instruments.isNotEmpty) 'instruments': instruments,
        if (overview?.limits != null) 'limits': overview!.limits!.toJson(),
      },
    );
  }
}
