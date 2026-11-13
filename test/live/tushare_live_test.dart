@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/tushare_source.dart';

/// 真实调用 Tushare 的冒烟测试。需要环境变量 TUSHARE_TOKEN，否则跳过。
/// 运行：flutter test test/live --tags live
void main() {
  final token = Platform.environment['TUSHARE_TOKEN'];
  final skip = token == null || token.isEmpty ? '未设置 TUSHARE_TOKEN' : null;
  late TushareSource ts;
  setUp(() => ts = TushareSource(token));

  test('实时报价：个股 / 指数 / ETF', () async {
    final q = await ts.quotes(['600519.SH', '000001.SH', '510300.SH', 'BK1036.EM']);
    expect(q.map((e) => e.code), containsAll(['600519.SH', '000001.SH', '510300.SH']));
    expect(q.every((e) => e.price > 0), isTrue);
  }, skip: skip);

  test('全市场宽度与涨跌停', () async {
    final b = await ts.breadth();
    final l = await ts.limitStats('');
    // ignore: avoid_print
    print('breadth up=${b.up} down=${b.down} flat=${b.flat}; limit up=${l.limitUp} down=${l.limitDown} broken=${l.broken}');
    expect(b.total, greaterThan(4000));
  }, skip: skip);

  test('成交额、ETF 排行、板块排行与成分', () async {
    final t = await ts.turnover();
    final etf = await ts.etfRank();
    final rank = await ts.sectorRank(SectorKind.industry, ascending: false);
    final members = await ts.sectorMembers('BK1036.EM', limit: 5);
    // ignore: avoid_print
    print('turnover today=${t.today / 1e8}亿 yesterday=${(t.yesterdayTotal ?? 0) / 1e8}亿; '
        'etf top=${etf.first.name}; sector top=${rank.first.name}; member top=${members.first.name}');
    expect(t.today, greaterThan(1e11));
    expect(etf, hasLength(10));
    expect(rank, isNotEmpty);
    expect(members, isNotEmpty);
  }, skip: skip);

  test('板块日 K', () async {
    final bars = await ts.dailyKline('BK1036.EM', from: '20261101');
    expect(bars, isNotEmpty);
  }, skip: skip);
}
