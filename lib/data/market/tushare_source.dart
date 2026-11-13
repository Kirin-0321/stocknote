import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/time/market_clock.dart';
import 'code_util.dart';
import 'http.dart';
import 'models.dart';
import 'sources.dart';

/// Tushare Pro（需 token），默认首选数据源（spec 5.3）。
///
/// - 实时：rt_k（个股，支持通配符拉全市场）、rt_idx_k（指数）、rt_etf_k（ETF）
/// - 由全市场实时行情计算：涨跌家数、涨停 / 跌停 / 炸板
/// - 板块：东财板块 dc_index / dc_member / dc_daily（代码与东方财富 BK 一致，规范代码 `BKxxxx.EM`）
/// - 基础：trade_cal、stock_basic、fund_basic、index_basic、日线
/// - 不提供：当日分时、板块实时排行（dc_index 为盘后数据，仅作兜底）
class TushareSource extends MarketSource {
  TushareSource(this.token, {Dio? dio, DateTime Function()? now})
      : _dio = dio ?? createMarketDio(),
        _now = now ?? DateTime.now;

  final String? token;
  final Dio _dio;
  final DateTime Function() _now;

  @override
  SourceId get id => SourceId.tushare;

  @override
  bool get isAvailable => token != null && token!.isNotEmpty;

  @override
  Set<Capability> get capabilities => {
        Capability.quotes,
        Capability.dailyKline,
        Capability.breadth,
        Capability.limitStats,
        Capability.turnover,
        Capability.sectorRank,
        Capability.sectorMembers,
        Capability.etfRank,
        Capability.instruments,
        Capability.calendar,
      };

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

  // ───────────── 规范代码 ↔ Tushare 代码 ─────────────

  static String _toTs(String code) =>
      Codes.isEmSector(code) ? '${Codes.symbol(code)}.DC' : code;

  static String _fromTs(String tsCode) =>
      tsCode.endsWith('.DC') ? '${Codes.symbol(tsCode)}.EM' : tsCode;

  // ───────────── 交易日 ─────────────

  List<String>? _openDays;
  DateTime? _openDaysAt;

  /// 最近的若干个开市日（倒序，含今天若今天开市）。
  Future<List<String>> _recentOpenDays() async {
    final now = _now();
    if (_openDays != null && now.difference(_openDaysAt!) < const Duration(hours: 6)) {
      return _openDays!;
    }
    final today = MarketClock.marketDate(now);
    final cal = await calendar(
        from: TradeDate.format(today.subtract(const Duration(days: 20))),
        to: TradeDate.format(today));
    _openDays = (cal.entries.where((e) => e.value).map((e) => e.key).toList()..sort())
        .reversed
        .toList();
    _openDaysAt = now;
    return _openDays!;
  }

  /// 依次尝试最近的开市日，返回第一个有数据的结果（盘后数据当天可能尚未生成）。
  Future<List<Map<String, dynamic>>> _latest(
      String api, Map<String, dynamic> params, String fields) async {
    final days = await _recentOpenDays();
    for (final d in days.take(3)) {
      final rows = await call(api, params: {...params, 'trade_date': d}, fields: fields);
      if (rows.isNotEmpty) return rows;
    }
    return const [];
  }

  @override
  Future<Map<String, bool>> calendar({required String from, required String to}) async {
    final rows = await call('trade_cal',
        params: {'exchange': 'SSE', 'start_date': from, 'end_date': to},
        fields: 'cal_date,is_open');
    return {for (final r in rows) r['cal_date'] as String: toInt(r['is_open']) == 1};
  }

  // ───────────── 实时报价 ─────────────

  static Quote _quote(Map<String, dynamic> r) {
    final close = toNum(r['close']) ?? 0;
    final t = r['trade_time'] as String?;
    return Quote(
      code: r['ts_code'] as String,
      name: ((r['name'] as String?) ?? '').trim(),
      price: close,
      preClose: toNum(r['pre_close']) ?? close,
      open: toNum(r['open']),
      high: toNum(r['high']),
      low: toNum(r['low']),
      volume: toNum(r['vol']),
      amount: toNum(r['amount']),
      time: t == null || t.length < 19
          ? null
          : DateTime.parse('${t.replaceFirst(' ', 'T')}+08:00').toUtc(),
    );
  }

