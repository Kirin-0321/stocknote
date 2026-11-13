import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/time/market_clock.dart';
import '../../data/db/app_database.dart';
import '../../data/market/models.dart';
import '../../domain/trade/portfolio.dart';
import '../market/market_providers.dart';

final accountsProvider = StreamProvider<List<Account>>((ref) => ref.watch(accountRepositoryProvider).watchAll());

/// 当前查看的账户，null 表示全部账户。
class SelectedAccountNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final selectedAccountProvider = NotifierProvider<SelectedAccountNotifier, String?>(SelectedAccountNotifier.new);

/// 成本算法（持久化到设置）。
class CostMethodNotifier extends Notifier<CostMethod> {
  static const _key = 'portfolio.cost_method';

  @override
  CostMethod build() {
    ref.read(settingsStoreProvider).raw(_key).then((v) {
      final m = CostMethod.fromCode(v);
      if (m != state) state = m;
    });
    return CostMethod.diluted;
  }

  Future<void> set(CostMethod m) async {
    state = m;
    await ref.read(settingsStoreProvider).setRaw(_key, m.code);
  }
}

final costMethodProvider = NotifierProvider<CostMethodNotifier, CostMethod>(CostMethodNotifier.new);

final tradesProvider = StreamProvider<List<Trade>>((ref) {
  final account = ref.watch(selectedAccountProvider);
  return ref.watch(tradeRepositoryProvider).watchAll(accountId: account);
});

final portfolioProvider = Provider<Portfolio>((ref) {
  final trades = ref.watch(tradesProvider).value ?? const [];
  final now = ref.watch(clockProvider)();
  final d = MarketClock.marketDate(now);
  final todayStart = MarketClock.fromMarket(d.year, d.month, d.day).millisecondsSinceEpoch;
  return Portfolio.compute(trades, todayStart: todayStart);
});

/// 交易中涉及的全部代码 → 名称。
final tradeNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final trades = ref.watch(tradesProvider).value ?? const [];
  final codes = trades.map((t) => t.instrumentCode).toSet();
  final rows = await ref.watch(instrumentRepositoryProvider).getMany(codes);
  return {for (final c in codes) c: indexShortNames[c] ?? rows[c]?.name ?? c};
});

/// 持仓标的的实时报价：交易时段 30 秒刷新，其余 5 分钟；离开页面即停止。
final positionQuotesProvider = StreamProvider.autoDispose<Map<String, Quote>>((ref) {
  final codes = ref.watch(portfolioProvider.select((p) => (p.open.map((h) => h.code).toList()..sort()).join(',')));
  final service = ref.watch(marketServiceProvider);
  final clock = ref.watch(clockProvider);
  final controller = StreamController<Map<String, Quote>>();
  Timer? timer;
  var disposed = false;
  var last = <String, Quote>{};

  Future<void> tick() async {
    if (disposed) return;
    if (codes.isEmpty) {
      controller.add(const {});
      return;
    }
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle == null || lifecycle == AppLifecycleState.resumed) {
      try {
        final qs = await service.quotes(codes.split(','));
        last = {...last, for (final q in qs) q.code: q};
        if (!disposed) controller.add(last);
      } catch (e, st) {
        if (!disposed && last.isEmpty) controller.addError(e, st);
      }
    }
    final live = MarketStatus.of(ref.read(tradingCalendarProvider), clock()).live;
    if (!disposed) timer = Timer(Duration(seconds: live ? 30 : 300), tick);
  }

  tick();
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

/// 汇总（按当前成本算法与报价）。
class PortfolioSummary {
  double marketValue = 0;
  double cost = 0;
  double floating = 0;
  double day = 0;
  double realized = 0;
  bool missingQuotes = false;

  double? get floatingPct => cost == 0 ? null : floating / cost * 100;
}

final portfolioSummaryProvider = Provider.autoDispose<PortfolioSummary>((ref) {
  final p = ref.watch(portfolioProvider);
  final m = ref.watch(costMethodProvider);
  final quotes = ref.watch(positionQuotesProvider).value ?? const {};
  final s = PortfolioSummary()..realized = p.realized(m);
  for (final h in p.open) {
    final q = quotes[h.code];
    if (q == null) {
      s.missingQuotes = true;
      s.cost += h.costTotal(m);
      continue;
    }
    s.marketValue += h.marketValue(q.price);
    s.cost += h.costTotal(m);
    s.floating += h.floating(q.price, m);
    s.day += h.dayPnl(q.price, q.preClose);
  }
  return s;
});
