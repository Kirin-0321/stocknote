import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/market/tencent_source.dart';

void main() {
  // 腾讯 5 日分时：新到旧，每行 "HHMM 价格 累计量 累计额"
  final days = [
    {
      'date': '20261116',
      'data': ['0930 3611.54 4320688 5433472579.20', '1030 3600 100 200000000000', '1130 3620 277036290 421756737368'],
    },
    {
      'date': '20261113',
      'data': [
        '0930 3658.72 4180629 5518513830.20',
        '1030 3650 1 250000000000',
        '1130 3640 1 400000000000',
        '1301 3641 1 410000000000',
        '1430 3635 1 650000000000',
        '1500 3634.35 472293657 770614169983.60',
      ],
    },
  ];

  double? at(int hhmm, {String today = '20261116'}) =>
      TencentSource.previousSameTimeAmount(days, today, hhmm);

  test('盘中取前一交易日同一时刻（不晚于该分钟的最后一行）', () {
    expect(at(1030), 250000000000);
    expect(at(1045), 250000000000);
    expect(at(1435), 650000000000);
  });

  test('午休按 11:30，收盘后按 15:00，盘前没有可比时段', () {
    expect(at(1200), 400000000000);
    expect(at(1600), 770614169983.60);
    expect(at(915), isNull);
  });

  test('今天休市：对比最近两个交易日的全天', () {
    expect(at(1000, today: '20261117'), 770614169983.60);
  });
}
