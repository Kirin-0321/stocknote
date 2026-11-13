import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/market/code_util.dart';
import 'package:stocknote/data/market/eastmoney_source.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/tencent_source.dart';
import 'package:stocknote/features/market/widgets/charts.dart';

void main() {
  group('代码转换', () {
    test('6 位代码推断交易所', () {
      expect(Codes.fromSymbol('600519'), '600519.SH');
      expect(Codes.fromSymbol('510300'), '510300.SH');
      expect(Codes.fromSymbol('000001'), '000001.SZ');
      expect(Codes.fromSymbol('159915'), '159915.SZ');
      expect(Codes.fromSymbol('920085'), '920085.BJ');
      expect(Codes.fromSymbol('bk1036'), 'BK1036.EM');
    });

    test('东方财富 secid 与腾讯代码', () {
      expect(Codes.toEmSecid('000001.SH'), '1.000001');
      expect(Codes.toEmSecid('399001.SZ'), '0.399001');
      expect(Codes.toEmSecid('BK1036.EM'), '90.BK1036');
      expect(Codes.toEmSecid('885338.TI'), isNull);
      expect(Codes.fromEm(1, '000001'), '000001.SH');
      expect(Codes.fromEm(0, '899050'), '899050.BJ');
      expect(Codes.toTencent('600519.SH'), 'sh600519');
      expect(Codes.fromTencent('sz399001'), '399001.SZ');
      expect(Codes.toTencent('BK1036.EM'), isNull);
    });

    test('类型推断', () {
      expect(Codes.guessType('000001.SH'), InstrumentType.marketIndex);
      expect(Codes.guessType('000001.SZ'), InstrumentType.stock);
      expect(Codes.guessType('510300.SH'), InstrumentType.etf);
      expect(Codes.guessType('BK1036.EM'), InstrumentType.sector);
    });
  });

  test('腾讯报价解析', () {
    final fields = List.filled(50, '');
    fields
      ..[1] = '上证指数'
      ..[2] = '000001'
      ..[3] = '3663.71'
      ..[4] = '3655.83'
      ..[5] = '3658.72'
      ..[30] = '20261113113500'
      ..[33] = '3669.44'
      ..[34] = '3652.28'
      ..[36] = '260160104'
      ..[37] = '44899708';
    final q = TencentSource.parseQuotes('v_sh000001="${fields.join('~')}";\n').single;
    expect(q.code, '000001.SH');
    expect(q.name, '上证指数');
    expect(q.price, 3663.71);
    expect(q.changePct, closeTo(0.2155, 0.001));
    expect(q.amount, closeTo(448997080000, 1));
    expect(q.time, DateTime.utc(2026, 11, 13, 3, 35));
  });

  test('两市成交额：今日累计 vs 昨日同时段', () {
    final rows = [
      for (final l in [
        '2026-11-12 09:31,0,10,0,0,0,100,0',
        '2026-11-12 09:32,0,10,0,0,0,200,0',
        '2026-11-12 09:33,0,10,0,0,0,300,0',
        '2026-11-13 09:31,0,10,0,0,0,150,0',
        '2026-11-13 09:32,0,10,0,0,0,250,0',
      ])
        TrendRow.parse(l, 0),
    ];
    final t = EastmoneySource.computeTurnover(rows);
    expect(t.today, 400);
    expect(t.yesterdaySameTime, 300);
    expect(t.yesterdayTotal, 600);
    expect(t.changePct, closeTo(33.33, 0.01));
  });

  test('腾讯板块排行解析', () {
    final items = TencentSource.parseSectorRank({
      'code': 0,
      'data': {
        'rank_list': [
          {
            'code': 'pt01801766',
            'name': '影视院线',
            'zdf': '5.09',
            'zxj': '1326.04',
            'turnover': '1508357',
            'lzg': {'name': '幸福蓝海', 'zdf': '20.01'},
          }
        ]
      }
    });
    final s = items.single;
    expect(s.code, '01801766.PT');
    expect(s.changePct, 5.09);
    expect(s.leaderName, '幸福蓝海');
    expect(s.amount, 15083570000);
    expect(Codes.toTencent(s.code), 'pt01801766');
    expect(Codes.guessType(s.code), InstrumentType.sector);
  });

  test('分时分钟序号', () {
    expect(minuteIndex('0925'), isNull);
    expect(minuteIndex('0930'), 0);
    expect(minuteIndex('1130'), 120);
    expect(minuteIndex('1301'), 121);
    expect(minuteIndex('1500'), 240);
  });

  test('LimitStats 炸板率', () {
    expect(const LimitStats(limitUp: 60, limitDown: 1, broken: 20).brokenRate, 25);
    expect(const LimitStats(limitUp: 0, limitDown: 0, broken: 0).brokenRate, isNull);
  });
}
