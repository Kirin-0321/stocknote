import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../data/market/code_util.dart';
import '../../../data/market/models.dart';
import '../../../domain/journal/entry_class.dart';
import '../../../domain/journal/entry_parser.dart';
import '../../../domain/journal/vocab.dart';
import '../journal_providers.dart';
import 'composer_toolbar.dart';
import 'instrument_suggest.dart';

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
  late final _suggest =
      InstrumentSuggestController(_controller, ref.read(instrumentRepositoryProvider));
  var _cls = EntryClass.empty;
  var _panel = ComposerPanel.none;
  var _expanded = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus && !_expanded) setState(() => _expanded = true);
    });
    _suggest.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _suggest.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // 联想列表打开时，回车优先选中第一项
    if (_suggest.active && _suggest.results.isNotEmpty) {
      _suggest.choose(_suggest.results.first);
      _focus.requestFocus();
      return;
    }
    final parsed = EntryParser.parse(_controller.text);
    if (parsed.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final codes = await _suggest.resolve(parsed.instrumentRefs);
      final repo = ref.read(journalRepositoryProvider);
      final entry = await repo.create(
        content: parsed.content,
        classification: inferJudgeTarget(_cls, codes),
        tags: parsed.tags,
        instrumentCodes: codes,
      );
      _controller.clear();
      _suggest.reset();
      _panel = ComposerPanel.none;
      // 连续记录时保留一级分类，清空二级与情绪
      setState(() => _cls = EntryClass.empty.withCategory(_cls.categoryEnum));
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
            // 按钮上方的弹出匹配列表：$ 标的联想优先，其次是工具栏按钮打开的列表
            if (_suggest.active)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: InstrumentSuggestPanel(controller: _suggest),
              )
            else if (_expanded && _panel != ComposerPanel.none)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ChoicePanel(
                  key: ValueKey(_panel),
                  sections: _panel == ComposerPanel.phrases
                      ? [
                          (
                            null,
                            [
                              for (final p in phrases)
                                PanelItem(
                                  key: 'opt-phrase-${p.id}',
                                  label: p.phrase,
                                  badge: '快捷',
                                  onTap: () {
                                    _insertPhrase(p.phrase);
                                    setState(() => _panel = ComposerPanel.none);
                                  },
                                ),
                            ]
                          ),
                        ]
                      : classificationSections(
                          context,
                          panel: _panel,
                          value: _cls,
                          onChanged: (v) => setState(() => _cls = v),
                          onAdvance: (p) => setState(() => _panel = p),
                        ),
                  empty: _panel == ComposerPanel.phrases ? '还没有常用短语，可在 设置 → 常用短语 添加' : null,
                ),
              ),
            if (_expanded)
              ComposerToolbar(
                value: _cls,
                open: _suggest.active ? ComposerPanel.none : _panel,
                onToggle: (p) {
                  if (_suggest.active) _suggest.dismiss();
                  setState(() => _panel = p);
                },
              ),
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
                        hintText: isToday
                            ? (_cls.categoryEnum?.hint ?? '记录想法，回车保存  #标签 \$代码')
                            : '将记录到今天',
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
                        setState(() {
                          _expanded = false;
                          _panel = ComposerPanel.none;
                        });
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

/// 判断未选对象但关联了标的时，按标的类型自动补全判断对象。
EntryClass inferJudgeTarget(EntryClass cls, List<String> codes) {
  if (cls.categoryEnum != EntryCategory.judge || cls.subcategory != null) return cls;
  final code = codes.where((c) => c.contains('.')).firstOrNull;
  if (code == null) return cls;
  final target = switch (Codes.guessType(code)) {
    InstrumentType.stock => JudgeTarget.stock,
    InstrumentType.etf => JudgeTarget.etf,
    InstrumentType.sector => JudgeTarget.sector,
    InstrumentType.marketIndex =>
      code == '000001.SH' ? JudgeTarget.market : JudgeTarget.marketIndex,
  };
  return cls.withField(TagField.subcategory, target.code);
}


