import '../../data/db/app_database.dart';
import 'trade_rules.dart';

/// 成本算法（spec 3.4.3）。
enum CostMethod {
  /// 摊薄成本：卖出盈亏摊回剩余持仓，成本 = (累计投入 − 累计回收) / 持仓
  diluted('diluted', '摊薄成本'),

  /// 移动加权平均：卖出按平均成本结转已实现盈亏
  movingAverage('moving', '移动加权平均');

  const CostMethod(this.code, this.label);
  final String code;
  final String label;

  static CostMethod fromCode(String? c) => values.firstWhere((m) => m.code == c, orElse: () => diluted);
}

double _fees(Trade t) => t.commission + t.stampTax + t.transferFee;

/// 一个标的的持仓状态（按交易流水推导）。
class Holding {
  Holding(this.code);
  final String code;

  int qty = 0;

  /// 移动加权平均法下的持仓成本总额
  double basis = 0;

  /// 摊薄法下的净投入（买入含费 − 卖出净额 − 分红）
  double netInvested = 0;

  /// 移动加权平均法下累计已实现盈亏（含分红）
  double realized = 0;

  /// 当前这一轮持仓的开仓时间（UTC ms）
  int? openedAt;

  /// 卖出超过持仓数量（流水不完整）
  bool oversold = false;

  /// 今日交易（计算当日盈亏）
  final List<Trade> today = [];

  double get avgCost => qty == 0 ? 0 : basis / qty;
  double get dilutedCost => qty == 0 ? 0 : netInvested / qty;
  double cost(CostMethod m) => m == CostMethod.diluted ? dilutedCost : avgCost;

  /// 持仓成本总额
  double costTotal(CostMethod m) => m == CostMethod.diluted ? netInvested : basis;

  double marketValue(double price) => qty * price;

  /// 浮动盈亏
  double floating(double price, CostMethod m) => marketValue(price) - costTotal(m);

  /// 当日盈亏：昨日已持有部分按昨收算，今日买入按成交价算，今日卖出按卖出价对昨收算。
  double dayPnl(double price, double preClose) {
    var qtyToday = 0;
    var pnl = 0.0;
    for (final t in today) {
      final side = TradeSide.fromCode(t.side);
      switch (side) {
        case TradeSide.buy:
          qtyToday += t.qty;
          pnl += t.qty * (price - t.price) - _fees(t);
        case TradeSide.init:
          // 期初持仓视为昨日已持有
          break;
        case TradeSide.sell:
          qtyToday -= t.qty;
          pnl += t.qty * (t.price - preClose) - _fees(t);
        case TradeSide.bonus:
          // 送转当日除权，昨收已是除权价，送股视为昨日已持有
          break;
        case TradeSide.dividend:
          pnl += t.amount - _fees(t);
        case null:
          break;
      }
    }
    final held = qty - qtyToday;
    return pnl + held * (price - preClose);
  }

  int holdingDays(DateTime now) =>
      openedAt == null ? 0 : now.difference(DateTime.fromMillisecondsSinceEpoch(openedAt!, isUtc: true)).inDays;
}

/// 一轮完整交易：从开仓（持仓 0 → >0）到清仓（回到 0）。
class RoundTrip {
  const RoundTrip({
    required this.code,
    required this.openedAt,
    required this.closedAt,
    required this.pnl,
    required this.invested,
  });
  final String code;
  final int openedAt;
  final int closedAt;

  /// 净盈亏（含费用、分红）
  final double pnl;

  /// 累计买入金额（含费）
  final double invested;

  double get returnPct => invested == 0 ? 0 : pnl / invested * 100;
}

class Portfolio {
  Portfolio._(this.holdings, this.roundTrips);

  /// 代码 → 持仓（含已清仓、只有已实现盈亏的标的）
  final Map<String, Holding> holdings;
  final List<RoundTrip> roundTrips;

  Iterable<Holding> get open => holdings.values.where((h) => h.qty > 0);

  /// 已实现盈亏。摊薄法下未清仓标的的部分卖出盈亏已摊进成本，只计已清仓的轮次与清仓后分红。
  double realized(CostMethod m) => m == CostMethod.movingAverage
      ? holdings.values.fold(0.0, (s, h) => s + h.realized)
      : roundTrips.fold(0.0, (s, r) => s + r.pnl) + _closedExtra;

