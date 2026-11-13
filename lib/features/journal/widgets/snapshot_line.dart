import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../data/db/app_database.dart';
import '../../market/widgets/market_widgets.dart';

final snapshotProvider = FutureProvider.autoDispose.family<MarketSnapshot?, String>(
    (ref, id) => ref.watch(snapshotRepositoryProvider).get(id));

/// 日记条目下方的一行行情快照：上证涨跌 + 关联标的涨跌。
class SnapshotLine extends ConsumerWidget {
  const SnapshotLine({super.key, required this.snapshotId});

  final String snapshotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapshotProvider(snapshotId)).value;
    if (snap == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final style = theme.textTheme.labelSmall;

    final items = <(String, Map<String, dynamic>)>[];
    final sh = snap.indices['000001.SH'];
    if (sh is Map) items.add(('上证', sh.cast<String, dynamic>()));
    final inst = snap.extra?['instruments'];
    if (inst is Map) {
      for (final e in inst.entries) {
        items.add(((e.value as Map)['name'] as String? ?? e.key as String, (e.value as Map).cast()));
      }
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 10, children: [
        Icon(Icons.show_chart, size: 12, color: theme.colorScheme.outline),
        for (final (name, q) in items)
          Text.rich(TextSpan(style: style, children: [
            TextSpan(text: '$name ', style: TextStyle(color: theme.colorScheme.outline)),
            TextSpan(
              text: '${formatPrice((q['price'] as num?)?.toDouble())} ${formatPct((q['pct'] as num?)?.toDouble())}',
              style: TextStyle(color: mc.of((q['pct'] as num?) ?? 0)),
            ),
          ])),
      ]),
    );
  }
}
