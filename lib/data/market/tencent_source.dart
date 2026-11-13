import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';

import 'code_util.dart';
import 'http.dart';
import 'models.dart';
import 'sources.dart';

/// 腾讯财经行情接口（非官方，免费）。报价 / 分时 / 日 K 的备用源。
class TencentSource extends MarketSource {
  TencentSource({Dio? dio}) : _dio = dio ?? createMarketDio();

  final Dio _dio;

  @override
  SourceId get id => SourceId.tencent;

  @override
  Set<Capability> get capabilities => {
        Capability.quotes,
        Capability.intraday,
        Capability.dailyKline,
        Capability.sectorRank,
        Capability.turnover,
      };

  /// 腾讯板块排行（行业 hy2 / 概念 gn），板块代码形如 `01801766.PT`。
  @override
  Future<List<RankItem>> sectorRank(SectorKind kind,
      {required bool ascending, int limit = 10}) async {
    final res = await _dio.get<List<int>>(
      'https://proxy.finance.qq.com/cgi/cgi-bin/rank/pt/getRank',
      queryParameters: {
        'board_type': kind == SectorKind.industry ? 'hy2' : 'gn',
        'sort_type': 'priceRatio',
        'direct': ascending ? 'up' : 'down',
        'offset': 0,
        'count': limit,
      },
    );
    return parseSectorRank(decodeJsonBytes(res.data!));
  }

  static List<RankItem> parseSectorRank(dynamic json) {
    if (json['code'] != 0) throw Exception('腾讯板块排行：${json['msg']}');
    final list = (json['data']?['rank_list'] as List?) ?? const [];
    return [
      for (final r in list)
        RankItem(
          code: Codes.fromTencent(r['code'] as String),
          name: r['name'] as String,
          changePct: toNum(r['zdf']) ?? 0,
          price: toNum(r['zxj']),
          amount: toNum(r['turnover']) == null ? null : toNum(r['turnover'])! * 10000,
          leaderName: r['lzg']?['name'] as String?,
          leaderPct: toNum(r['lzg']?['zdf']),
        ),
    ];
  }

  /// 仅今日两市成交额（上证指数 + 深证成指），无昨日同时段对比。
  @override
  Future<Turnover> turnover() async {
    final q = await quotes(['000001.SH', '399001.SZ']);
    if (q.length < 2) throw Exception('成交额数据不完整');
    return Turnover(today: q.fold(0.0, (s, x) => s + (x.amount ?? 0)));
  }

  List<String> _symbols(List<String> codes) {
    final out = <String>[];
    for (final c in codes) {
      final t = Codes.toTencent(c);
      if (t != null) out.add(t);
    }
    if (out.isEmpty) throw const UnsupportedRequest('腾讯不支持这些代码');
    return out;
  }

  @override
  Future<List<Quote>> quotes(List<String> codes) async {
    final res = await _dio.get<List<int>>('https://qt.gtimg.cn/q=${_symbols(codes).join(',')}');
    return parseQuotes(gbk.decode(res.data!));
  }

  /// 解析 `v_sh000001="1~上证指数~000001~3663.71~3655.83~3658.72~...";`
  static List<Quote> parseQuotes(String body) {
    final out = <Quote>[];
    final re = RegExp(r'v_([a-z]{2}\w+)="([^"]*)"');
    for (final m in re.allMatches(body)) {
      final f = m.group(2)!.split('~');
      if (f.length < 38) continue;
      final price = toNum(f[3]);
      if (price == null) continue;
      final t = f[30];
      out.add(Quote(
        code: Codes.fromTencent(m.group(1)!),
        name: f[1],
        price: price,
        preClose: toNum(f[4]) ?? price,
        open: toNum(f[5]),
        high: toNum(f[33]),
        low: toNum(f[34]),
        volume: (toNum(f[36]) ?? 0) * 100,
        amount: (toNum(f[37]) ?? 0) * 10000,
        time: t.length >= 14
            ? DateTime.utc(int.parse(t.substring(0, 4)), int.parse(t.substring(4, 6)),
                    int.parse(t.substring(6, 8)), int.parse(t.substring(8, 10)),
                    int.parse(t.substring(10, 12)), int.parse(t.substring(12, 14)))
                .subtract(const Duration(hours: 8))
            : null,
      ));
    }
    return out;
  }

  @override
  Future<Intraday> intraday(String code) async {
    final sym = _symbols([code]).first;
    final res = await _dio
        .get<List<int>>('https://web.ifzq.gtimg.cn/appstock/app/minute/query', queryParameters: {'code': sym});
    final json = decodeJsonBytes(res.data!);
    final node = json['data']?[sym];
    if (node == null) throw SourceError(id, '分时数据为空');
    final lines = (node['data']?['data'] as List?)?.cast<String>() ?? const [];
    final qt = (node['qt']?[sym] as List?)?.cast<String>();
    final preClose = qt == null ? 0.0 : (toNum(qt[4]) ?? 0.0);
    // 行格式："0931 3658.72 4180629 5518513830.20"（价格 累计量 累计额）
    final points = <IntradayPoint>[];
    double? prevCum;
    for (final l in lines) {
      final p = l.split(' ');
      final cum = toNum(p.length > 3 ? p[3] : null);
      points.add(IntradayPoint(
        minute: p[0],
        price: double.parse(p[1]),
        amount: cum == null ? null : cum - (prevCum ?? 0),
      ));
      prevCum = cum ?? prevCum;
    }
    return Intraday(
        code: code, preClose: preClose, points: points, date: node['data']?['date'] as String?);
  }

  @override
  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) async {
    final sym = _symbols([code]).first;
    String dash(String d) => '${d.substring(0, 4)}-${d.substring(4, 6)}-${d.substring(6, 8)}';
    final res = await _dio.get<List<int>>(
        'https://web.ifzq.gtimg.cn/appstock/app/fqkline/get',
        queryParameters: {'param': '$sym,day,${dash(from)},${to == null ? '' : dash(to)},640,'});
    final json = decodeJsonBytes(res.data!);
    final rows = (json['data']?[sym]?['day'] as List?) ?? const [];
    // 行格式：[date, open, close, high, low, volume]
    return [
      for (final r in rows.cast<List>())
        KBar(
          date: (r[0] as String).replaceAll('-', ''),
          open: toNum(r[1])!,
          close: toNum(r[2])!,
          high: toNum(r[3])!,
          low: toNum(r[4])!,
          volume: toNum(r[5]),
        ),
    ];
  }
}
