import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../data/market/market_service.dart';
import '../../data/market/models.dart';
import 'instrument_detail_page.dart';
import 'instrument_search_page.dart';
import 'market_providers.dart';
import 'widgets/market_widgets.dart';

/// 大盘看板（spec 3.1.1）。
class MarketPage extends ConsumerWidget {
  const MarketPage({super.key});

  static void openDetail(BuildContext context, String code, String name) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InstrumentDetailPage(code: code, name: name)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(marketOverviewProvider);
    final status = MarketStatus.of(ref.watch(tradingCalendarProvider), ref.watch(clockProvider)());
    final data = overview.value;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('大盘'),
          Text(
            '${status.label}${data == null ? '' : ' · 更新于 ${formatClock(data.fetchedAt)}'}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ]),
        actions: [
          IconButton(
            tooltip: '搜索标的',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const InstrumentSearchPage())),
          ),
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(marketOverviewProvider),
          ),
        ],
      ),
      body: data == null
          ? overview.hasError
              ? _ErrorView(error: overview.error.toString(), onRetry: () => ref.invalidate(marketOverviewProvider))
              : const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(marketOverviewProvider);
                await ref.read(marketOverviewProvider.future);
              },
              child: _Board(data: data),
            ),
    );
  }
}

String formatClock(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
}

class _Board extends ConsumerWidget {
  const _Board({required this.data});
  final MarketOverview data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(appConfigProvider.select((c) => c.watchlist));
    final indices = data.indices.where((q) => defaultBoardIndices.contains(q.code)).toList();
    final watched = data.indices.where((q) => watchlist.contains(q.code)).toList();
    final mc = marketColors(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        // 指数
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.25,
            children: [
              for (final q in indices)
                IndexTile(
                    quote: q,
                    onTap: () => MarketPage.openDetail(context, q.code, indexShortNames[q.code] ?? q.name)),
            ],
          ),
        ),
        if (data.errors.containsKey('indices') && indices.isEmpty)
          const _InlineError('指数行情暂不可用'),

        // 市场宽度
        BoardCard(
          title: '市场情绪',
          error: data.errors['limits'],
          hasData: data.limits != null,
          child: Column(children: [
            if (data.breadth != null)
              BreadthBar(breadth: data.breadth!)
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text('涨跌家数暂不可用（东方财富限流时无备用源）',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Metric(
                      label: '涨停', value: '${data.limits?.limitUp ?? '--'}', color: mc.up)),
              Expanded(
                  child: Metric(
                      label: '跌停', value: '${data.limits?.limitDown ?? '--'}', color: mc.down)),
              Expanded(
                  child: Metric(
                      label: '炸板率',
                      value: data.limits?.brokenRate == null
                          ? '--'
                          : '${data.limits!.brokenRate!.toStringAsFixed(1)}%')),
            ]),
          ]),
        ),

        // 成交额
        BoardCard(
          title: '两市成交额',
          error: data.errors['turnover'],
          hasData: data.turnover != null,
          child: Row(children: [
            Expanded(
              child: Metric(label: '今日', value: formatAmount(data.turnover?.today)),
            ),
            Expanded(
              child: Metric(
                label: '较昨日同时段',
                value: formatPct(data.turnover?.changePct),
                sub: data.turnover?.changePct == null
                    ? null
                    : (data.turnover!.changePct! >= 0 ? '放量' : '缩量'),
                color: data.turnover?.changePct == null ? null : mc.of(data.turnover!.changePct!),
              ),
            ),
            Expanded(
              child: Metric(label: '昨日全天', value: formatAmount(data.turnover?.yesterdayTotal)),
            ),
          ]),
        ),

        if (watchlist.isNotEmpty)
          BoardCard(
            title: '自选',
            child: Column(children: [
              for (final (i, q) in watched.indexed)
                RankRow(
                  index: i + 1,
                  item: RankItem(code: q.code, name: q.name, changePct: q.changePct, price: q.price, amount: q.amount),
                  showAmount: true,
                  onTap: () => MarketPage.openDetail(context, q.code, q.name),
                ),
              if (watched.isEmpty) const Text('自选标的行情加载中…'),
            ]),
          ),

        _SectorCard(data: data),

        BoardCard(
          title: '热门 ETF（成交额）',
          error: data.errors['etf'],
          hasData: data.hotEtfs.isNotEmpty,
          child: Column(children: [
            for (final (i, e) in data.hotEtfs.indexed)
              RankRow(
                index: i + 1,
                item: e,
                showAmount: true,
                onTap: () => MarketPage.openDetail(context, e.code, e.name),
              ),
            if (data.hotEtfs.isEmpty) const Text('暂无数据'),
          ]),
        ),

        if (data.errors.isNotEmpty) _SourceNote(errors: data.errors),
      ],
    );
  }
}

class _SectorCard extends StatefulWidget {
  const _SectorCard({required this.data});
  final MarketOverview data;

  @override
  State<_SectorCard> createState() => _SectorCardState();
}

class _SectorCardState extends State<_SectorCard> {
  var _kind = SectorKind.industry;
  var _top = true;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final list = switch ((_kind, _top)) {
      (SectorKind.industry, true) => d.industryTop,
      (SectorKind.industry, false) => d.industryBottom,
      (SectorKind.concept, true) => d.conceptTop,
      (SectorKind.concept, false) => d.conceptBottom,
    };
    return BoardCard(
      title: '板块',
      error: d.errors[_kind == SectorKind.industry ? 'industry' : 'concept'],
      hasData: list.isNotEmpty,
      trailing: SegmentedButton<bool>(
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: true, label: Text('涨幅')),
          ButtonSegment(value: false, label: Text('跌幅')),
        ],
        selected: {_top},
        onSelectionChanged: (s) => setState(() => _top = s.first),
      ),
      child: Column(children: [
        Row(children: [
          ChoiceChip(
            label: const Text('行业'),
            selected: _kind == SectorKind.industry,
            onSelected: (_) => setState(() => _kind = SectorKind.industry),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('概念'),
            selected: _kind == SectorKind.concept,
            onSelected: (_) => setState(() => _kind = SectorKind.concept),
          ),
          const Spacer(),
          Text('领涨股', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 24),
        ]),
        const SizedBox(height: 4),
        for (final (i, s) in list.indexed)
          RankRow(
            index: i + 1,
            item: s,
            onTap: () => MarketPage.openDetail(context, s.code, s.name),
          ),
        if (list.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('暂无数据')),
      ]),
    );
  }
}

class _SourceNote extends StatelessWidget {
  const _SourceNote({required this.errors});
  final Map<String, String> errors;

  static const _labels = {
    'indices': '指数',
    'breadth': '涨跌家数',
    'limits': '涨跌停',
    'turnover': '成交额',
    'industry': '行业板块',
    'concept': '概念板块',
    'etf': 'ETF',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        '部分数据获取失败：${errors.keys.map((k) => _labels[k] ?? k).join('、')}。'
        '免费行情源可能被临时限流，会自动重试；可在 设置 → 数据源 查看状态。',
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 8),
            Text('行情加载失败\n$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ]),
        ),
      );
}


