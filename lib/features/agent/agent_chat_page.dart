import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../data/agent/agent_service.dart';
import '../../data/ai/ai_settings.dart';
import '../../data/ai/llm.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/agent_repository.dart';
import '../../domain/journal/vocab.dart';
import '../portfolio/trade_form_page.dart';
import '../review/prediction_detail_page.dart';
import '../settings/ai_settings_page.dart';
import 'agent_pages.dart';
import 'agent_providers.dart';
import 'md_view.dart';

/// 快捷指令（spec 3.5.1）。
const agentQuickPrompts = [
  '今天盘面怎么看？',
  '复盘我本周的判断',
  '我最近哪类判断最不准？',
  '检查我的持仓风险',
  '总结我最近的交易表现',
];

/// Agent 对话页。[threadId] 为空时发送第一条消息再建会话。
class AgentChatPage extends ConsumerStatefulWidget {
  const AgentChatPage({super.key, this.threadId, this.pageContext});
  final String? threadId;
  final AgentPageContext? pageContext;

  @override
  ConsumerState<AgentChatPage> createState() => _AgentChatPageState();
}

class _AgentChatPageState extends ConsumerState<AgentChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  String? _threadId;
  AgentPageContext? _context;
  bool _sending = false;
  final _progress = <String>[];
  String? _error;
  late final AgentService _service;

  @override
  void initState() {
    super.initState();
    _threadId = widget.threadId;
    _context = widget.pageContext;
    _service = ref.read(agentServiceProvider);
  }

  @override
  void dispose() {
    // 离开对话时提炼候选记忆（后台进行，失败忽略）
    final id = _threadId;
    if (id != null) _service.extractMemories(id).catchError((_) => 0);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<bool> _ensureAcknowledged() async {
    final s = await ref.read(agentServiceProvider).loadSettings();
    if (s.acknowledged) return true;
    if (!mounted) return false;
    final cfg = await ref.read(aiConfigRepositoryProvider).load();
    final tm = cfg.taskModel(AiTask.agent);
    if (!mounted) return false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('使用 AI 助手前'),
        content: Text('助手回答问题时，会把需要的日记、判断、持仓等数据发送给你选择的模型服务（${LlmPreset.byId(tm.presetId).name} · ${tm.model}）。'
            '可在助手设置中关闭某类数据的访问。\n\n助手的分析与建议仅供参考，不构成投资建议。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('同意并继续')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(agentServiceProvider).saveSettings(s.copyWith(acknowledged: true));
      ref.invalidate(agentSettingsProvider);
    }
    return ok == true;
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending) return;
    if (!await _ensureAcknowledged()) return;
    final repo = ref.read(agentRepositoryProvider);
    _threadId ??= (await repo.createThread()).id;
    final ctx = _context;
    setState(() {
      _sending = true;
      _error = null;
      _progress.clear();
      _context = null; // 上下文只随第一条消息发送
      if (preset == null) _input.clear();
    });
    _scrollToEnd();
    try {
      await _service.send(_threadId!, text, context: ctx, onProgress: (p) {
        if (mounted) setState(() => _progress.add(p));
      });
    } on AgentNotConfigured catch (e) {
      _error = e.toString();
    } on LlmException catch (e) {
      _error = 'AI 请求失败：$e';
    } catch (e) {
      _error = '出错了：$e';
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _openCitation(String type, String id) async {
    void notFound() =>
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('没有找到这条记录')));
    switch (type) {
      case 'prediction':
        var p = await ref.read(predictionRepositoryProvider).get(id);
        // 模型偶尔把日记 id 当成判断 id：按日记找对应判断
        p ??= await ref.read(predictionRepositoryProvider).forEntry(id);
        if (!mounted) return;
        if (p == null) return notFound();
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PredictionDetailPage(predictionId: p!.id)));
      case 'trade':
        final t = await ref.read(tradeRepositoryProvider).get(id);
        if (!mounted) return;
        if (t == null) return notFound();
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TradeFormPage(trade: t)));
      default:
        var e = await ref.read(journalRepositoryProvider).get(id);
        if (e == null) {
          final p = await ref.read(predictionRepositoryProvider).get(id);
          if (p?.entryId != null) e = await ref.read(journalRepositoryProvider).get(p!.entryId!);
        }
        if (!mounted) return;
        if (e == null) return notFound();
        final entry = e;
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (c) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${formatDateTime(entry.ts)} · ${byCode(EntryCategory.values, entry.category)?.label ?? '日记'}',
                  style: Theme.of(c).textTheme.labelMedium),
              const SizedBox(height: 8),
              SelectableText(entry.content, style: Theme.of(c).textTheme.bodyLarge),
              if (entry.deletedAt != null)
                Padding(padding: const EdgeInsets.only(top: 8), child: Text('（已删除）', style: Theme.of(c).textTheme.labelSmall)),
            ]),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = _threadId == null
        ? const <AgentMessage>[]
        : (ref.watch(agentMessagesProvider(_threadId!)).value ?? const <AgentMessage>[]);
    final thread = _threadId == null
        ? null
        : (ref.watch(agentThreadsProvider).value ?? const <AgentThread>[]).where((t) => t.id == _threadId).firstOrNull;
    final ready = ref.watch(aiSettingsProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(thread?.title ?? 'AI 助手', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: '新对话',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AgentChatPage())),
          ),
          IconButton(
            tooltip: '历史对话',
            icon: const Icon(Icons.forum_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AgentThreadsPage())),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => switch (v) {
                      'memories' => const MemoriesPage(),
                      'model' => const AiSettingsPage(),
                      _ => const AgentSettingsPage(),
                    })),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'memories', child: Text('长期记忆')),
              PopupMenuItem(value: 'settings', child: Text('数据权限')),
              PopupMenuItem(value: 'model', child: Text('模型设置')),
            ],
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: messages.isEmpty && !_sending
              ? _Welcome(onPick: _send, ready: ready)
              : ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  children: [
                    ..._buildMessages(messages),
                    if (_sending) _Thinking(progress: _progress),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(children: [
                          Expanded(child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
                          if (_error!.contains('API Key'))
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => const AiSettingsPage())),
                              child: const Text('去设置'),
                            ),
                        ]),
                      ),
                  ],
                ),
        ),
        if (_context != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.attach_file, size: 16),
                label: Text('附带：${_context!.label}'),
                onDeleted: () => setState(() => _context = null),
              ),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  key: const Key('agent-input'),
                  controller: _input,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: '问问助手，比如"我本周判断准确率怎样"',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                key: const Key('agent-send'),
                onPressed: _sending ? null : () => _send(),
                icon: const Icon(Icons.arrow_upward),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildMessages(List<AgentMessage> messages) {
    final out = <Widget>[];
    var i = 0;
    while (i < messages.length) {
      final m = messages[i];
      final meta = m.toolCalls == null ? const <String, dynamic>{} : (jsonDecode(m.toolCalls!) as Map).cast<String, dynamic>();
      if (m.role == 'user') {
        out.add(_UserBubble(text: m.content, contextLabel: meta['context_label'] as String?));
        i++;
      } else if (m.role == 'tool') {
        // 连续的工具调用合并显示；确认卡片单独显示
        final group = <(AgentMessage, Map<String, dynamic>)>[];
        while (i < messages.length && (messages[i].role == 'tool' || (messages[i].role == 'assistant' && messages[i].content.trim().isEmpty))) {
          if (messages[i].role == 'tool') {
            group.add((messages[i], (jsonDecode(messages[i].toolCalls ?? '{}') as Map).cast<String, dynamic>()));
          }
          i++;
        }
        out.add(_ToolGroup(items: group));
        for (final (msg, meta) in group) {
          if (meta['card'] != null) {
            out.add(_ConfirmCard(
              message: msg,
              card: (meta['card'] as Map).cast<String, dynamic>(),
              onConfirm: () async {
                await _service.confirmCard(msg);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(meta['card']['type'] == 'memory' ? '已保存到长期记忆' : '已保存到今天的日记')));
                }
              },
              onDismiss: () => _service.dismissCard(msg),
            ));
          }
        }
      } else {
        if (m.content.trim().isNotEmpty) out.add(_AssistantBubble(text: m.content, onCite: _openCitation));
        i++;
      }
    }
    return out;
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onPick, required this.ready});
  final void Function(String) onPick;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 24),
      Icon(Icons.auto_awesome, size: 40, color: theme.colorScheme.primary),
      const SizedBox(height: 12),
      Text('交易助手', textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('可以查看你的日记、判断、持仓交易和实时行情来回答问题，会记住你的交易风格和规则。',
          textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      const SizedBox(height: 24),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
        for (final p in agentQuickPrompts) ActionChip(label: Text(p), onPressed: () => onPick(p)),
      ]),
    ]);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text, this.contextLabel});
  final String text;
  final String? contextLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48, top: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (contextLabel != null)
            Text('📎 $contextLabel', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          SelectableText(text, style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
        ]),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text, required this.onCite});
  final String text;
  final void Function(String, String) onCite;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: MdView.plain(text)));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8, right: 8),
          child: MdView(text, onCite: onCite),
        ),
      );
}

