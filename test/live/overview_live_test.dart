@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/market/eastmoney_source.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/tencent_source.dart';
import 'package:stocknote/data/market/tushare_source.dart';

/// 用真实数据源跑一次完整看板刷新，打印各部分来源与错误。
void main() {
  final token = Platform.environment['TUSHARE_TOKEN'];
  test('完整看板刷新', () async {
    final router = MarketRouter([TushareSource(token), EastmoneySource(), TencentSource()]);
    final o = await MarketService(router).overview(defaultBoardIndices, '20261113');
    // ignore: avoid_print
    print('indices=${o.indices.length} breadth=${o.breadth?.toJson()} limits=${o.limits?.toJson()} '
        'turnover=${o.turnover?.today} industry=${o.industryTop.length} etf=${o.hotEtfs.length}');
    // ignore: avoid_print
    print('errors=${o.errors}');
    for (final e in router.health.entries) {
      // ignore: avoid_print
      print('${e.key.label}: ok=${e.value.successes} fail=${e.value.failures} last=${e.value.lastError}');
    }
    expect(o.indices, isNotEmpty);
  }, skip: token == null ? '未设置 TUSHARE_TOKEN' : null, timeout: const Timeout(Duration(minutes: 2)));
}
