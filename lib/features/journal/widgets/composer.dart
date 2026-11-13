import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../domain/journal/entry_parser.dart';
import '../journal_providers.dart';
import 'attribute_chips.dart';

/// 日记页底部常驻的快捷输入栏（spec 3.2.2）。
///
/// 回车即保存一条，焦点保持在输入框，可连续分条记录。
class Composer extends ConsumerStatefulWidget {
  const Composer({super.key, this.onSaved, this.onOpenAgent});

  /// 保存后回调（用于跳回今天并滚动到底部）。
  final VoidCallback? onSaved;
  final VoidCallback? onOpenAgent;

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  var _attrs = EntryAttributes.empty;
  var _expanded = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus && !_expanded) setState(() => _expanded = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsed = EntryParser.parse(_controller.text);
    if (parsed.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final codes =
          await ref.read(instrumentRepositoryProvider).resolveRefs(parsed.instrumentRefs);
      final repo = ref.read(journalRepositoryProvider);
      final entry = await repo.create(
        content: parsed.content,
        stance: _attrs.stance?.code,
        action: _attrs.action?.code,
        emotion: _attrs.emotion?.code,
        tags: parsed.tags,
        instrumentCodes: codes,
      );
      _controller.clear();
      setState(() => _attrs = EntryAttributes.empty);
      widget.onSaved?.call();
      // 行情快照在后台抓取，不阻塞连续记录
      final snapshots = ref.read(snapshotServiceProvider);
      unawaited(snapshots.capture(codes).then((s) {
        if (s != null) repo.attachSnapshot(entry.id, s.id);
      }).catchError((_) {}));
    } finally {
      if (mounted) setState(() => _saving = false);
      _focus.requestFocus();
    }
  }

  void _insertPhrase(String phrase) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final needsSpace = start > 0 && !RegExp(r'[\s，,。]$').hasMatch(text.substring(0, start));
    final insert = '${needsSpace ? '，' : ''}$phrase';
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, insert),
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = ref.watch(selectedDateProvider.notifier).isToday;
    ref.watch(selectedDateProvider);
    final phrases = ref.watch(quickPhrasesProvider).value ?? const [];

    return Material(
      elevation: 3,
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_expanded) ...[
              const SizedBox(height: 8),
              AttributeBar(value: _attrs, onChanged: (v) => setState(() => _attrs = v)),
              if (phrases.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final p in phrases)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(p.phrase),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _insertPhrase(p.phrase),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'AI 助手',
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: widget.onOpenAgent,
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('composer-input'),
                      controller: _controller,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        hintText: isToday ? '记录想法，回车保存  #标签 \$代码' : '将记录到今天',
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (_expanded)
                    IconButton(
                      tooltip: '收起',
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () {
                        _focus.unfocus();
                        setState(() => _expanded = false);
                      },
                    ),
                  IconButton.filled(
                    key: const Key('composer-send'),
                    tooltip: '保存',
                    icon: const Icon(Icons.send),
                    onPressed: _saving ? null : _save,
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
