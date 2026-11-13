import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/market_clock.dart';
import '../../data/db/app_database.dart';
import '../../data/market/models.dart';
import '../../domain/trade/portfolio.dart';
import '../../domain/trade/trade_rules.dart';
import '../market/widgets/market_widgets.dart';
import 'accounts_page.dart';
import 'import_pages.dart';
import 'portfolio_providers.dart';
import 'trade_form_page.dart';

/// 持仓与交易（spec 3.4，Tab 4）。
class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  Future<void> _addTrade(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TradeFormPage()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final selected = ref.watch(selectedAccountProvider);
    final method = ref.watch(costMethodProvider);
    final current = accounts.where((a) => a.id == selected).firstOrNull;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: accounts.length > 1
              ? PopupMenuButton<String?>(
                  initialValue: selected,
                  onSelected: (v) => ref.read(selectedAccountProvider.notifier).set(v == '' ? null : v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: '', child: Text('全部账户')),
                    for (final a in accounts) PopupMenuItem(value: a.id, child: Text(a.name)),
                  ],
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(current?.name ?? '全部账户'),
                    const Icon(Icons.arrow_drop_down),
                  ]),
                )
              : const Text('持仓'),
          actions: [
            IconButton(
                key: const Key('trade-add'),
                tooltip: '记一笔',
                icon: const Icon(Icons.add),
                onPressed: () => _addTrade(context)),
            PopupMenuButton<String>(
              key: const Key('portfolio-menu'),
              onSelected: (v) {
                switch (v) {
                  case 'table':
                    startTableImport(context, ref);
                  case 'image':
                    startImageImport(context, ref);
                  case 'accounts':
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountsPage()));
                  case 'diluted' || 'moving':
                    ref.read(costMethodProvider.notifier).set(CostMethod.fromCode(v));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'table', child: ListTile(leading: Icon(Icons.table_view), title: Text('导入交割单（CSV / Excel）'))),
                const PopupMenuItem(value: 'image', child: ListTile(leading: Icon(Icons.image_outlined), title: Text('识别券商截图'))),
                const PopupMenuItem(value: 'accounts', child: ListTile(leading: Icon(Icons.account_balance_outlined), title: Text('账户与费率'))),
                const PopupMenuDivider(),
                for (final m in CostMethod.values)
                  CheckedPopupMenuItem(value: m.code, checked: m == method, child: Text('成本：${m.label}')),
              ],
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: '持仓'), Tab(text: '交易'), Tab(text: '统计')]),
        ),
        body: const TabBarView(children: [_HoldingsTab(), _TradesTab(), _StatsTab()]),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '还没有交易记录。\n右上角 + 记一笔，或在菜单中导入交割单 / 识别券商持仓截图。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
}

// ───────────── 持仓 ─────────────

