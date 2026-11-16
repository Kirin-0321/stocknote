import '../../data/agent/agent_service.dart';
import '../agent/agent_chat_page.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/market_clock.dart';
import '../../data/market/code_util.dart';
import '../../data/market/models.dart';
import 'market_providers.dart';
import 'widgets/charts.dart';
import 'widgets/market_widgets.dart';

/// 单个标的的实时报价（交易时段按设置间隔刷新）。
final _quoteProvider = StreamProvider.autoDispose.family<Quote, String>((ref, code) {
  final service = ref.watch(marketServiceProvider);
  final refresh = ref.watch(appConfigProvider.select((c) => c.refreshSeconds));
  final controller = StreamController<Quote>();
  Timer? timer;
  var disposed = false;
  Future<void> tick() async {
    try {
      final q = await service.quotes([code]);
      if (!disposed && q.isNotEmpty) controller.add(q.first);
    } catch (e, st) {
      if (!disposed) controller.addError(e, st);
    }
    if (disposed) return;
    final live =
        MarketStatus.of(ref.read(tradingCalendarProvider), ref.read(clockProvider)()).live;
    timer = Timer(Duration(seconds: live ? refresh : 120), tick);
  }

  tick();
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

final _intradayProvider = FutureProvider.autoDispose.family<Intraday, String>(
    (ref, code) => ref.watch(marketServiceProvider).intraday(code));

final _dailyProvider = FutureProvider.autoDispose.family<List<KBar>, String>((ref, code) {
  final now = MarketClock.marketDate(ref.watch(clockProvider)());
  final from = TradeDate.format(now.subtract(const Duration(days: 200)));
  return ref.watch(marketServiceProvider).dailyKline(code, from: from);
});

final _membersProvider = FutureProvider.autoDispose.family<List<RankItem>, String>(
    (ref, code) => ref.watch(marketServiceProvider).sectorMembers(code));

/// 标的详情：报价 + 分时 / 日 K；板块额外显示成分股。
class InstrumentDetailPage extends ConsumerStatefulWidget {
  const InstrumentDetailPage({super.key, required this.code, required this.name});

  final String code;
  final String name;

  @override
  ConsumerState<InstrumentDetailPage> createState() => _InstrumentDetailPageState();
}

class _InstrumentDetailPageState extends ConsumerState<InstrumentDetailPage> {
  var _chart = 0; // 0 分时，1 日K

  @override
  Widget build(BuildContext context) {
    final quote = ref.watch(_quoteProvider(widget.code));
    final watched = ref.watch(appConfigProvider.select((c) => c.watchlist.contains(widget.code)));
    final isSector = Codes.guessType(widget.code) == InstrumentType.sector;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.name),
          Text(widget.code, style: theme.textTheme.labelSmall),
        ]),
        actions: [
          IconButton(
            tooltip: '问 AI',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AgentChatPage(
                    pageContext: AgentPageContext(
                        label: '${widget.name}（${widget.code}）',
                        text: '用户正在看 ${widget.name}（${widget.code}）的行情页，问题默认针对这个标的。')))),
          ),
          IconButton(
            tooltip: watched ? '取消自选' : '加入自选',
            icon: Icon(watched ? Icons.star : Icons.star_border),
            onPressed: () => ref.read(appConfigProvider.notifier).toggleWatch(widget.code),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          quote.when(
            data: (q) => _QuoteHeader(quote: q),
            loading: () => const SizedBox(height: 96, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('报价获取失败：$e')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('分时')),
                ButtonSegment(value: 1, label: Text('日K')),
              ],
              selected: {_chart},
              onSelectionChanged: (s) => setState(() => _chart = s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 12, 4),
            child: _chart == 0
                ? ref.watch(_intradayProvider(widget.code)).when(
                      data: (d) => IntradayChart(data: d),
                      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => SizedBox(height: 220, child: Center(child: Text('分时获取失败：$e'))),
                    )
                : ref.watch(_dailyProvider(widget.code)).when(
                      data: (bars) => CandleChart(bars: bars),
                      loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => SizedBox(height: 240, child: Center(child: Text('日K获取失败：$e'))),
                    ),
          ),
          if (_chart == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Container(width: 12, height: 2, color: Colors.amber.shade700),
                const Text(' MA5   ', style: TextStyle(fontSize: 11)),
                Container(width: 12, height: 2, color: Colors.purple.shade300),
                const Text(' MA20', style: TextStyle(fontSize: 11)),
              ]),
            ),
          if (isSector) _Members(code: widget.code),
        ],
      ),
    );
  }
}

class _QuoteHeader extends StatelessWidget {
  const _QuoteHeader({required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = marketColors(context).of(quote.change);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(formatPrice(quote.price),
              style: theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
          Text(
            '${quote.change >= 0 ? '+' : ''}${quote.change.toStringAsFixed(quote.price < 10 ? 3 : 2)}   ${formatPct(quote.changePct)}',
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ]),
        const SizedBox(width: 24),
        Expanded(
          child: Wrap(spacing: 16, runSpacing: 4, children: [
            _kv(context, '今开', formatPrice(quote.open)),
            _kv(context, '最高', formatPrice(quote.high)),
            _kv(context, '最低', formatPrice(quote.low)),
            _kv(context, '昨收', formatPrice(quote.preClose)),
            _kv(context, '成交额', formatAmount(quote.amount)),
          ]),
        ),
      ]),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    final t = Theme.of(context).textTheme;
    return Text.rich(TextSpan(children: [
      TextSpan(text: '$k ', style: t.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
      TextSpan(text: v, style: t.labelMedium),
    ]));
  }
}

class _Members extends ConsumerWidget {
  const _Members({required this.code});
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(_membersProvider(code));
    return BoardCard(
      title: '成分股（按涨幅）',
      child: members.when(
        data: (list) => Column(children: [
          for (final (i, m) in list.indexed)
            RankRow(
              index: i + 1,
              item: m,
              showAmount: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => InstrumentDetailPage(code: m.code, name: m.name))),
            ),
        ]),
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('成分股获取失败：$e'),
      ),
    );
  }
}
