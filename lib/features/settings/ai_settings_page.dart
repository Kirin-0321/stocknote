import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../data/ai/ai_settings.dart';
import '../../data/ai/llm.dart';

/// AI 模型设置（spec 3.1.2）：各提供方 Key、各任务所用模型与思考强度、定时分析。
class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  Map<String, String> _keyStatus = {};
  (int, int)? _usage;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final repo = ref.read(aiConfigRepositoryProvider);
    final m = <String, String>{};
    for (final p in LlmPreset.all) {
      if (await repo.keyFromEnv(p.id)) {
        m[p.id] = '使用 .env 中的 Key';
      } else if (await repo.apiKey(p.id) != null) {
        m[p.id] = '已配置';
      }
    }
    final usage = await ref.read(aiAnalysisRepositoryProvider).tokenUsage();
    if (mounted) {
      setState(() {
        _keyStatus = m;
        _usage = usage;
      });
    }
  }

  Future<void> _save(AiSettings s) async {
    await ref.read(aiConfigRepositoryProvider).save(s);
    ref.invalidate(aiSettingsProvider);
  }

  Future<void> _editProvider(LlmPreset p, AiSettings s) async {
    final key = TextEditingController();
    final url = TextEditingController(text: s.baseUrls[p.id] ?? '');
    final r = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(p.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            key: const Key('ai-key'),
            controller: key,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'API Key',
              helperText: _keyStatus[p.id] == null ? (p.keyHint.isEmpty ? null : p.keyHint) : '留空则保持当前 Key',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: url,
            decoration: InputDecoration(
              labelText: 'Base URL',
              hintText: p.baseUrl.isEmpty ? 'https://…/v1' : p.baseUrl,
              helperText: p.baseUrl.isEmpty ? 'OpenAI 兼容接口地址' : '留空使用默认地址',
            ),
          ),
        ]),
        actions: [
          if (_keyStatus[p.id] == '已配置')
            TextButton(
              onPressed: () async {
                await ref.read(aiConfigRepositoryProvider).setApiKey(p.id, null);
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('清除 Key'),
            ),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('保存')),
        ],
      ),
    );
    if (r != true) return;
    if (key.text.trim().isNotEmpty) {
      await ref.read(aiConfigRepositoryProvider).setApiKey(p.id, key.text);
    }
    final urls = {...s.baseUrls};
    url.text.trim().isEmpty ? urls.remove(p.id) : urls[p.id] = url.text.trim();
    await _save(s.copyWith(baseUrls: urls));
    await _refreshStatus();
  }

  Future<void> _editTask(AiTask t, AiSettings s) async {
    var tm = s.taskModel(t);
    final model = TextEditingController(text: tm.model);
    final r = await showDialog<TaskModel>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setLocal) {
        final preset = LlmPreset.byId(tm.presetId);
        return AlertDialog(
          title: Text(t.label),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (t.hint != null) Text(t.hint!, style: Theme.of(context).textTheme.bodySmall),
            DropdownButtonFormField<String>(
              initialValue: preset.id,
              decoration: const InputDecoration(labelText: '提供方'),
              items: [for (final p in LlmPreset.all) DropdownMenuItem(value: p.id, child: Text(p.name))],
              onChanged: (v) => setLocal(() {
                final p = LlmPreset.byId(v);
                tm = tm.copyWith(presetId: p.id, model: p.defaultModel);
                model.text = p.defaultModel;
              }),
            ),
            const SizedBox(height: 8),
            TextField(controller: model, decoration: const InputDecoration(labelText: '模型')),
            Wrap(spacing: 6, children: [
              for (final m in preset.models.where((m) => m.isNotEmpty))
                ActionChip(label: Text(m), onPressed: () => setLocal(() => model.text = m)),
            ]),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: TaskModel.efforts.contains(tm.effort) ? tm.effort : '',
              decoration: const InputDecoration(labelText: '思考强度'),
              items: [
                for (final e in TaskModel.efforts)
                  DropdownMenuItem(value: e, child: Text(TaskModel.effortLabels[e]!)),
              ],
              onChanged: (v) => setLocal(() => tm = tm.copyWith(effort: v)),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            FilledButton(
              onPressed: () => Navigator.pop(context, tm.copyWith(model: model.text.trim())),
              child: const Text('保存'),
            ),
          ],
        );
      }),
    );
    if (r == null) return;
    await _save(s.copyWith(tasks: {...s.tasks, t: r}));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(aiSettingsProvider).value;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);
    return Scaffold(
      appBar: AppBar(title: const Text('AI 模型')),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: [
              const _Header('各任务使用的模型'),
              for (final t in AiTask.values)
                ListTile(
                  key: Key('ai-task-${t.code}'),
                  title: Text(t.label),
                  subtitle: Text('${LlmPreset.byId(s.taskModel(t).presetId).name} · ${s.taskModel(t).model}'
                      ' · 思考${TaskModel.effortLabels[s.taskModel(t).effort] ?? s.taskModel(t).effort}'
                      '${_keyStatus[s.taskModel(t).presetId] == null ? '（未配置 Key）' : ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editTask(t, s),
                ),
              const _Header('提供方 API Key'),
              for (final p in LlmPreset.all)
                ListTile(
                  title: Text(p.name),
                  subtitle: Text(_keyStatus[p.id] ?? '未配置', style: _keyStatus[p.id] == null ? muted : null),
                  trailing: const Icon(Icons.key_outlined),
                  onTap: () => _editProvider(p, s),
                ),
              const _Header('大盘分析'),
              SwitchListTile(
                title: const Text('定时分析'),
                subtitle: const Text('交易日 9:35 / 11:35 / 15:05 自动分析（应用打开时）'),
                value: s.scheduleEnabled,
                onChanged: (v) => _save(s.copyWith(scheduleEnabled: v)),
              ),
              SwitchListTile(
                title: const Text('附带最近日记观点'),
                subtitle: const Text('把近两个交易日的日记一并发给模型参考'),
                value: s.includeJournal,
                onChanged: (v) => _save(s.copyWith(includeJournal: v)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Text(
                  'Key 保存在系统安全存储中，只发送给对应的模型服务。'
                  '${_usage == null ? '' : '\n大盘分析累计用量：输入 ${_usage!.$1} / 输出 ${_usage!.$2} tokens'}',
                  style: muted,
                ),
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