class _HoldingsTab extends ConsumerWidget {
  const _HoldingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(portfolioProvider);
    final trades = ref.watch(tradesProvider).value;
    if (trades == null) return const Center(child: CircularProgressIndicator());
    if (trades.isEmpty) return const _Empty();
    final method = ref.watch(costMethodProvider);
    final quotes = ref.watch(positionQuotesProvider).value ?? const {};
    final names = ref.watch(tradeNamesProvider).value ?? const {};
    final s = ref.watch(portfolioSummaryProvider);
    final mc = marketColors(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final open = p.open.toList()
      ..sort((a, b) {
        double mv(Holding h) => quotes[h.code] == null ? h.costTotal(method) : h.marketValue(quotes[h.code]!.price);
        return mv(b).compareTo(mv(a));
      });

    return ListView(padding: const EdgeInsets.only(bottom: 88), children: [
      BoardCard(
        key: const Key('portfolio-summary'),
        title: '总览 · ${method.label}',
        child: Column(children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Metric(label: '持仓市值', value: formatMoney(s.marketValue))),
            Expanded(
              child: Metric(
                label: '浮动盈亏',
                value: formatMoney(s.floating, signed: true),
                sub: formatPct(s.floatingPct),
                color: mc.of(s.floating),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Metric(label: '当日盈亏', value: formatMoney(s.day, signed: true), color: mc.of(s.day))),
            Expanded(
                child: Metric(
                    label: '已实现盈亏', value: formatMoney(s.realized, signed: true), color: mc.of(s.realized))),
          ]),
          if (s.missingQuotes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('部分标的行情暂不可用，市值未计入', style: theme.textTheme.labelSmall),
            ),
        ]),
      ),
      if (open.isEmpty)
        const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('当前没有持仓'))),
      for (final h in open)
        _HoldingTile(
          holding: h,
          quote: quotes[h.code],
          name: names[h.code] ?? h.code,
          method: method,
          weight: s.marketValue == 0 || quotes[h.code] == null ? null : h.marketValue(quotes[h.code]!.price) / s.marketValue,
          days: h.holdingDays(now),
        ),
    ]);
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({
    required this.holding,
    required this.quote,
    required this.name,
    required this.method,
    required this.weight,
    required this.days,
  });
  final Holding holding;
  final Quote? quote;
  final String name;
  final CostMethod method;
  final double? weight;
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final h = holding;
    final q = quote;
    final cost = h.cost(method);
    final floating = q == null ? null : h.floating(q.price, method);
    final pct = q == null || h.costTotal(method) == 0 ? null : floating! / h.costTotal(method) * 100;
    final day = q == null ? null : h.dayPnl(q.price, q.preClose);
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => HoldingTradesPage(code: h.code, name: name))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                  Text(h.code, style: muted),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(floating == null ? '--' : formatMoney(floating, signed: true),
                    style: theme.textTheme.titleSmall?.copyWith(color: floating == null ? null : mc.of(floating))),
                Text(formatPct(pct), style: theme.textTheme.labelSmall?.copyWith(color: pct == null ? null : mc.of(pct))),
              ]),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text('持仓 ${h.qty}', style: muted)),
              Expanded(child: Text('成本 ${formatPrice(cost)}', style: muted)),
              Expanded(
                child: Text('现价 ${formatPrice(q?.price)}',
                    style: muted?.copyWith(color: q == null ? null : mc.of(q.changePct))),
              ),
            ]),
            Row(children: [
              Expanded(child: Text('市值 ${q == null ? '--' : formatMoney(h.marketValue(q.price))}', style: muted)),
              Expanded(
                child: Text('当日 ${day == null ? '--' : formatMoney(day, signed: true)}',
                    style: muted?.copyWith(color: day == null ? null : mc.of(day))),
              ),
              Expanded(
                child: Text(
                    '${weight == null ? '' : '占比 ${(weight! * 100).toStringAsFixed(1)}% · '}$days 天',
                    style: muted),
              ),
            ]),
            if (h.oversold)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('卖出数量超过持仓，交易流水可能不完整', style: muted?.copyWith(color: theme.colorScheme.error)),
              ),
          ]),
        ),
      ),
    );
  }
}

// ───────────── 交易 ─────────────

class TradeTile extends StatelessWidget {
  const TradeTile({super.key, required this.trade, required this.name, this.showName = true});
  final Trade trade;
  final String name;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final t = trade;
    final side = TradeSide.fromCode(t.side);
    final color = switch (side) {
      TradeSide.buy || TradeSide.init => mc.up,
      TradeSide.sell => mc.down,
      _ => theme.colorScheme.tertiary,
    };
    final fees = t.commission + t.stampTax + t.transferFee;
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(side?.label.substring(0, 1) ?? '?', style: TextStyle(color: color, fontSize: 13)),
      ),
      title: Text(showName ? '$name  ${side?.label ?? t.side}' : side?.label ?? t.side),
      subtitle: Text([
        formatDateTime(t.ts),
        if (side == TradeSide.dividend) '金额 ${formatMoney(t.amount)}' else '${formatPrice(t.price)} × ${t.qty}',
        if (fees > 0) '费 ${formatMoney(fees)}',
        if (t.source != 'manual') t.source == 'table' ? '表格导入' : '截图导入',
        if (t.revisionCount > 0) '改过 ${t.revisionCount} 次',
        if (t.note != null) t.note!,
      ].join(' · ')),
      trailing: side == TradeSide.dividend || side == TradeSide.bonus ? null : Text(formatMoney(t.amount)),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TradeFormPage(trade: t))),
    );
  }
}