  /// 报价：个股 rt_k / 指数 rt_idx_k / ETF rt_etf_k；板块不支持（返回其余部分）。
  @override
  Future<List<Quote>> quotes(List<String> codes) async {
    final byApi = <String, List<String>>{};
    for (final c in codes) {
      final api = switch (Codes.guessType(c)) {
        InstrumentType.stock => 'rt_k',
        // rt_idx_k 只支持沪深指数（北证指数由其他源补齐）
        InstrumentType.marketIndex when Codes.exchange(c) != 'BJ' => 'rt_idx_k',
        InstrumentType.marketIndex => null,
        InstrumentType.etf => 'rt_etf_k',
        InstrumentType.sector => null,
      };
      if (api != null) (byApi[api] ??= []).add(c);
    }
    if (byApi.isEmpty) throw const UnsupportedRequest('Tushare 不支持这些代码的实时报价');
    final out = <Quote>[];
    Object? lastError;
    for (final e in byApi.entries) {
      try {
        final rows = await call(e.key, params: {'ts_code': e.value.join(',')});
        out.addAll(rows.map(_quote).where((q) => q.price > 0));
      } catch (err) {
        lastError = err; // 单组失败不影响其他组，缺的部分由下一个源补齐
      }
    }
    if (out.isEmpty && lastError != null) throw lastError;
    return out;
  }

  // ───────────── 全市场实时（宽度 / 涨跌停） ─────────────

  List<Map<String, dynamic>>? _market;
  DateTime? _marketAt;

  Future<List<Map<String, dynamic>>> _allStocks() async {
    final now = _now();
    if (_market != null && now.difference(_marketAt!) < const Duration(seconds: 15)) {
      return _market!;
    }
    _market = await call('rt_k',
        params: {'ts_code': '6*.SH,0*.SZ,3*.SZ,4*.BJ,8*.BJ,9*.BJ'},
        fields: 'ts_code,name,pre_close,close,high');
    _marketAt = now;
    return _market!;
  }

  /// 涨跌停幅度：北交所 30%，创业板 / 科创板 20%，ST 5%，其余 10%。
  static double limitRatio(String code, String name) {
    final sym = Codes.symbol(code);
    if (Codes.exchange(code) == 'BJ') return 0.30;
    if (sym.startsWith('300') || sym.startsWith('301') || sym.startsWith('688') || sym.startsWith('689')) {
      return 0.20;
    }
    if (name.contains('ST')) return 0.05;
    return 0.10;
  }

  static double _limitPrice(double pre, double ratio) => (pre * (1 + ratio) * 100).round() / 100;

  /// 由全市场快照计算宽度与涨跌停（可单测）。
  static (Breadth, LimitStats) computeMarketStats(List<Map<String, dynamic>> rows) {
    var up = 0, down = 0, flat = 0, lu = 0, ld = 0, broken = 0;
    for (final r in rows) {
      final pre = toNum(r['pre_close']);
      final close = toNum(r['close']);
      if (pre == null || close == null || pre <= 0 || close <= 0) continue;
      if (close > pre) {
        up++;
      } else if (close < pre) {
        down++;
      } else {
        flat++;
      }
      final ratio = limitRatio(r['ts_code'] as String, (r['name'] as String?) ?? '');
      final upPx = _limitPrice(pre, ratio);
      final downPx = _limitPrice(pre, -ratio);
      final high = toNum(r['high']) ?? close;
      if (close >= upPx) {
        lu++;
      } else if (high >= upPx) {
        broken++;
      }
      if (close <= downPx) ld++;
    }
    return (Breadth(up: up, down: down, flat: flat), LimitStats(limitUp: lu, limitDown: ld, broken: broken));
  }

  @override
  Future<Breadth> breadth() async => computeMarketStats(await _allStocks()).$1;

  @override
  Future<LimitStats> limitStats(String tradeDate) async => computeMarketStats(await _allStocks()).$2;

  /// 两市成交额（上证指数 + 深证综指）：今日来自 rt_idx_k，昨日全天来自 index_daily（无同时段对比）。
  @override
  Future<Turnover> turnover() async {
    // 上证指数 = 沪市全部，深证综指 = 深市全部（深证成指仅 500 只成分股）
    final idx = await call('rt_idx_k', params: {'ts_code': '000001.SH,399106.SZ'});
    final today = idx.fold<double>(0, (s, r) => s + (toNum(r['amount']) ?? 0));
    double? yesterday;
    try {
      final days = await _recentOpenDays();
      final todayStr = TradeDate.format(MarketClock.marketDate(_now()));
      final prev = days.firstWhere((d) => d != todayStr);
      var sum = 0.0;
      for (final c in ['000001.SH', '399106.SZ']) {
        final rows = await call('index_daily',
            params: {'ts_code': c, 'trade_date': prev}, fields: 'amount');
        sum += (toNum(rows.firstOrNull?['amount']) ?? 0) * 1000;
      }
      yesterday = sum > 0 ? sum : null;
    } catch (_) {}
    return Turnover(today: today, yesterdayTotal: yesterday);
  }

