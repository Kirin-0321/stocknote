import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/time/market_clock.dart';
import '../../../data/repo/prediction_repository.dart';
import '../../../domain/verify/stats.dart';
import '../../../domain/verify/verifier.dart';
import '../../journal/widgets/highlighted_text.dart';
import '../../market/widgets/market_widgets.dart';

Color statusColor(BuildContext context, VerifyStatus? s) => switch (s) {
      VerifyStatus.correct => const Color(0xFF43A047),
      VerifyStatus.partial => const Color(0xFFFFA000),
      VerifyStatus.wrong => const Color(0xFFE53935),
      VerifyStatus.pendingManual => const Color(0xFF8E24AA),
      null => Theme.of(context).colorScheme.outline,
    };

IconData statusIcon(VerifyStatus? s) => switch (s) {
      VerifyStatus.correct => Icons.check_circle,
      VerifyStatus.partial => Icons.adjust,
      VerifyStatus.wrong => Icons.cancel,
      VerifyStatus.pendingManual => Icons.help,
      null => Icons.schedule,
    };

String mmdd(String yyyymmdd) => '${int.parse(yyyymmdd.substring(4, 6))}/${int.parse(yyyymmdd.substring(6, 8))}';

/// 小徽标。
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.color, this.icon});
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(4)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 2)],
          Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ]),
      );
}

/// 复盘列表中的一条判断。
class PredictionCard extends StatelessWidget {
  const PredictionCard({super.key, required this.view, required this.name, this.onTap, this.verifiable = false});

  final PredictionView view;
  final String name;
  final VoidCallback? onTap;

  /// 已过到期时间但尚未判定（等待 K 线）
  final bool verifiable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = view.prediction;
    final r = view.result;
    final s = view.status;
    final mc = marketColors(context);
    final dirColor = switch (p.direction) { 'up' => mc.up, 'down' => mc.down, _ => mc.flat };
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
              ),
              const SizedBox(width: 6),
              Pill(directionLabels[p.direction] ?? p.direction, color: dirColor),
              const SizedBox(width: 4),
              Pill(horizonLabels[p.horizonType] ?? p.horizonType, color: theme.colorScheme.primary),
              const Spacer(),
              Icon(statusIcon(s), size: 16, color: statusColor(context, s)),
              const SizedBox(width: 3),
              Text(
                s?.label ?? (verifiable ? '待验证' : '到期 ${mmdd(p.dueDate)}'),
                style: theme.textTheme.labelMedium?.copyWith(color: statusColor(context, s)),
              ),
            ]),
            if (view.entry != null) ...[
              const SizedBox(height: 4),
              HighlightedText(view.entry!.content, maxLines: 2, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 6),
            // 各时点结果：当收 / 次开 / 次收 / T+3 / T+5（主时点加粗）
            Wrap(spacing: 8, runSpacing: 2, children: [
              for (final cp in view.plan.points.keys)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(cp.short,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: cp == view.primary ? FontWeight.w800 : null,
                        decoration: cp == view.primary ? TextDecoration.underline : null,
                      )),
                  const SizedBox(width: 2),
                  Icon(statusIcon(view.statusAt(cp)), size: 13, color: statusColor(context, view.statusAt(cp))),
                ]),
            ]),
            const SizedBox(height: 4),
            Wrap(spacing: 10, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (view.entry != null) Text(formatDateTime(view.entry!.ts), style: muted),
              if (p.basePrice != null)
                Text('基准 ${formatPrice(p.basePrice)}${r?.actualClose == null ? '' : ' → ${formatPrice(r!.actualClose)}'}',
                    style: muted),
              if (r?.changePct != null)
                Text(formatPct(r!.changePct), style: theme.textTheme.labelSmall?.copyWith(color: mc.of(r.changePct!))),
              if (r?.mfe != null && p.direction != 'range')
                Text('最大有利 ${formatPct(r!.mfe)} / 不利 ${formatPct(r.mae)}', style: muted),
              if (p.modifiedBeforeDue) Pill('已修改', color: theme.colorScheme.error),
              if (r?.isManual ?? false) Pill('手动', color: theme.colorScheme.tertiary),
              if (view.reviewed) Pill('已复盘', color: const Color(0xFF00897B), icon: Icons.done),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// yyyyMMdd → `11月16日`。
String formatDue(String d) => '${TradeDate.parse(d).month}月${TradeDate.parse(d).day}日';
