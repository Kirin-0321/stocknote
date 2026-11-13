import 'dart:convert';

import 'package:dio/dio.dart';

import 'code_util.dart';
import 'http.dart';
import 'models.dart';
import 'sources.dart';

/// Tushare Pro（需 token）。代码表、交易日历、日 K 的权威来源（spec 5.3）。
class TushareSource extends MarketSource {
  TushareSource(this.token, {Dio? dio}) : _dio = dio ?? createMarketDio();

  final String? token;
  final Dio _dio;

  @override
  SourceId get id => SourceId.tushare;

  @override
  bool get isAvailable => token != null && token!.isNotEmpty;

  @override
  Set<Capability> get capabilities =>
      {Capability.dailyKline, Capability.instruments, Capability.calendar};

  /// 调用 Tushare 接口，返回字段名 → 值 的行列表。
  Future<List<Map<String, dynamic>>> call(String api,
      {Map<String, dynamic> params = const {}, String fields = ''}) async {
    if (!isAvailable) throw SourceError(id, '未配置 token');
    final res = await _dio.post<List<int>>(
      'https://api.tushare.pro',
      data: jsonEncode({'api_name': api, 'token': token, 'params': params, 'fields': fields}),
      options: Options(contentType: 'application/json', receiveTimeout: const Duration(seconds: 30)),
    );
    final json = decodeJsonBytes(res.data!) as Map<String, dynamic>;
    if (json['code'] != 0) throw SourceError(id, '$api: ${json['msg']}');
    final data = json['data'] as Map<String, dynamic>;
    final names = (data['fields'] as List).cast<String>();
    return [
      for (final row in (data['items'] as List).cast<List>())
        {for (var i = 0; i < names.length; i++) names[i]: row[i]},
    ];
  }

  @override
  Future<Map<String, bool>> calendar({required String from, required String to}) async {
    final rows = await call('trade_cal',
        params: {'exchange': 'SSE', 'start_date': from, 'end_date': to},
        fields: 'cal_date,is_open');
    return {for (final r in rows) r['cal_date'] as String: toInt(r['is_open']) == 1};
  }

  /// 个股 + 场内基金（ETF/LOF）+ 沪深主要指数 + 同花顺行业/概念板块。
  @override
  Future<List<InstrumentInfo>> instruments() async {
    final out = <InstrumentInfo>[];
    final stocks = await call('stock_basic',
        params: {'list_status': 'L'}, fields: 'ts_code,name,cnspell,exchange,list_date');
    out.addAll(stocks.map((r) => InstrumentInfo(
          code: r['ts_code'] as String,
          name: r['name'] as String,
          type: InstrumentType.stock,
          exchange: Codes.exchange(r['ts_code'] as String),
          pinyin: r['cnspell'] as String?,
          listDate: r['list_date'] as String?,
        )));
    final funds = await call('fund_basic',
        params: {'market': 'E', 'status': 'L'}, fields: 'ts_code,name,list_date');
    out.addAll(funds.map((r) => InstrumentInfo(
          code: r['ts_code'] as String,
          name: r['name'] as String,
          type: InstrumentType.etf,
          exchange: Codes.exchange(r['ts_code'] as String),
          listDate: r['list_date'] as String?,
        )));
    for (final market in ['SSE', 'SZSE']) {
      final idx = await call('index_basic', params: {'market': market}, fields: 'ts_code,name');
      out.addAll(idx.map((r) => InstrumentInfo(
            code: r['ts_code'] as String,
            name: r['name'] as String,
            type: InstrumentType.marketIndex,
            exchange: Codes.exchange(r['ts_code'] as String),
          )));
    }
    return out;
  }

  @override
  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) async {
    final api = switch (Codes.guessType(code)) {
      InstrumentType.marketIndex => 'index_daily',
      InstrumentType.etf => 'fund_daily',
      InstrumentType.sector when Codes.isThsSector(code) => 'ths_daily',
      InstrumentType.sector => throw const UnsupportedRequest('Tushare 仅支持同花顺板块'),
      InstrumentType.stock => 'daily',
    };
    final rows = await call(api, params: {
      'ts_code': code,
      'start_date': from,
      'end_date': ?to,
    }, fields: 'trade_date,open,high,low,close,vol,amount');
    final bars = [
      for (final r in rows)
        KBar(
          date: r['trade_date'] as String,
          open: toNum(r['open'])!,
          high: toNum(r['high'])!,
          low: toNum(r['low'])!,
          close: toNum(r['close'])!,
          // Tushare 日线：vol 单位手（指数为股），amount 单位千元
          volume: toNum(r['vol']),
          amount: toNum(r['amount']) == null ? null : toNum(r['amount'])! * 1000,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return bars;
  }
}

