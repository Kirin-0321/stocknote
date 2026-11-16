import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../data/agent/agent_tools.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/agent_repository.dart';
import 'agent_chat_page.dart';
import 'agent_providers.dart';

/// 历史对话列表。
class AgentThreadsPage extends ConsumerWidget {
  const AgentThreadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(agentThreadsProvider).value ?? const <AgentThread>[];
    final repo = ref.read(agentRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('历史对话')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AgentChatPage())),
        icon: const Icon(Icons.add),
        label: const Text('新对话'),
      ),
      body: threads.isEmpty
          ? const Center(child: Text('还没有对话'))
          : ListView(children: [
              for (final t in threads)
                ListTile(
                  leading: Icon(t.pinned ? Icons.push_pin : Icons.chat_bubble_outline, size: 20),
                  title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(formatDateTime(t.lastMessageAt)),
                  onTap: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) => AgentChatPage(threadId: t.id))),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'pin') await repo.updateThread(t.id, pinned: !t.pinned);
                      if (v == 'delete') await repo.deleteThread(t.id);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'pin', child: Text(t.pinned ? '取消置顶' : '置顶')),
                      const PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
                ),
            ]),
    );
  }
}

/// 长期记忆管理（spec 3.5.3）：待确认的候选记忆、按分类查看、编辑、置顶、删除。
class MemoriesPage extends ConsumerWidget {
  const MemoriesPage({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, AgentMemory? m) async {
    final text = TextEditingController(text: m?.content ?? '');
    var kind = MemoryKind.fromCode(m?.kind ?? 'rule');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(m == null ? '添加记忆' : '编辑记忆'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<MemoryKind>(
              initialValue: kind,
              decoration: const InputDecoration(labelText: '分类'),
              items: [for (final k in MemoryKind.values) DropdownMenuItem(value: k, child: Text(k.label))],
              onChanged: (v) => set(() => kind = v ?? kind),
            ),
            TextField(
              controller: text,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '内容', hintText: '如：不追涨停板'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('保存')),
          ],
        ),
      ),
    );
    if (ok != true || text.text.trim().isEmpty) return;
    final repo = ref.read(agentRepositoryProvider);
    m == null
        ? await repo.addMemory(kind: kind, content: text.text)
        : await repo.updateMemory(m.id, content: text.text, kind: kind, status: 'active');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(agentMemoriesProvider).value ?? const <AgentMemory>[];
    final repo = ref.read(agentRepositoryProvider);
    final theme = Theme.of(context);
    final candidates = all.where((m) => m.status == 'candidate').toList();
    final active = all.where((m) => m.status == 'active').toList();
    return Scaffold(
      appBar: AppBar(title: const Text('长期记忆')),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加记忆',
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('助手每次回答时会参考置顶记忆和与问题相关的记忆。对话结束后提炼的候选记忆需要你确认。',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ),
        if (candidates.isNotEmpty) ...[
          _Header('待确认（${candidates.length}）'),
          for (final m in candidates)
            ListTile(
              title: Text(m.content),
              subtitle: Text(MemoryKind.fromCode(m.kind).label),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  tooltip: '忽略',
                  icon: const Icon(Icons.close),
                  onPressed: () => repo.deleteMemory(m.id),
                ),
                IconButton(
                  tooltip: '保存',
                  icon: const Icon(Icons.check),
                  onPressed: () => repo.updateMemory(m.id, status: 'active'),
                ),
              ]),
            ),
        ],
        for (final k in MemoryKind.values)
          if (active.any((m) => m.kind == k.code)) ...[
            _Header(k.label),
            for (final m in active.where((m) => m.kind == k.code))
              ListTile(
                leading: m.pinned ? const Icon(Icons.push_pin, size: 18) : null,
                title: Text(m.content),
                subtitle: Text('重要度 ${'★' * m.importance}'
                    '${m.lastUsedAt == null ? '' : ' · 最近用到 ${formatDateTime(m.lastUsedAt!)}'}'),
                onTap: () => _edit(context, ref, m),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'pin') repo.updateMemory(m.id, pinned: !m.pinned);
                    if (v == 'delete') repo.deleteMemory(m.id);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'pin', child: Text(m.pinned ? '取消置顶' : '置顶（每次都参考）')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ),
          ],
        if (all.isEmpty)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('还没有记忆。在对话中说"记住……"即可添加。'))),
      ]),
    );
  }
}

/// 助手数据权限（spec 3.5.5）。
class AgentSettingsPage extends ConsumerWidget {
  const AgentSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(agentSettingsProvider).value;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('助手数据权限')),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text('关闭后助手无法读取对应数据（相关工具不可用）。大盘行情始终可用。',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ),
              for (final p in AgentPermission.values)
                SwitchListTile(
                  title: Text(p.label),
                  value: !s.denied.contains(p),
                  onChanged: (v) async {
                    final denied = {...s.denied};
                    v ? denied.remove(p) : denied.add(p);
                    await ref.read(agentServiceProvider).saveSettings(s.copyWith(denied: denied));
                    ref.invalidate(agentSettingsProvider);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.psychology_outlined),
                title: const Text('长期记忆'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemoriesPage())),
              ),
            ]),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