class _ToolGroup extends StatelessWidget {
  const _ToolGroup({required this.items});
  final List<(AgentMessage, Map<String, dynamic>)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline);
    final summaries = [for (final (_, m) in items) '${m['summary'] ?? m['name']}'];
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        dense: true,
        tilePadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        leading: Icon(Icons.manage_search, size: 18, color: theme.colorScheme.outline),
        title: Text(summaries.join('，'), style: muted, maxLines: 2, overflow: TextOverflow.ellipsis),
        children: [
          for (final (msg, m) in items)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${m['name']}  ${jsonEncode(m['args'] ?? {})}', style: muted?.copyWith(fontFamily: 'monospace')),
                const SizedBox(height: 4),
                Text(msg.content.length > 600 ? '${msg.content.substring(0, 600)}…' : msg.content,
                    style: muted?.copyWith(fontFamily: 'monospace')),
              ]),
            ),
        ],
      ),
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.message, required this.card, required this.onConfirm, required this.onDismiss});
  final AgentMessage message;
  final Map<String, dynamic> card;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = (card['data'] as Map).cast<String, dynamic>();
    final memory = card['type'] == 'memory';
    final status = card['status'] as String?;
    final title = memory
        ? '记住：${MemoryKind.fromCode(data['kind'] as String?).label}'
        : '起草日记 · ${byCode(EntryCategory.values, data['category'] as String?)?.label ?? ''}'
            '${data['stance'] == null ? '' : ' · ${switch (data['stance']) { 'bull' => '看多', 'bear' => '看空', _ => '震荡' }}'}';
    return Card(
      key: Key('agent-card-${message.id}'),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(memory ? Icons.psychology_outlined : Icons.edit_note, size: 18),
            const SizedBox(width: 6),
            Text(title, style: theme.textTheme.labelLarge),
          ]),
          const SizedBox(height: 6),
          Text('${data['content']}'),
          if ((data['instrument_codes'] as List?)?.isNotEmpty ?? false)
            Text('关联：${(data['instrument_codes'] as List).join('、')}', style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          if (status == 'pending')
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: onDismiss, child: const Text('不用了')),
              FilledButton(key: const Key('agent-card-save'), onPressed: onConfirm, child: const Text('保存')),
            ])
          else
            Align(
              alignment: Alignment.centerRight,
              child: Text(status == 'saved' ? '已保存' : '已忽略', style: theme.textTheme.labelSmall),
            ),
        ]),
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking({required this.progress});
  final List<String> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            progress.isEmpty ? '思考中…' : '${progress.last}…',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
      ]),
    );
  }
}
