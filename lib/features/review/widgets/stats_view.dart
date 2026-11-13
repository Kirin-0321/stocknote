import 'package:material_ui/material_ui.dart';

import '../../../data/repo/prediction_repository.dart';
import '../../../domain/journal/vocab.dart';
import '../../../domain/verify/stats.dart';
import '../../../domain/verify/verifier.dart';
import 'prediction_card.dart';

/// 准确率统计（spec 3.3.5）。
class StatsView extends StatefulWidget {
  const StatsView({super.key, required this.views});
  final List<PredictionView> views;

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  var _excludeModified = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = PredictionStats.compute(widget.views, excludeModified: _excludeModified);
    final o = s.overall;
    String pct(double v) => '${(v * 100).toStringAsFixed(0)}%';

    return ListView(padding: const EdgeInsets.only(bottom: 88), children: [
      Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(o.decided == 0 ? '--' : pct(o.accuracy),
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('正确率', style: theme.textTheme.labelLarge),
              ),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(o.decided == 0 ? '--' : pct(o.directional), style: theme.textTheme.titleLarge),
                Text('方向正确率（含部分正确）', style: theme.textTheme.labelSmall),
              ]),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 6, children: [
              Pill('正确 ${o.correct}', color: statusColor(context, VerifyStatus.correct)),
              Pill('部分 ${o.partial}', color: statusColor(context, VerifyStatus.partial)),
              Pill('错误 ${o.wrong}', color: statusColor(context, VerifyStatus.wrong)),
              if (o.manualPending > 0)
                Pill('待手动 ${o.manualPending}', color: statusColor(context, VerifyStatus.pendingManual)),
              Pill('进行中 ${s.pending}', color: theme.colorScheme.outline),
            ]),
            const Divider(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('排除到期前修改过的判断'),
              subtitle: Text('共 ${s.modified} 条修改过，排除后统计更诚实'),
              value: _excludeModified,
              onChanged: (v) => setState(() => _excludeModified = v),
            ),
          ]),
        ),
      ),
      _Breakdown(title: '按方向', buckets: {
        for (final e in s.byDirection.entries) directionLabels[e.key] ?? e.key: e.value,
      }),
      _Breakdown(title: '按对象', buckets: {
        for (final e in s.byTarget.entries) byCode(JudgeTarget.values, e.key)?.label ?? '其他': e.value,
      }),
      _Breakdown(title: '按周期', buckets: {
        for (final e in s.byHorizon.entries) horizonLabels[e.key] ?? e.key: e.value,
      }),
      if (s.byConfidence.length > 1)
        _Breakdown(title: '按信心度', buckets: {
          for (final e in (s.byConfidence.entries.toList()..sort((a, b) => a.key.compareTo(b.key))))
            '★' * e.key: e.value,
        }),
      if (o.decided == 0)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text('还没有已判定的判断。\n在日记中记录"判断"类条目（选对象、方向、周期），到期后会自动验证。',
              textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.outline)),
        ),
    ]);
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.title, required this.buckets});
  final String title;
  final Map<String, StatBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = buckets.entries.where((e) => e.value.decided > 0).toList()
      ..sort((a, b) => b.value.decided.compareTo(a.value.decided));
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final e in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(width: 64, child: Text(e.key, style: theme.textTheme.bodySmall)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: e.value.accuracy,
                      minHeight: 8,
                      color: statusColor(context, VerifyStatus.correct),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    '${(e.value.accuracy * 100).toStringAsFixed(0)}%  (${e.value.correct}/${e.value.decided})',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