  double _closedExtra = 0;

  /// 由交易流水计算持仓。[todayStart] 为今日 0 点（UTC ms），用于当日盈亏。
  static Portfolio compute(Iterable<Trade> trades, {int? todayStart}) {
    final list = trades.where((t) => t.deletedAt == null).toList()
      ..sort((a, b) => a.ts != b.ts ? a.ts.compareTo(b.ts) : a.createdAt.compareTo(b.createdAt));
    final map = <String, Holding>{};
    final trips = <RoundTrip>[];
    final tripCash = <String, double>{};
    final tripBuy = <String, double>{};
    var closedExtra = 0.0;

    for (final t in list) {
      final side = TradeSide.fromCode(t.side);
      if (side == null) continue;
      final h = map.putIfAbsent(t.instrumentCode, () => Holding(t.instrumentCode));
      if (todayStart != null && t.ts >= todayStart) h.today.add(t);
      final fees = _fees(t);
      switch (side) {
        case TradeSide.buy || TradeSide.init:
          final cost = t.amount + fees;
          if (h.qty == 0) {
            h.openedAt = t.ts;
            tripCash[h.code] = 0;
            tripBuy[h.code] = 0;
          }
          h.qty += t.qty;
          h.basis += cost;
          h.netInvested += cost;
          tripCash[h.code] = (tripCash[h.code] ?? 0) - cost;
          tripBuy[h.code] = (tripBuy[h.code] ?? 0) + cost;
        case TradeSide.bonus:
          h.qty += t.qty;
        case TradeSide.dividend:
          final cash = t.amount - fees;
          h.realized += cash;
          if (h.qty > 0) {
            h.netInvested -= cash;
            tripCash[h.code] = (tripCash[h.code] ?? 0) + cash;
          } else {
            closedExtra += cash;
          }
        case TradeSide.sell:
          if (h.qty <= 0) {
            h.oversold = true;
            continue;
          }
          var q = t.qty;
          var proceeds = t.amount - fees;
          if (q > h.qty) {
            // 流水缺少买入记录：只按持仓数量结转
            h.oversold = true;
            proceeds = proceeds * h.qty / q;
            q = h.qty;
          }
          final avg = h.basis / h.qty;
          h.realized += proceeds - avg * q;
          h.basis -= avg * q;
          h.qty -= q;
          h.netInvested -= proceeds;
          tripCash[h.code] = (tripCash[h.code] ?? 0) + proceeds;
          if (h.qty == 0) {
            trips.add(RoundTrip(
              code: h.code,
              openedAt: h.openedAt ?? t.ts,
              closedAt: t.ts,
              pnl: tripCash[h.code] ?? 0,
              invested: tripBuy[h.code] ?? 0,
            ));
            h.basis = 0;
            h.netInvested = 0;
            h.openedAt = null;
          }
      }
    }
    return Portfolio._(map, trips).._closedExtra = closedExtra;
  }
}

/// 已清仓交易的统计（spec 3.4.3）。
class TradeStats {
  TradeStats(List<RoundTrip> trips) {
    for (final t in trips) {
      count++;
      total += t.pnl;
      if (t.pnl > 0) {
        wins++;
        grossWin += t.pnl;
      } else {
        grossLoss += -t.pnl;
      }
    }
  }

  int count = 0;
  int wins = 0;
  double total = 0;
  double grossWin = 0;
  double grossLoss = 0;

  double get winRate => count == 0 ? 0 : wins / count;
  double get avgWin => wins == 0 ? 0 : grossWin / wins;
  double get avgLoss => count - wins == 0 ? 0 : grossLoss / (count - wins);

  /// 盈亏比：平均盈利 / 平均亏损
  double? get payoff => avgLoss == 0 ? null : avgWin / avgLoss;

  static Map<String, TradeStats> groupBy(List<RoundTrip> trips, String Function(RoundTrip) key) {
    final g = <String, List<RoundTrip>>{};
    for (final t in trips) {
      g.putIfAbsent(key(t), () => []).add(t);
    }
    return g.map((k, v) => MapEntry(k, TradeStats(v)));
  }
}