class _TradesTab extends ConsumerWidget {
  const _TradesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(tradesProvider).value;
    if (trades == null) return const Center(child: CircularProgressIndicator());
    if (trades.isEmpty) return const _Empty();
    final names = ref.watch(tradeNamesProvider).value ?? const {};
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: trades.length,
      itemBuilder: (context, i) =>
          TradeTile(trade: trades[i], name: names[trades[i].instrumentCode] ?? trades[i].instrumentCode),
    );
  }
}

/// 某个标的的全部交易。
class HoldingTradesPage extends ConsumerWidget {
  const HoldingTradesPage({super.key, required this.code, required this.name});
  final String code;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = (ref.watch(tradesProvider).value ?? const <Trade>[]).where((t) => t.instrumentCode == code).toList();
    final h = ref.watch(portfolioProvider).holdings[code];
    final method = ref.watch(costMethodProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name),
          Text(code, style: theme.textTheme.labelSmall),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TradeFormPage(code: code, name: name, side: TradeSide.buy))),
            child: const Text('买入'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TradeFormPage(code: code, name: name, side: TradeSide.sell))),
            child: const Text('卖出'),
          ),
        ],
      ),
      body: ListView(children: [
        if (h != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '持仓 ${h.qty} · 成本 ${formatPrice(h.cost(method))}（${method.label}）'
              ' · 已实现 ${formatMoney(h.realized, signed: true)}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        for (final t in trades) TradeTile(trade: t, name: name, showName: false),
      ]),
    );
  }
}

// ───────────── 统计 ─────────────

class _StatsTab extends ConsumerWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(portfolioProvider);
    final names = ref.watch(tradeNamesProvider).value ?? const {};
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final trips = p.roundTrips;
    if (trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('还没有已清仓的交易。\n一只标的从买入到全部卖出算一笔完整交易，清仓后计入胜率与盈亏比。',
              textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.outline)),
        ),
      );
    }
    final all = TradeStats(trips);
    String month(RoundTrip t) {
      final m = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(t.closedAt, isUtc: true));
      return '${m.year}-${m.month.toString().padLeft(2, '0')}';
    }

    final byMonth = TradeStats.groupBy(trips, month).entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    final byCode = TradeStats.groupBy(trips, (t) => t.code).entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    Widget row(String label, TradeStats s) => ListTile(
          dense: true,
          title: Text(label),
          subtitle: Text('${s.count} 笔 · 胜率 ${(s.winRate * 100).toStringAsFixed(0)}%'),
          trailing: Text(formatMoney(s.total, signed: true),
              style: theme.textTheme.titleSmall?.copyWith(color: mc.of(s.total))),
        );

    return ListView(padding: const EdgeInsets.only(bottom: 88), children: [
      BoardCard(
        title: '已清仓交易',
        child: Column(children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Metric(label: '笔数', value: '${all.count}')),
            Expanded(child: Metric(label: '胜率', value: '${(all.winRate * 100).toStringAsFixed(0)}%')),
            Expanded(child: Metric(label: '盈亏比', value: all.payoff == null ? '--' : all.payoff!.toStringAsFixed(2))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Metric(label: '合计', value: formatMoney(all.total, signed: true), color: mc.of(all.total))),
            Expanded(child: Metric(label: '平均盈利', value: formatMoney(all.avgWin), color: mc.up)),
            Expanded(child: Metric(label: '平均亏损', value: formatMoney(-all.avgLoss), color: mc.down)),
          ]),
        ]),
      ),
      BoardCard(title: '按月份', child: Column(children: [for (final e in byMonth) row(e.key, e.value)])),
      BoardCard(
          title: '按标的',
          child: Column(children: [for (final e in byCode) row(names[e.key] ?? e.key, e.value)])),
      BoardCard(
        title: '每笔交易',
        child: Column(children: [
          for (final t in trips.reversed)
            ListTile(
              dense: true,
              title: Text(names[t.code] ?? t.code),
              subtitle: Text('${formatDateTime(t.openedAt)} → ${formatDateTime(t.closedAt)}'),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatMoney(t.pnl, signed: true), style: TextStyle(color: mc.of(t.pnl))),
                Text(formatPct(t.returnPct), style: theme.textTheme.labelSmall?.copyWith(color: mc.of(t.pnl))),
              ]),
            ),
        ]),
      ),
    ]);
  }
}
