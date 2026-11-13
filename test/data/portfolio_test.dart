import 'dart:convert';

import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/ai/ai_settings.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/import/import_service.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/data/repo/trade_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';
import 'package:stocknote/domain/trade/portfolio.dart';
import 'package:stocknote/domain/trade/trade_rules.dart';

import '../helpers/fake_llm.dart';
import '../helpers/fake_market.dart';

int ts(int m, int d, [int h = 10, int mi = 0]) => MarketClock.fromMarket(2026, m, d, h, mi).millisecondsSinceEpoch;

/// 模拟券商持仓截图：名称、代码、持仓、成本（3 位小数）、现价、券商显示的浮动盈亏（用未截断成本算出）。
const samplePositions = [
  ('贵州茅台', '600519.SH', 100, 1500.123, 1420.50, -7962.31),
  ('沪深300ETF华泰柏瑞', '510300.SH', 20000, 4.1235, 4.012, -2230.04),
  ('证券ETF国泰', '512880.SH', 15000, 1.0567, 1.102, 679.51),
  ('创业板ETF易方达', '159915.SZ', 8000, 2.5013, 2.388, -906.37),
];

void main() {
  group('费用', () {
    const r = FeeRates(); // 万 2.5，最低 5 元，印花税 万 5，过户费 十万分之一
    test('股票：佣金最低 5 元，卖出收印花税，双向过户费', () {
      final buy = calcFees(r, TradeSide.buy, '600519.SH', 10000);
      expect((buy.commission, buy.stampTax, buy.transferFee), (5.0, 0.0, 0.1));
      final sell = calcFees(r, TradeSide.sell, '000001.SZ', 100000);
      expect((sell.commission, sell.stampTax, sell.transferFee), (25.0, 50.0, 1.0));
    });
    test('ETF 免印花税与过户费；代码补后缀', () {
      final f = calcFees(r, TradeSide.sell, '510300.SH', 100000);
      expect((f.commission, f.stampTax, f.transferFee), (25.0, 0.0, 0.0));
      expect(canonicalCode('600519'), '600519.SH');
      expect(canonicalCode('="000001"'), '000001.SZ');
      expect(canonicalCode('1282'), '001282.SZ', reason: 'Excel 丢失前导 0');
      expect(canonicalCode('sz159825'), '159825.SZ');
      expect(canonicalCode('920001'), '920001.BJ');
    });
  });

  group('持仓计算', () {
    late AppDatabase db;
    late TradeRepository repo;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = TradeRepository(db);
    });
    tearDown(() => db.close());

    Future<void> add(String code, TradeSide side, int t, double price, int qty, {double fee = 0, double? amount}) =>
        repo.add(TradeDraft(
            accountId: 'a', code: code, side: side, ts: t, price: price, qty: qty, amount: amount,
            fees: Fees(commission: fee)));

    test('移动加权平均 vs 摊薄成本；清仓形成一笔完整交易', () async {
      await add('600000.SH', TradeSide.buy, ts(11, 2), 10, 1000, fee: 5); // 成本 10005
      await add('600000.SH', TradeSide.buy, ts(11, 3), 12, 1000, fee: 5); // 成本 12005
      await add('600000.SH', TradeSide.sell, ts(11, 4), 13, 1000, fee: 10); // 净收 12990
      await add('600000.SH', TradeSide.dividend, ts(11, 5), 0, 0, amount: 100);
      var p = Portfolio.compute(await repo.all());
      final h = p.holdings['600000.SH']!;
      expect(h.qty, 1000);
      expect(h.avgCost, closeTo(11.005, 1e-9), reason: '(10005+12005)/2000');
      expect(h.realized, closeTo(12990 - 11005 + 100, 1e-6));
      expect(h.dilutedCost, closeTo((22010 - 12990 - 100) / 1000, 1e-9));
      // 两种算法总盈亏一致：已实现 + 浮动
      expect(h.realized + h.floating(12, CostMethod.movingAverage), closeTo(h.floating(12, CostMethod.diluted), 1e-6));
      expect(p.roundTrips, isEmpty);

      await add('600000.SH', TradeSide.sell, ts(11, 6), 11, 1000, fee: 10);
      p = Portfolio.compute(await repo.all());
      expect(p.open, isEmpty);
      final trip = p.roundTrips.single;
      expect(trip.pnl, closeTo(-22010 + 12990 + 100 + 10990, 1e-6));
      expect(trip.invested, 22010);
      expect(p.realized(CostMethod.movingAverage), closeTo(trip.pnl, 1e-6));
      expect(p.realized(CostMethod.diluted), closeTo(trip.pnl, 1e-6));
      final stats = TradeStats(p.roundTrips);
      expect((stats.count, stats.wins), (1, 1));
    });

    test('当日盈亏：昨日持有按昨收、今日买入按成交价；送转不改成本总额', () async {
      await add('000001.SZ', TradeSide.buy, ts(11, 12), 10, 1000);
      await add('000001.SZ', TradeSide.buy, ts(11, 13, 10), 10.5, 500);
      await add('000001.SZ', TradeSide.bonus, ts(11, 13, 9), 0, 300);
      final p = Portfolio.compute(await repo.all(), todayStart: ts(11, 13, 0));
      final h = p.holdings['000001.SZ']!;
      expect(h.qty, 1800);
      expect(h.basis, 15250);
      // 昨日 1000 + 送 300 按昨收 10.2 → 现价 10.8；今日买 500 @10.5
      expect(h.dayPnl(10.8, 10.2), closeTo(1300 * 0.6 + 500 * 0.3, 1e-6));
    });

    test('卖出超过持仓时标记流水不完整', () async {
      await add('600000.SH', TradeSide.buy, ts(11, 2), 10, 100);
      await add('600000.SH', TradeSide.sell, ts(11, 3), 11, 300);
      final h = Portfolio.compute(await repo.all()).holdings['600000.SH']!;
      expect(h.oversold, isTrue);
      expect(h.qty, 0);
    });

    test('持仓截图作为期初持仓：浮动盈亏与券商一致（误差来自成本价小数位）', () async {
      for (final (_, code, qty, cost, _, _) in samplePositions) {
        await add(code, TradeSide.init, ts(11, 13, 9, 0), cost, qty);
      }
      final p = Portfolio.compute(await repo.all(), todayStart: ts(11, 13, 0));
      var mv = 0.0;
      for (final (name, code, _, _, price, brokerPnl) in samplePositions) {
        final h = p.holdings[code]!;
        mv += h.marketValue(price);
        expect(h.floating(price, CostMethod.diluted), closeTo(brokerPnl, h.qty * 0.0005 + 0.01), reason: name);
        expect(h.dayPnl(price, price), 0, reason: '期初持仓不算今日买入');
      }
      expect(mv, closeTo(142050 + 80240 + 16530 + 19104, 0.01));
    });
  });

  group('表格导入', () {
    late AppDatabase db;
    late TradeImportService svc;
    late Account account;
    late FakeSource source;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      source = FakeSource(SourceId.tushare);
      svc = TradeImportService(
        trades: TradeRepository(db),
        mappings: ColumnMappingRepository(db),
        instruments: InstrumentRepository(db),
        market: MarketService(MarketRouter([source])),
        aiConfig: AiConfigRepository(SettingsStore(db), MemorySecretStore(), envDeepseekKey: 'sk'),
        llmFactory: (_) => FakeLlm(['{"date":0,"secCode":1,"side":2,"qty":3,"price":4}']),
      );
      account = await AccountRepository(db).ensureDefault();
    });
    tearDown(() => db.close());

    // 券商常见导出：GBK 编码、制表符分隔、扩展名 .xls，含非交易流水
    const deliveryNote = '成交日期\t成交时间\t证券代码\t证券名称\t操作\t成交数量\t成交均价\t成交金额\t手续费\t印花税\t过户费\t发生金额\n'
        '20261103\t09:35:12\t="600000"\t浦发银行\t证券买入\t1000\t10.000\t10000.00\t5.00\t0.00\t0.10\t-10005.10\n'
        '20261104\t14:20:00\t="159825"\t农业ETF\t证券买入\t20000\t0.720\t14400.00\t5.00\t0.00\t0.00\t-14405.00\n'
        '20261105\t10:01:30\t="600000"\t浦发银行\t证券卖出\t400\t11.000\t4400.00\t5.00\t2.20\t0.04\t4392.76\n'
        '20261106\t\t\t\t银行转证券\t0\t0\t0\t0\t0\t0\t50000.00\n'
        '20261110\t15:00:00\t="600000"\t浦发银行\t红利入账\t0\t0\t60.00\t0\t0\t0\t60.00\n';

    test('交割单导入后持仓与盈亏正确（M5 验收）；再次导入全部判为重复', () async {
      final bytes = gbk.encode(deliveryNote);
      final p = await svc.previewTable(bytes, '交割单.xls', account);
      expect(p.layout.complete, isTrue);
      expect(p.parsed.where((r) => r.draft != null), hasLength(4));
      expect(p.parsed.where((r) => r.skipped != null).single.skipped, '银行转证券');
      final sell = p.parsed.firstWhere((r) => r.draft?.side == TradeSide.sell).draft!;
      expect((sell.code, sell.qty, sell.price, sell.fees.stampTax), ('600000.SH', 400, 11.0, 2.2));
      expect(sell.ts, ts(11, 5, 10, 1) + 30000);
      await svc.commitTable(p);

      final pf = Portfolio.compute(await TradeRepository(db).all());
      final pufa = pf.holdings['600000.SH']!;
      expect(pufa.qty, 600);
      expect(pufa.avgCost, closeTo(10005.10 / 1000, 1e-9));
      expect(pufa.realized, closeTo(4392.76 - 400 * 10.0051 + 60, 1e-6));
      expect(pufa.dilutedCost, closeTo((10005.10 - 4392.76 - 60) / 600, 1e-9));
      expect(pf.holdings['159825.SZ']!.qty, 20000);
      expect(pf.holdings['159825.SZ']!.avgCost, closeTo(14405 / 20000, 1e-9));

      final again = await svc.previewTable(bytes, '交割单.xls', account);
      expect(again.mappingName, '交割单.xls', reason: '复用保存的映射');
      expect(again.parsed.where((r) => r.draft != null).every((r) => r.duplicate && !r.selected), isTrue);
    });

    test('UTF-8 CSV（带 BOM、引号、千分位），无费用列时按账户费率计算', () async {
      const csv = '﻿发生日期,证券代码,证券名称,买卖标志,成交价格,成交数量,成交金额\n'
          '2026-11-03 09:31:00,"600519",贵州茅台,买入,"1,420.00",100,"142,000.00"\n';
      final p = await svc.previewTable(_utf8(csv), 'a.csv', account);
      final d = p.parsed.single.draft!;
      expect((d.code, d.price, d.qty, d.amount), ('600519.SH', 1420.0, 100, 142000.0));
      expect(d.ts, ts(11, 3, 9, 31));
      expect(d.fees.commission, 35.5);
      expect(d.fees.transferFee, 1.42);
    });

    test('xlsx 读取', () async {
      final book = Excel.createExcel();
      final sheet = book[book.getDefaultSheet()!];
      sheet.appendRow([TextCellValue('成交日期'), TextCellValue('证券代码'), TextCellValue('操作'),
        TextCellValue('成交数量'), TextCellValue('成交价格')]);
      sheet.appendRow([IntCellValue(20261103), TextCellValue('510300'), TextCellValue('卖出'),
        IntCellValue(1000), DoubleCellValue(4.123)]);
      final p = await svc.previewTable(book.encode()!, 'b.xlsx', account);
      final d = p.parsed.single.draft!;
      expect((d.code, d.side, d.qty, d.price), ('510300.SH', TradeSide.sell, 1000, 4.123));
      expect(d.fees.stampTax, 0, reason: 'ETF');
    });

    test('未知表头：自动识别不全，AI 推荐映射后可解析', () async {
      const csv = 'D,C,S,Q,P\n20261103,600000,买,100,10\n';
      final p = await svc.previewTable(_utf8(csv), 'c.csv', account);
      expect(p.layout.complete, isFalse);
      final m = await svc.suggestMapping(p);
      p.layout = p.layout.withMapping(m);
      expect(p.layout.complete, isTrue);
      await svc.reparse(p, account);
      expect(p.parsed.single.draft!.code, '600000.SH');
    });
  });

  test('截图识别：持仓转为期初持仓，名称按代码表与现价匹配', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final source = FakeSource(SourceId.tushare)
      ..quoteOverride = (c) => switch (c) {
            '159825.SZ' => const Quote(code: '159825.SZ', name: '富国中证农业主题ETF', price: 0.730, preClose: 0.72),
            '516810.SH' => const Quote(code: '516810.SH', name: '华夏中证农业主题ETF', price: 0.95, preClose: 0.95),
            _ => FakeSource.quote(c, 1, 1),
          };
    await InstrumentRepository(db).upsertAll(const [
      InstrumentInfo(code: '600519.SH', name: '贵州茅台', type: InstrumentType.stock),
      InstrumentInfo(code: '159825.SZ', name: '富国中证农业主题ETF', type: InstrumentType.etf),
      InstrumentInfo(code: '159826.SZ', name: '富国中证农业主题联接', type: InstrumentType.etf),
      InstrumentInfo(code: '516810.SH', name: '华夏中证农业主题ETF', type: InstrumentType.etf),
    ]);
    final llm = FakeLlm(['''{"kind":"positions","items":[
      {"name":"贵州茅台","code":"","qty":100,"cost":1500.123,"price":1420.5},
      {"name":"农业ETF富国","code":"","qty":20000,"cost":0.72,"price":0.73},
      {"name":"不存在ETF某某","code":"","qty":1,"cost":1,"price":1}]}''']);
    final svc = TradeImportService(
      trades: TradeRepository(db),
      mappings: ColumnMappingRepository(db),
      instruments: InstrumentRepository(db),
      market: MarketService(MarketRouter([source])),
      aiConfig: AiConfigRepository(SettingsStore(db), MemorySecretStore(), envDeepseekKey: 'sk'),
      llmFactory: (_) => llm,
      now: () => MarketClock.fromMarket(2026, 11, 13, 16, 0),
    );
    final account = await AccountRepository(db).ensureDefault();
    final p = await svc.previewImage([1, 2, 3], 'image/png', account);
    expect(llm.calls.single.single.images.single.mime, 'image/png');
    expect(p.kind, 'positions');
    final ok = p.rows.where((r) => r.draft != null).map((r) => r.draft!).toList();
    expect(ok.map((d) => (d.code, d.side, d.qty, d.price)), [
      ('600519.SH', TradeSide.init, 100, 1500.123),
      ('159825.SZ', TradeSide.init, 20000, 0.72),
    ]);
    expect(p.rows.last.error, contains('不存在ETF某某'));
    await svc.commitImage(p);
    expect(await TradeRepository(db).all(), hasLength(2));
    await db.close();
  });
}

List<int> _utf8(String s) => const Utf8Codec().encode(s);
