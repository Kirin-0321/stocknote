import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/trading_session.dart';
import '../../data/db/app_database.dart';
import '../../domain/journal/entry_class.dart';
import '../../domain/journal/vocab.dart';
import 'widgets/attribute_chips.dart';
import 'widgets/highlighted_text.dart';

final _historyProvider =
    FutureProvider.autoDispose.family<(JournalEntry?, List<Revision>), String>((ref, id) async {
  final repo = ref.watch(journalRepositoryProvider);
  return (await repo.get(id), await repo.history(id));
});

/// 一条日记的修改历史：当前版本 + 每次修改前的版本（新 → 旧）。
class RevisionHistoryPage extends ConsumerWidget {
  const RevisionHistoryPage({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_historyProvider(entryId));
    return Scaffold(
      appBar: AppBar(title: const Text('修改历史')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (d) {
          final (current, revisions) = d;
          if (current == null) return const Center(child: Text('记录不存在'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _VersionCard(
                title: '当前版本（第 ${current.revisionCount} 版）',
                subtitle: '最后修改 ${formatDateTime(current.updatedAt)}',
                json: current.toJson(),
                highlight: true,
              ),
              for (final r in revisions.reversed)
                _VersionCard(
                  title: '第 ${r.revisionNo - 1} 版',
                  subtitle:
                      '${formatDateTime(r.ts)} 被修改：${r.changedFields.map((f) => journalFieldLabels[f] ?? f).join('、')}',
                  json: r.before,
                  changed: r.changedFields.toSet(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.title,
    required this.subtitle,
    required this.json,
    this.changed = const {},
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final Map<String, dynamic> json;
  final Set<String> changed;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = json['ts'] as int?;
    final session = json['session'] as String?;
    final tags = (json['tags'] as List?)?.cast<String>() ?? const [];
    TextStyle? mark(String field) => changed.contains(field)
        ? TextStyle(backgroundColor: theme.colorScheme.errorContainer)
        : null;

    return Card(
      elevation: highlight ? 1 : 0,
      color: highlight ? null : theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            Text(subtitle,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
            const Divider(height: 16),
            if (ts != null)
              Text(
                '${formatDateTime(ts)} · ${session == null ? '' : TradingSession.fromCode(session).label}',
                style: theme.textTheme.labelMedium?.merge(mark('ts')),
              ),
            const SizedBox(height: 4),
            Container(
              decoration: changed.contains('content')
                  ? BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4))
                  : null,
              child: HighlightedText(json['content'] as String? ?? ''),
            ),
            const SizedBox(height: 6),
            ClassTags(
              value: EntryClass(
                category: json['category'] as String?,
                subcategory: json['subcategory'] as String?,
                stance: json['stance'] as String?,
                action: json['action'] as String?,
                horizon: json['horizon'] as String?,
                emotion: json['emotion'] as String?,
              ),
            ),
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('标签：${tags.join('、')}', style: theme.textTheme.labelSmall?.merge(mark('tags'))),
              ),
          ],
        ),
      ),
    );
  }
}

