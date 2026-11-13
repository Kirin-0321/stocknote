import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/market/tushare_source.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';

void main() {
  test('涨跌停幅度按板块区分', () {
    expect(TushareSource.limitRatio('600519.SH', '贵州茅台'), 0.10);
    expect(TushareSource.limitRatio('300750.SZ', '宁德时代'), 0.20);
    expect(TushareSource.limitRatio('688981.SH', '中芯国际'), 0.20);
    expect(TushareSource.limitRatio('920085.BJ', '森峰激光'), 0.30);
    expect(TushareSource.limitRatio('600001.SH', 'ST某某'), 0.05);
    expect(TushareSource.limitRatio('300001.SZ', 'ST创业'), 0.20);
  });

  test('由全市场快照计算涨跌家数与涨停 / 跌停 / 炸板', () {
    Map<String, dynamic> r(String code, double pre, double close, {double? high, String name = 'x'}) =>
        {'ts_code': code, 'name': name, 'pre_close': pre, 'close': close, 'high': high ?? close};
    final (b, l) = TushareSource.computeMarketStats([
      r('600000.SH', 10, 11), // 涨停 10%
      r('600001.SH', 10, 10.5, high: 11), // 炸板
      r('300001.SZ', 10, 12), // 创业板涨停 20%
      r('300002.SZ', 10, 11), // 创业板 +10%，未涨停
      r('600002.SH', 10, 9), // 跌停
      r('600003.SH', 10, 10), // 平
      r('600004.SH', 10, 0), // 停牌（close=0）忽略
      r('600005.SH', 3.33, 3.66), // 3.33*1.1=3.663 → 3.66 涨停
    ]);
    expect((b.up, b.down, b.flat), (5, 1, 1));
    expect((l.limitUp, l.limitDown, l.broken), (3, 1, 1));
  });

  test('名称拼音首字母', () {
    expect(initials('贵州茅台'), 'GZMT');
    expect(initials('沪深300ETF'), 'HS300ETF');
    expect(initials('智算中心（AIDC）'), 'ZSZXAIDC');
  });
}
