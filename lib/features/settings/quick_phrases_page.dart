import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../journal/journal_providers.dart';

/// 常用短语管理：添加、拖动排序、左滑删除。
class QuickPhrasesPage extends ConsumerWidget {
  const QuickPhrasesPage({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加短语'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '如：缩量回调'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('添加')),
        ],
      ),
    );
    controller.dispose();
    if (text != null) await ref.read(quickPhraseRepositoryProvider).add(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrases = ref.watch(quickPhrasesProvider);
    final repo = ref.read(quickPhraseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('常用短语')),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加',
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: phrases.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('还没有短语，点右下角添加'))
            : ReorderableListView.builder(
                itemCount: list.length,
                padding: const EdgeInsets.only(bottom: 88),
                onReorderItem: (from, to) {
                  final ids = list.map((p) => p.id).toList();
                  ids.insert(to, ids.removeAt(from));
                  repo.reorder(ids);
                },
                itemBuilder: (context, i) {
                  final p = list[i];
                  return Dismissible(
                    key: ValueKey(p.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => repo.delete(p.id),
                    child: ListTile(
                      title: Text(p.phrase),
                      trailing: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