  // ───────────── 排行 ─────────────

  /// ETF 成交额排行（实时，rt_etf_k 通配符）。
  @override
  Future<List<RankItem>> etfRank({int limit = 10}) async {
    final rows = await call('rt_etf_k',
        params: {'ts_code': '5*.SH,1*.SZ'}, fields: 'ts_code,name,pre_close,close,amount');
    final items = [
      for (final r in rows)
        if ((toNum(r['close']) ?? 0) > 0)
          () {
            final q = _quote(r);
            return RankItem(
                code: q.code, name: q.name, changePct: q.changePct, price: q.price, amount: q.amount);
          }(),
    ]..sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
    return items.take(limit).toList();
  }

  /// 板块排行（盘后数据 dc_index，交易时段内仅作兜底）。
  @override
  Future<List<RankItem>> sectorRank(SectorKind kind,
      {required bool ascending, int limit = 10}) async {
    final rows = await _latest(
      'dc_index',
      {'idx_type': kind == SectorKind.industry ? '行业板块' : '概念板块'},
      'ts_code,name,pct_change,leading,leading_pct',
    );
    final items = [
      for (final r in rows)
        RankItem(
          code: _fromTs(r['ts_code'] as String),
          name: r['name'] as String,
          changePct: toNum(r['pct_change']) ?? 0,
          leaderName: (r['leading'] as String?) == '-' ? null : r['leading'] as String?,
          leaderPct: toNum(r['leading_pct']),
        ),
    ]..sort((a, b) => ascending
        ? a.changePct.compareTo(b.changePct)
        : b.changePct.compareTo(a.changePct));
    return items.take(limit).toList();
  }

  /// 板块成分（dc_member）+ 成分股实时报价。
  @override
  Future<List<RankItem>> sectorMembers(String sectorCode, {int limit = 50}) async {
    if (!Codes.isEmSector(sectorCode)) throw const UnsupportedRequest('仅支持东财板块');
    final members =
        await _latest('dc_member', {'ts_code': _toTs(sectorCode)}, 'con_code,name');
    if (members.isEmpty) throw SourceError(id, '无成分数据');
    final codes = members.map((m) => m['con_code'] as String).toList();
    final quotes = <Quote>[];
    for (var i = 0; i < codes.length; i += 300) {
      quotes.addAll(await this.quotes(codes.sublist(i, (i + 300).clamp(0, codes.length))));
    }
    final items = [
      for (final q in quotes)
        RankItem(code: q.code, name: q.name, changePct: q.changePct, price: q.price, amount: q.amount),
    ]..sort((a, b) => b.changePct.compareTo(a.changePct));
    return items.take(limit).toList();
  }

  // ───────────── 代码表 / 日 K ─────────────

  /// 个股 + 场内基金（ETF/LOF）+ 沪深指数 + 东财行业 / 概念 / 地域板块。
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
          name: (r['name'] as String).trim(),
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
    final boards = await _latest('dc_index', const {}, 'ts_code,name,idx_type');
    out.addAll(boards.map((r) => InstrumentInfo(
          code: _fromTs(r['ts_code'] as String),
          name: r['name'] as String,
          type: InstrumentType.sector,
          exchange: 'EM',
        )));
    return out;
  }

  @override
  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) async {
    final api = switch (Codes.guessType(code)) {
      InstrumentType.marketIndex => 'index_daily',
      InstrumentType.etf => 'fund_daily',
      InstrumentType.sector when Codes.isEmSector(code) => 'dc_daily',
      InstrumentType.sector when Codes.isThsSector(code) => 'ths_daily',
      InstrumentType.sector => throw const UnsupportedRequest('Tushare 不支持该板块代码'),
      InstrumentType.stock => 'daily',
    };
    final rows = await call(api, params: {
      'ts_code': _toTs(code),
      'start_date': from,
      'end_date': ?to,
    }, fields: 'trade_date,open,high,low,close,vol,amount');
    // dc_daily 的 amount 单位为元，其余日线为千元
    final amountUnit = api == 'dc_daily' ? 1.0 : 1000.0;
    final bars = [
      for (final r in rows)
        KBar(
          date: r['trade_date'] as String,
          open: toNum(r['open'])!,
          high: toNum(r['high'])!,
          low: toNum(r['low'])!,
          close: toNum(r['close'])!,
          volume: toNum(r['vol']),
          amount: toNum(r['amount']) == null ? null : toNum(r['amount'])! * amountUnit,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return bars;
  }
}

