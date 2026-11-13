import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repo/journal_repository.dart';
import 'attribute_chips.dart';
import 'highlighted_text.dart';
import 'snapshot_line.dart';

/// 时间轴上的一条日记。
class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
    this.showDate = false,
  });

  final JournalEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: showDate ? 92 : 44,
              child: Text(
                showDate ? formatDateTime(entry.ts) : formatTime(entry.ts),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.outline, height: 1.9),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(entry.content),
                  if (entry.snapshotId != null) SnapshotLine(snapshotId: entry.snapshotId!),
                  if (entry.classification.labels().isNotEmpty ||
                      entry.emotion != null ||
                      entry.revisionCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(children: [
                        Flexible(child: ClassTags(value: entry.classification)),
                        const Spacer(),
                        if (entry.revisionCount > 0)
                          Text('已修改 ${entry.revisionCount} 次', style: muted),
                      ]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

