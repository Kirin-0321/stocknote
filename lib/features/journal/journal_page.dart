import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/trading_session.dart';
import '../../data/db/app_database.dart';
import 'edit_entry_sheet.dart';
import 'journal_providers.dart';
import 'revision_history_page.dart';
import 'search_page.dart';
import 'widgets/composer.dart';
import 'widgets/entry_card.dart';

/// 日记页：某交易日按时段分组的时间轴 + 底部快捷输入栏（spec 3.2）。
class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key, this.onOpenAgent});

  final VoidCallback? onOpenAgent;

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = ref.read(selectedDateProvider);
    final now = ref.read(clockProvider)();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: '选择日期（非交易日跳到下一交易日）',
    );
    if (picked != null) {
      ref
          .read(selectedDateProvider.notifier)
          .set(DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _openSearch() async {
    final date = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
    if (date != null) ref.read(selectedDateProvider.notifier).set(date);
  }

  void _afterSave() {
    final notifier = ref.read(selectedDateProvider.notifier);
    if (!notifier.isToday) notifier.goToday();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _showActions(JournalEntry entry) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑'),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text('修改历史（${entry.revisionCount}）'),
            enabled: entry.revisionCount > 0,
            onTap: () => Navigator.pop(context, 'history'),
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('复制内容'),
            onTap: () => Navigator.pop(context, 'copy'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: const Text('删除'),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ]),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        await showEditEntrySheet(context, entry);
      case 'history':
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RevisionHistoryPage(entryId: entry.id)));
      case 'copy':
        await Clipboard.setData(ClipboardData(text: entry.content));
      case 'delete':
        await deleteEntryWithUndo(context, ref, entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);
    final notifier = ref.read(selectedDateProvider.notifier);
    final today = notifier.today();
    final entries = ref.watch(dayEntriesProvider(date));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          tooltip: '前一交易日',
          icon: const Icon(Icons.chevron_left),
          onPressed: notifier.previous,
        ),
        title: InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateTitle(date, today: today)),
                Text(
                  date == today ? '今天' : '点击选择日期',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: '后一交易日',
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.next,
          ),
          if (date != today)
            TextButton(onPressed: notifier.goToday, child: const Text('今天')),
          IconButton(
            tooltip: '搜索',
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: entries.when(
              data: (list) => list.isEmpty
                  ? _EmptyDay(isToday: date == today)
                  : _Timeline(
                      entries: list,
                      controller: _scroll,
                      onTap: (e) => showEditEntrySheet(context, e),
                      onLongPress: _showActions,
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
            ),
          ),
          Composer(onSaved: _afterSave, onOpenAgent: widget.onOpenAgent),
        ],
      ),
    );
  }
}

/// 软删除并提供撤销。
Future<void> deleteEntryWithUndo(
    BuildContext context, WidgetRef ref, JournalEntry entry) async {
  final repo = ref.read(journalServiceProvider);
  final messenger = ScaffoldMessenger.of(context);
  await repo.delete(entry.id);
  messenger.showSnackBar(SnackBar(
    content: const Text('已删除'),
    action: SnackBarAction(label: '撤销', onPressed: () => repo.restore(entry.id)),
  ));
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.entries,
    required this.controller,
    required this.onTap,
    required this.onLongPress,
  });

  final List<JournalEntry> entries;
  final ScrollController controller;
  final ValueChanged<JournalEntry> onTap;
  final ValueChanged<JournalEntry> onLongPress;

  @override
  Widget build(BuildContext context) {
    final groups = groupBy(entries, (JournalEntry e) => TradingSession.fromCode(e.session));
    final sessions = TradingSession.values.where(groups.containsKey).toList();
    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        for (final s in sessions) ...[
          _SessionHeader(session: s, count: groups[s]!.length),
          for (final e in groups[s]!)
            EntryCard(
              key: ValueKey(e.id),
              entry: e,
              onTap: () => onTap(e),
              onLongPress: () => onLongPress(e),
            ),
        ],
      ],
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.session, required this.count});

  final TradingSession session;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: session.isMarketOpen
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(session.label, style: theme.textTheme.titleSmall),
        const SizedBox(width: 6),
        Text('$count', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
      ]),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.isToday});
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_note, size: 48, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          Text(
            isToday ? '今天还没有记录\n在下方输入第一条想法，回车即保存' : '这一天没有记录',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ]),
      ),
    );
  }
}

