import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/format.dart';
import '../../../data/market/models.dart';

MarketColors marketColors(BuildContext context) =>
    Theme.of(context).extension<MarketColors>() ?? MarketColors.redUp;

/// 看板卡片容器。
class BoardCard extends StatelessWidget {
  const BoardCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.error,
    this.hasData = true,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? error;

  /// 出错时是否仍有上次的数据可展示。
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(title, style: theme.textTheme.titleSmall),
              const Spacer(),
              ?trailing,
            ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(hasData ? '刷新失败，显示的是上次数据' : '暂不可用（数据源被限流或不支持）',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// 指数小卡片。
class IndexTile extends StatelessWidget {
  const IndexTile({super.key, required this.quote, this.onTap});

  final Quote quote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = marketColors(context).of(quote.change);
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              Text(indexShortNames[quote.code] ?? quote.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(formatPrice(quote.price),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                '${quote.change >= 0 ? '+' : ''}${quote.change.toStringAsFixed(2)}  ${formatPct(quote.changePct)}',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 涨跌家数条。
class BreadthBar extends StatelessWidget {
  const BreadthBar({super.key, required this.breadth});
  final Breadth breadth;

  @override
  Widget build(BuildContext context) {
    final mc = marketColors(context);
    final theme = Theme.of(context);
    final total = breadth.total == 0 ? 1 : breadth.total;
    Widget seg(int n, Color c) => Expanded(
          flex: (n * 1000 / total).round().clamp(1, 1000),
          child: Container(height: 8, color: c),
        );
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(children: [
          seg(breadth.up, mc.up),
          seg(breadth.flat, mc.flat),
          seg(breadth.down, mc.down),
        ]),
      ),
      const SizedBox(height: 6),
      Row(children: [
        Text('涨 ${breadth.up}', style: theme.textTheme.labelMedium?.copyWith(color: mc.up)),
        const Spacer(),
        Text('平 ${breadth.flat}', style: theme.textTheme.labelMedium?.copyWith(color: mc.flat)),
        const Spacer(),
        Text('跌 ${breadth.down}', style: theme.textTheme.labelMedium?.copyWith(color: mc.down)),
      ]),
    ]);
  }
}

/// 一个数值指标（标签 + 值）。
class Metric extends StatelessWidget {
  const Metric({super.key, required this.label, required this.value, this.color, this.sub});

  final String label;
  final String value;
  final String? sub;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
        if (sub != null)
          Text(sub!, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

/// 排行榜一行。
class RankRow extends StatelessWidget {
  const RankRow({super.key, required this.index, required this.item, this.onTap, this.showAmount = false});

  final int index;
  final RankItem item;
  final VoidCallback? onTap;
  final bool showAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = marketColors(context).of(item.changePct);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          SizedBox(
            width: 22,
            child: Text('$index',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
          ),
          Expanded(
            flex: 5,
            child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 4,
            child: Text(
              showAmount ? formatAmount(item.amount) : (item.leaderName ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          SizedBox(
            width: 68,
            child: Text(formatPct(item.changePct),
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}
