import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/format.dart';
import '../../../data/db/app_database.dart';
import '../../../data/market/models.dart';
import '../../market/widgets/market_widgets.dart';

final snapshotProvider = FutureProvider.autoDispose.family<MarketSnapshot?, String>(
    (ref, id) => ref.watch(snapshotRepositoryProvider).get(id));

/// 代码 → 名称（快照里没取到行情的标的也要显示名称）。key 为逗号连接的代码。
final _namesProvider = FutureProvider.autoDispose.family<Map<String, String>, String>((ref, joined) async {
  final codes = joined.split(',').where((c) => c.isNotEmpty);
  final rows = await ref.watch(instrumentRepositoryProvider).getMany(codes);
  return {for (final c in codes) c: indexShortNames[c] ?? rows[c]?.name ?? c};
});

/// 日记条目下方的行情行：记录时刻的上证指数 + 全部 `$` 关联标的。
///
/// 没取到行情的标的显示名称和"--"；估算值（板块由成分股推算）前加 ≈。
class SnapshotLine extends ConsumerWidget {
  const SnapshotLine({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = entry.snapshotId == null ? null : ref.watch(snapshotProvider(entry.snapshotId!)).value;
    final codes = entry.instrumentCodes.where((c) => c.contains('.')).toList();
    final names = ref.watch(_namesProvider(codes.join(','))).value ?? const {};
    if (snap == null && codes.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final mc = marketColors(context);
    final style = theme.textTheme.labelSmall;
    final inst = (snap?.extra?['instruments'] as Map?)?.cast<String, dynamic>() ?? const {};

    final items = <(String, Map<String, dynamic>?)>[];
    final sh = snap?.indices['000001.SH'];
    if (sh is Map) items.add(('上证', sh.cast<String, dynamic>()));
    for (final c in codes) {
      if (c == '000001.SH' && sh is Map) continue;
      final q = inst[c] ?? snap?.indices[c];
      final name = (q is Map ? q['name'] as String? : null) ?? names[c] ?? c;
      items.add((name, q is Map ? q.cast<String, dynamic>() : null));
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 10, runSpacing: 2, children: [
        Icon(Icons.show_chart, size: 12, color: theme.colorScheme.outline),
        for (final (name, q) in items)
          Text.rich(TextSpan(style: style, children: [
            TextSpan(text: '$name ', style: TextStyle(color: theme.colorScheme.outline)),
            if (q == null)
              TextSpan(text: '--', style: TextStyle(color: theme.colorScheme.outline))
            else
              TextSpan(
                text: '${q['approx'] == true ? '≈' : ''}'
                    '${formatPrice((q['price'] as num?)?.toDouble())} '
                    '${formatPct((q['pct'] as num?)?.toDouble())}',
                style: TextStyle(color: mc.of((q['pct'] as num?) ?? 0)),
              ),
          ])),
      ]),
    );
  }
}
