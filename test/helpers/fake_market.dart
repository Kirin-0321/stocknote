import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/sources.dart';

/// 可编程的假数据源。
class FakeSource extends MarketSource {
  FakeSource(this.id, {Set<Capability>? caps, this.fail = false, this.available = true})
      : capabilities = caps ?? Capability.values.toSet();

  @override
  final SourceId id;
  @override
  final Set<Capability> capabilities;
  bool fail;
  final bool available;
  int calls = 0;

  @override
  bool get isAvailable => available;

  Future<T> _run<T>(T Function() value) async {
    calls++;
    if (fail) throw Exception('${id.code} down');
    return value();
  }

  static Quote quote(String code, double price, double pre, {String? name}) =>
      Quote(code: code, name: name ?? indexShortNames[code] ?? code, price: price, preClose: pre, amount: 1e11);

  @override
  Future<List<Quote>> quotes(List<String> codes) => _run(() => [
        for (final c in codes) quote(c, 100 + codes.indexOf(c).toDouble(), 100),
      ]);

  /// 代码 → 日 K（测试按需填充）
  final Map<String, List<KBar>> klines = {};

  @override
  Future<List<KBar>> dailyKline(String code, {required String from, String? to}) =>
      _run(() => (klines[code] ?? const <KBar>[]).where((b) => b.date.compareTo(from) >= 0).toList());

  @override
  Future<Breadth> breadth() => _run(() => const Breadth(up: 3000, down: 1800, flat: 200));

  @override
  Future<LimitStats> limitStats(String tradeDate) =>
      _run(() => const LimitStats(limitUp: 60, limitDown: 5, broken: 20));

  @override
  Future<Turnover> turnover() =>
      _run(() => const Turnover(today: 1.0e12, yesterdaySameTime: 0.9e12, yesterdayTotal: 1.5e12));

  @override
  Future<List<RankItem>> sectorRank(SectorKind kind, {required bool ascending, int limit = 10}) =>
      _run(() => [
            for (var i = 0; i < 3; i++)
              RankItem(
                code: 'BK000$i.EM',
                name: '${kind == SectorKind.industry ? '行业' : '概念'}${ascending ? '跌' : '涨'}$i',
                changePct: ascending ? -3.0 + i : 3.0 - i,
                leaderName: '龙头$i',
              ),
          ]);

  @override
  Future<List<RankItem>> etfRank({int limit = 10}) => _run(() => [
        const RankItem(code: '510300.SH', name: '沪深300ETF', changePct: 0.5, amount: 5e9),
      ]);
}
