import 'package:dio/dio.dart';

import 'code_util.dart';
import 'http.dart';
import 'models.dart';
import 'sources.dart';

/// 东方财富网页行情接口（非官方，免费）。
///
/// 能力最全（宽度、涨停池、板块、ETF 排行），但有反爬：高频请求会被临时断开连接，
/// 因此由路由器负责失败退避，看板对这些数据使用较低刷新频率。
class EastmoneySource extends MarketSource {
  EastmoneySource({Dio? dio}) : _dio = dio ?? createMarketDio();

  final Dio _dio;

  static const _ut = 'bd1d9ddb04089700cf9c27f6f7426281';
  static const _poolUt = '7eea3edcaed734bea9cbfc24409ed989';

  @override
  SourceId get id => SourceId.eastmoney;

  @override
  Set<Capability> get capabilities => {
        Capability.quotes,
        Capability.intraday,
        Capability.dailyKline,
        Capability.breadth,
        Capability.limitStats,
        Capability.turnover,
        Capability.sectorRank,
        Capability.sectorMembers,
        Capability.etfRank,
        Capability.instruments,
      };

  Future<dynamic> _get(String url, Map<String, dynamic> params) async {
    final res = await _dio.get<List<int>>(url,
        queryParameters: params,
        options: Options(headers: {'Referer': 'https://quote.eastmoney.com/'}));
    return decodeJsonBytes(res.data!);
  }

  @override
  Future<List<Quote>> quotes(List<String> codes) async {
    final secids = <String>[];
    for (final c in codes) {
      final s = Codes.toEmSecid(c);
      if (s != null) secids.add(s);
    }
    if (secids.isEmpty) throw const UnsupportedRequest('无可识别的代码');
    final json = await _get('https://push2.eastmoney.com/api/qt/ulist.np/get', {
      'fltt': 2,
      'invt': 2,
      'ut': _ut,
      'secids': secids.join(','),
      'fields': 'f2,f5,f6,f12,f13,f14,f15,f16,f17,f18,f124',
    });
    final diff = (json['data']?['diff'] as List?) ?? const [];
    return [
      for (final d in diff)
        if (toNum(d['f2']) != null)
          Quote(
            code: Codes.fromEm(toInt(d['f13']), d['f12'] as String),
            name: d['f14'] as String,
            price: toNum(d['f2'])!,
            preClose: toNum(d['f18']) ?? toNum(d['f2'])!,
            open: toNum(d['f17']),
            high: toNum(d['f15']),
            low: toNum(d['f16']),
            volume: (toNum(d['f5']) ?? 0) * 100,
            amount: toNum(d['f6']),
            time: d['f124'] is num
                ? DateTime.fromMillisecondsSinceEpoch((d['f124'] as num).toInt() * 1000,
                    isUtc: true)
                : null,
          ),
    ];
  }

  Future<List<TrendRow>> _trends(String secid, int ndays) async {
    final json = await _get('https://push2his.eastmoney.com/api/qt/stock/trends2/get', {
      'secid': secid,
      'ut': _ut,
      'fields1': 'f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13',
      'fields2': 'f51,f52,f53,f54,f55,f56,f57,f58',
      'ndays': ndays,
      'iscr': 0,
    });
    final data = json['data'];
    if (data == null) throw SourceError(id, '分时数据为空');
    final pre = toNum(data['preClose']) ?? toNum(data['prePrice']) ?? 0;
    return [
      for (final t in (data['trends'] as List).cast<String>())
        TrendRow.parse(t, pre),
    ];
  }

  @override
  Future<Intraday> intraday(String code) async {
    final secid = Codes.toEmSecid(code);
    if (secid == null) throw const UnsupportedRequest('代码格式不支持');
    final rows = await _trends(secid, 1);
    if (rows.isEmpty) throw SourceError(id, '无分时数据');
    return Intraday(
      code: code,
      preClose: rows.first.preClose,
      date: rows.first.date,
      points: [
        for (final r in rows)
          IntradayPoint(minute: r.minute, price: r.close, avg: r.avg, amount: r.amount),
      ],
    );
  }

