import 'package:material_ui/material_ui.dart';

import '../../../data/db/app_database.dart';
import '../../../data/market/models.dart';
import '../../../data/repo/instrument_repository.dart';

/// 输入 `$` 后的标的联想：监听输入框，识别光标前正在输入的 `$xxx`，
/// 按代码 / 名称 / 首字母搜索指数、板块题材、ETF、个股，选中后替换为 `$名称 ` 并记住对应代码。
class InstrumentSuggestController extends ChangeNotifier {
  InstrumentSuggestController(this.text, this.repo) {
    text.addListener(_onText);
  }

  final TextEditingController text;
  final InstrumentRepository repo;

  /// 已选择的 名称(大写) → 规范代码，保存时优先使用，避免同名歧义。
  final Map<String, String> picked = {};

  List<Instrument> results = const [];

  /// 当前正在输入的 `$` 查询词；null 表示不在 `$` 输入状态。
  String? query;
  int _tokenStart = -1;
  int _seq = 0;

  static final _token = RegExp(r'[$￥]([^\s$￥#＃,，。;；!！?？、]*)$');

  bool get active => query != null;

  void _onText() {
    final sel = text.selection;
    final caret = sel.isValid && sel.isCollapsed ? sel.baseOffset : text.text.length;
    final before = text.text.substring(0, caret.clamp(0, text.text.length));
    final m = _token.firstMatch(before);
    if (m == null) {
      if (query != null) {
        query = null;
        results = const [];
        notifyListeners();
      }
      return;
    }
    final q = m.group(1)!;
    _tokenStart = m.start;
    if (q == query) return;
    query = q;
    if (q.isEmpty) {
      results = const [];
      notifyListeners();
      return;
    }
    final seq = ++_seq;
    repo.search(q, limit: 12).then((r) {
      if (seq != _seq || query == null) return;
      results = r;
      notifyListeners();
    });
    notifyListeners();
  }

  void choose(Instrument i) {
    final value = text.value;
    final caret = value.selection.isValid ? value.selection.baseOffset : value.text.length;
    final insert = '\$${i.name} ';
    final start = _tokenStart < 0 ? caret : _tokenStart;
    text.value = TextEditingValue(
      text: value.text.replaceRange(start, caret, insert),
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
    picked[i.name.toUpperCase()] = i.code;
    query = null;
    results = const [];
    notifyListeners();
  }

  void dismiss() {
    query = null;
    results = const [];
    notifyListeners();
  }

  /// 把解析出的 `$` 引用转成代码：先用联想选择的，再走代码表解析。
  Future<List<String>> resolve(List<String> refs) async {
    final out = <String>[];
    for (final r in refs) {
      out.add(picked[r.toUpperCase()] ?? (await repo.resolveRefs([r])).first);
    }
    return out.toSet().toList();
  }

  void reset() {
    picked.clear();
    dismiss();
  }

  @override
  void dispose() {
    text.removeListener(_onText);
    super.dispose();
  }
}

String instrumentTypeLabel(Instrument i) => InstrumentType.fromCode(i.type).label;

/// 联想结果列表。
class InstrumentSuggestPanel extends StatelessWidget {
  const InstrumentSuggestPanel({super.key, required this.controller, this.maxHeight = 232});

  final InstrumentSuggestController controller;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.active) return const SizedBox.shrink();
        final results = controller.results;
        if (results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(children: [
              Icon(Icons.search, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  controller.query!.isEmpty
                      ? '输入代码 / 名称 / 首字母，关联指数、板块题材、ETF、个股'
                      : '没有匹配的标的（可在 设置 → 数据源 同步代码表）',
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ]),
          );
        }
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: results.length,
            itemBuilder: (context, i) {
              final r = results[i];
              return InkWell(
                key: Key('suggest-${r.code}'),
                onTap: () => controller.choose(r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  child: Row(children: [
                    Container(
                      width: 40,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(instrumentTypeLabel(r),
                          textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(r.code,
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
