import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/market_clock.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/journal_repository.dart';
import '../../domain/journal/entry_parser.dart';
import 'journal_page.dart';
import 'revision_history_page.dart';
import 'widgets/attribute_chips.dart';

Future<void> showEditEntrySheet(BuildContext context, JournalEntry entry) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => EditEntrySheet(entry: entry),
  );
}

/// 编辑一条日记：内容、要素、时间。保存时自动写入修改历史。
class EditEntrySheet extends ConsumerStatefulWidget {
  const EditEntrySheet({super.key, required this.entry});

  final JournalEntry entry;

  @override
  ConsumerState<EditEntrySheet> createState() => _EditEntrySheetState();
}

class _EditEntrySheetState extends ConsumerState<EditEntrySheet> {
  late final _controller = TextEditingController(text: widget.entry.content);
  late var _cls = widget.entry.classification;
  late var _ts = widget.entry.ts;
  var _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final m = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(_ts, isUtc: true));
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(m.year, m.month, m.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(m.year + 1, 12, 31),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m.hour, minute: m.minute),
    );
    if (time == null) return;
    setState(() {
      _ts = MarketClock.fromMarket(date.year, date.month, date.day, time.hour, time.minute)
          .millisecondsSinceEpoch;
    });
  }

  Future<void> _save() async {
    final parsed = EntryParser.parse(_controller.text);
    if (parsed.isEmpty) return;
    setState(() => _saving = true);
    final codes =
        await ref.read(instrumentRepositoryProvider).resolveRefs(parsed.instrumentRefs);
    await ref.read(journalRepositoryProvider).update(
          widget.entry.id,
          content: parsed.content,
          classification: _cls,
          tags: parsed.tags,
          instrumentCodes: codes,
          at: _ts == widget.entry.ts
              ? null
              : DateTime.fromMillisecondsSinceEpoch(_ts, isUtc: true),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('编辑记录', style: theme.textTheme.titleMedium),
              const Spacer(),
              ActionChip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: Text(formatDateTime(_ts)),
                onPressed: _pickTime,
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              key: const Key('edit-content'),
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 10,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            CategoryForm(value: _cls, onChanged: (v) => setState(() => _cls = v)),
            const SizedBox(height: 16),
            Row(children: [
              TextButton.icon(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                label: Text('删除', style: TextStyle(color: theme.colorScheme.error)),
                onPressed: () async {
                  Navigator.pop(context);
                  await deleteEntryWithUndo(context, ref, widget.entry);
                },
              ),
              if (widget.entry.revisionCount > 0)
                TextButton.icon(
                  icon: const Icon(Icons.history),
                  label: Text('历史 ${widget.entry.revisionCount}'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RevisionHistoryPage(entryId: widget.entry.id))),
                ),
              const Spacer(),
              FilledButton(
                key: const Key('edit-save'),
                onPressed: _saving ? null : _save,
                child: const Text('保存'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