  @override
  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) async {
    final secid = Codes.toEmSecid(code);
    if (secid == null) throw const UnsupportedRequest('代码格式不支持');
    final json = await _get('https://push2his.eastmoney.com/api/qt/stock/kline/get', {
      'secid': secid,
      'ut': _ut,
      'klt': 101,
      'fqt': 0, // 不复权，与判定口径一致
      'beg': from,
      'end': to ?? '20500101',
      'fields1': 'f1,f2,f3',
      'fields2': 'f51,f52,f53,f54,f55,f56,f57',
    });
    final lines = (json['data']?['klines'] as List?)?.cast<String>() ?? const [];
    return [
      for (final l in lines)
        () {
          final p = l.split(',');
          return KBar(
            date: p[0].replaceAll('-', ''),
            open: double.parse(p[1]),
            close: double.parse(p[2]),
            high: double.parse(p[3]),
            low: double.parse(p[4]),
            volume: toNum(p[5]),
            amount: toNum(p[6]),
          );
        }(),
    ];
  }

  @override
  Future<Breadth> breadth() async {
    // 上证指数 = 沪市全部，深证综指 = 深市全部
    final json = await _get('https://push2.eastmoney.com/api/qt/ulist.np/get', {
      'fltt': 2,
      'ut': _ut,
      'secids': '1.000001,0.399106',
      'fields': 'f12,f104,f105,f106',
    });
    final diff = (json['data']?['diff'] as List?) ?? const [];
    if (diff.isEmpty) throw SourceError(id, '宽度数据为空');
    var up = 0, down = 0, flat = 0;
    for (final d in diff) {
      up += toInt(d['f104']);
      down += toInt(d['f105']);
      flat += toInt(d['f106']);
    }
    return Breadth(up: up, down: down, flat: flat);
  }

  Future<int> _poolCount(String api, String dpt, String date) async {
    final json = await _get('https://push2ex.eastmoney.com/$api', {
      'ut': _poolUt,
      'dpt': dpt,
      'Pageindex': 0,
      'pagesize': 1,
      'sort': 'fbt:asc',
      'date': date,
    });
    return toInt(json['data']?['tc']);
  }

  @override
  Future<LimitStats> limitStats(String tradeDate) async {
    final up = await _poolCount('getTopicZTPool', 'wz.ztzt', tradeDate);
    final down = await _poolCount('getTopicDTPool', 'wz.ztzt', tradeDate);
    final broken = await _poolCount('getTopicZBPool', 'wz.ztzt', tradeDate);
    return LimitStats(limitUp: up, limitDown: down, broken: broken);
  }

  @override
  Future<Turnover> turnover() async {
    final sh = await _trends('1.000001', 2);
    final sz = await _trends('0.399001', 2);
    return computeTurnover([...sh, ...sz]);
  }

  /// 由两日分时计算今日成交额与昨日同时段成交额。可单测。
  static Turnover computeTurnover(List<TrendRow> rows) {
    if (rows.isEmpty) throw StateError('no rows');
    final dates = rows.map((r) => r.date).toSet().toList()..sort();
    final today = dates.last;
    final yesterday = dates.length > 1 ? dates[dates.length - 2] : null;
    final todayRows = rows.where((r) => r.date == today);
    final lastMinute = todayRows.map((r) => r.minute).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    double sum(Iterable<TrendRow> xs) => xs.fold(0, (s, r) => s + (r.amount ?? 0));
    final yRows = rows.where((r) => r.date == yesterday);
    return Turnover(
      today: sum(todayRows),
      yesterdaySameTime:
          yesterday == null ? null : sum(yRows.where((r) => r.minute.compareTo(lastMinute) <= 0)),
      yesterdayTotal: yesterday == null ? null : sum(yRows),
    );
  }

  Future<List<RankItem>> _clist(String fs,
      {required String fid, required bool ascending, int limit = 10, int page = 1}) async {
    final json = await _get('https://push2.eastmoney.com/api/qt/clist/get', {
      'pn': page,
      'pz': limit,
      'po': ascending ? 0 : 1,
      'np': 1,
      'fltt': 2,
      'invt': 2,
      'ut': _ut,
      'fid': fid,
      'fs': fs,
      'fields': 'f2,f3,f6,f12,f13,f14,f128,f136',
    });
    final diff = (json['data']?['diff'] as List?) ?? const [];
    return [
      for (final d in diff)
        RankItem(
          code: Codes.fromEm(toInt(d['f13']), d['f12'] as String),
          name: d['f14'] as String,
          changePct: toNum(d['f3']) ?? 0,
          price: toNum(d['f2']),
          amount: toNum(d['f6']),
          leaderName: d['f128'] is String && d['f128'] != '-' ? d['f128'] as String : null,
          leaderPct: toNum(d['f136']),
        ),
    ];
  }

  @override
  Future<List<RankItem>> sectorRank(SectorKind kind,
          {required bool ascending, int limit = 10}) =>
      _clist(kind == SectorKind.industry ? 'm:90+t:2' : 'm:90+t:3',
          fid: 'f3', ascending: ascending, limit: limit);

  @override
  Future<List<RankItem>> sectorMembers(String sectorCode, {int limit = 50}) {
    if (!Codes.isEmSector(sectorCode)) {
      throw const UnsupportedRequest('仅支持东方财富板块代码');
    }
    return _clist('b:${Codes.symbol(sectorCode)}', fid: 'f3', ascending: false, limit: limit);
  }

  @override
  Future<List<RankItem>> etfRank({int limit = 10}) => _clist(
      'b:MK0021,b:MK0022,b:MK0023,b:MK0024',
      fid: 'f6', ascending: false, limit: limit);

  /// 只拉板块列表（个股 / ETF 代码表优先用 Tushare）。分页，每页间隔以降低反爬风险。
  @override
  Future<List<InstrumentInfo>> instruments() async {
    final result = <InstrumentInfo>[];
    for (final fs in ['m:90+t:2', 'm:90+t:3']) {
      for (var page = 1; page <= 20; page++) {
        final items = await _clist(fs, fid: 'f12', ascending: true, limit: 100, page: page);
        result.addAll(items.map((i) => InstrumentInfo(
            code: i.code, name: i.name, type: InstrumentType.sector, exchange: 'EM')));
        if (items.length < 100) break;
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
    return result;
  }
}

/// 东方财富分时行："2026-11-13 09:31,open,close,high,low,vol,amount,avg"
class TrendRow {
  TrendRow(this.date, this.minute, this.close, this.amount, this.avg, this.preClose);

  factory TrendRow.parse(String line, double preClose) {
    final p = line.split(',');
    final dt = p[0].split(' ');
    return TrendRow(
      dt[0].replaceAll('-', ''),
      dt[1].replaceAll(':', ''),
      double.parse(p[2]),
      toNum(p[6]),
      toNum(p[7]),
      preClose,
    );
  }

  final String date;
  final String minute;
  final double close;
  final double? amount;
  final double? avg;
  final double preClose;
}


