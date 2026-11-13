import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/time/market_clock.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/journal_repository.dart';
import 'widgets/attribute_chips.dart';
import 'widgets/entry_card.dart';

/// 日记搜索：关键词 + 观点 / 动作 / 情绪过滤。点击结果返回其交易日。
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  var _attrs = EntryAttributes.empty;
  List<JournalEntry>? _results;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _run);
  }

  Future<void> _run() async {
    final q = JournalQuery(
      text: _controller.text,
      stance: _attrs.stance?.code,
      action: _attrs.action?.code,
      emotion: _attrs.emotion?.code,
    );
    if (q.isEmpty) {
      setState(() => _results = null);
      return;
    }
    final results = await ref.read(journalRepositoryProvider).search(q);
    if (mounted) setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _results;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '搜索内容、#标签、代码',
            border: InputBorder.none,
          ),
          onChanged: (_) => _schedule(),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _schedule();
              },
            ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AttributeBar(
            value: _attrs,
            onChanged: (v) {
              setState(() => _attrs = v);
              _run();
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: results == null
              ? Center(
                  child: Text('输入关键词或选择要素筛选',
                      style: TextStyle(color: theme.colorScheme.outline)))
              : results.isEmpty
                  ? const Center(child: Text('没有匹配的记录'))
                  : ListView.builder(
                      itemCount: results.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text('${results.length} 条结果',
                                style: theme.textTheme.labelMedium),
                          );
                        }
                        final e = results[i - 1];
                        return EntryCard(
                          entry: e,
                          showDate: true,
                          onTap: () => Navigator.pop(context, TradeDate.parse(e.tradeDate)),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
