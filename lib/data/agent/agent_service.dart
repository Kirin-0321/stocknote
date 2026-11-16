import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../domain/journal/entry_class.dart';
import '../ai/ai_settings.dart';
import '../ai/llm.dart';
import '../db/app_database.dart';
import '../repo/agent_repository.dart';
import '../service/journal_service.dart';
import '../settings/settings_store.dart';
import 'agent_tools.dart';

/// 打开 Agent 时所在页面的上下文（spec 3.5.1）。
class AgentPageContext {
  const AgentPageContext({required this.label, required this.text});

  /// 显示给用户："11月13日的日记"
  final String label;

  /// 随第一条消息发给模型的内容
  final String text;
}

/// Agent 设置：数据权限、首次使用提示。
class AgentSettings {
  const AgentSettings({this.denied = const {}, this.acknowledged = false});

  /// 被关闭的数据类别
  final Set<AgentPermission> denied;
  final bool acknowledged;

  bool allows(AgentPermission? p) => p == null || !denied.contains(p);

  AgentSettings copyWith({Set<AgentPermission>? denied, bool? acknowledged}) =>
      AgentSettings(denied: denied ?? this.denied, acknowledged: acknowledged ?? this.acknowledged);

  Map<String, dynamic> toJson() => {'denied': [for (final p in denied) p.code], 'acknowledged': acknowledged};

  static AgentSettings fromJson(Map<String, dynamic> j) => AgentSettings(
        denied: {
          for (final c in (j['denied'] as List? ?? const []))
            ...AgentPermission.values.where((p) => p.code == c),
        },
        acknowledged: j['acknowledged'] == true,
      );
}

class AgentNotConfigured implements Exception {
  const AgentNotConfigured();
  @override
  String toString() => '尚未配置"Agent 助手"所用模型的 API Key';
}

/// 全局 Agent（spec 3.5）：按需调用工具读取本地数据，多会话、滚动摘要、长期记忆、写操作需确认。
class AgentService {
  AgentService({
    required this.repo,
    required this.toolDeps,
    required this.aiConfig,
    required this.settings,
    required this.journalService,
    required this.calendar,
    LlmProvider Function(LlmConfig)? providerFactory,
    DateTime Function()? now,
  })  : _provider = providerFactory ?? LlmProvider.of,
        _now = now ?? DateTime.now;

  final AgentRepository repo;
  final AgentToolDeps toolDeps;
  final AiConfigRepository aiConfig;
  final SettingsStore settings;
  final JournalService journalService;
  final TradingCalendar calendar;
  final LlmProvider Function(LlmConfig) _provider;
  final DateTime Function() _now;

  static const maxRounds = 8;

  /// 未摘要的消息超过此数时压缩早期消息
  static const summarizeAfter = 40;

  /// 压缩后保留的最近消息数（约）
  static const keepRecent = 12;
  static const _settingsKey = 'agent.settings';

  Future<AgentSettings> loadSettings() async {
    final raw = await settings.raw(_settingsKey);
    if (raw == null) return const AgentSettings();
    try {
      return AgentSettings.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return const AgentSettings();
    }
  }

  Future<void> saveSettings(AgentSettings s) => settings.setRaw(_settingsKey, jsonEncode(s.toJson()));

  Future<LlmProvider> _llm() async {
    final cfg = await aiConfig.configFor(AiTask.agent);
    if (cfg == null) throw const AgentNotConfigured();
    return _provider(cfg);
  }

  // ───────────── 提示词 ─────────────

  Future<String> _systemPrompt(AgentThread thread, String question, AgentSettings s) async {
    final now = MarketClock.toMarket(_now());
    final loc = calendar.locate(_now());
    String two(int n) => n.toString().padLeft(2, '0');
    final pinned = (await repo.activeMemories()).where((m) => m.pinned).toList();
    final relevant = (await repo.searchMemories(question, limit: 8)).where((m) => !m.pinned).toList();
    final used = [...pinned, ...relevant];
    for (final m in used) {
      await repo.updateMemory(m.id, lastUsedAt: _now().millisecondsSinceEpoch);
    }
    final denied = s.denied.map((p) => p.label).join('、');
    final b = StringBuffer()
      ..writeln('你是"交易日记"App 内的 A 股交易助手，服务于这位用户本人。')
      ..writeln('现在是 ${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}（北京时间，${loc.session.label}）。')
      ..writeln()
      ..writeln('工作方式：')
      ..writeln('- 需要数据时调用工具查询用户的日记、判断与验证结果、持仓交易、历史 AI 分析和实时行情，不要凭空编造数字；查不到就如实说。')
      ..writeln('- 先想清楚需要哪些数据，尽量一次并行调用多个工具；日期范围按用户问题推算（"本周"指本周一至今）。')
      ..writeln('- 引用具体记录时在句末加引用标记：日记 [[journal:ID]]，判断 [[prediction:ID]]，交易 [[trade:ID]]，ID 取自工具结果。')
      ..writeln('- 写操作（保存日记、保存记忆）只能用 draft_journal_entry / memory_save 生成确认卡片，由用户点保存；不要声称已经保存。')
      ..writeln('- 用户说"记住……"，或你发现稳定的个人风格 / 规则 / 教训时，用 memory_save 提议保存。')
      ..writeln('- 用中文回答，先给结论再给依据，简洁、具体；可用 Markdown 的标题、列表和加粗。')
      ..writeln('- 分析与建议仅供参考，不构成投资建议；不要给出确定性的买卖指令。');
    if (denied.isNotEmpty) b.writeln('- 用户关闭了以下数据的访问：$denied。相关问题请说明无法查看。');
    if (used.isNotEmpty) {
      b
        ..writeln()
        ..writeln('关于用户的长期记忆：');
      for (final m in used) {
        b.writeln('- [${MemoryKind.fromCode(m.kind).label}] ${m.content}');
      }
    }
    if (thread.summary != null && thread.summary!.isNotEmpty) {
      b
        ..writeln()
        ..writeln('本次对话较早部分的摘要：')
        ..writeln(thread.summary);
    }
    return b.toString();
  }

  /// 数据库消息 → 模型消息（只取摘要之后的部分）。
  List<LlmMessage> _history(List<AgentMessage> all, AgentThread thread) {
    var start = 0;
    if (thread.summaryUptoMessageId != null) {
      final i = all.indexWhere((m) => m.id == thread.summaryUptoMessageId);
      if (i >= 0) start = i + 1;
    }
    final out = <LlmMessage>[];
    for (final m in all.skip(start)) {
      final meta = m.toolCalls == null ? const <String, dynamic>{} : (jsonDecode(m.toolCalls!) as Map).cast<String, dynamic>();
      switch (m.role) {
        case 'user':
          final ctx = meta['context_text'] as String?;
          out.add(LlmMessage.user(ctx == null ? m.content : '$ctx\n\n${m.content}'));
        case 'assistant':
          out.add(LlmMessage.assistant(
            m.content,
            toolCalls: [
              for (final c in (meta['calls'] as List? ?? const [])) LlmToolCall.fromJson((c as Map).cast<String, dynamic>()),
            ],
            extra: (meta['extra'] as Map?)?.cast<String, dynamic>(),
          ));
        case 'tool':
          if (m.toolCallId != null) out.add(LlmMessage.tool(m.toolCallId!, m.content));
      }
    }
    // 防御：中途失败遗留的工具调用若缺少结果，模型接口会报错——去掉这些调用及其残缺结果
    final cleaned = <LlmMessage>[];
    for (var i = 0; i < out.length; i++) {
      final m = out[i];
      if (m.role == 'assistant' && m.toolCalls.isNotEmpty) {
        final ids = {for (final c in m.toolCalls) c.id};
        final answered = <String>{};
        for (var j = i + 1; j < out.length && out[j].role == 'tool'; j++) {
          answered.add(out[j].toolCallId!);
        }
        if (!answered.containsAll(ids)) {
          if (m.content.trim().isNotEmpty) cleaned.add(LlmMessage.assistant(m.content));
          while (i + 1 < out.length && out[i + 1].role == 'tool') {
            i++;
          }
          continue;
        }
      }
      cleaned.add(m);
    }
    return cleaned;
  }

  // ───────────── 对话 ─────────────

  /// 发送一条消息并完成本轮（可能多次调用工具）。[onProgress] 在每次工具调用后回调摘要。
  Future<void> send(String threadId, String text, {AgentPageContext? context, void Function(String)? onProgress}) async {
    final llm = await _llm();
    final s = await loadSettings();
    final tools = buildAgentTools(toolDeps).where((t) => s.allows(t.permission)).toList();
    final byName = {for (final t in tools) t.spec.name: t};

    await repo.addMessage(threadId, 'user', text,
        meta: context == null ? null : {'context_label': context.label, 'context_text': '【当前页面：${context.label}】\n${context.text}'});
    var thread = (await repo.thread(threadId))!;
    if (thread.title == '新对话') {
      final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      await repo.updateThread(threadId, title: t.length > 18 ? '${t.substring(0, 18)}…' : t);
      thread = (await repo.thread(threadId))!;
    }

    final system = await _systemPrompt(thread, text, s);
    final msgs = [LlmMessage.system(system), ..._history(await repo.messages(threadId), thread)];

    for (var round = 0; round < maxRounds; round++) {
      final r = await llm.chat(msgs, tools: [for (final t in tools) t.spec], maxTokens: 8000);
      await repo.addMessage(threadId, 'assistant', r.text,
          meta: {
            if (r.toolCalls.isNotEmpty) 'calls': [for (final c in r.toolCalls) c.toJson()],
            if (r.extra != null) 'extra': r.extra,
          },
          tokens: r.tokensOut);
      msgs.add(r.toMessage());
      if (r.toolCalls.isEmpty) {
        await _maybeSummarize(threadId);
        return;
      }
      for (final call in r.toolCalls) {
        final tool = byName[call.name];
        AgentToolResult result;
        if (tool == null) {
          result = AgentToolResult('{"error":"工具不可用：${call.name}"}', summary: '工具不可用：${call.name}');
        } else {
          try {
            result = await tool.run(call.arguments);
          } catch (e) {
            result = AgentToolResult(jsonEncode({'error': '$e'}), summary: '${call.name} 失败：$e');
          }
        }
        final content = result.content.length > 16000 ? '${result.content.substring(0, 16000)}…（已截断）' : result.content;
        await repo.addMessage(threadId, 'tool', content,
            toolCallId: call.id,
            meta: {'name': call.name, 'args': call.arguments, 'summary': result.summary, 'card': ?result.card});
        msgs.add(LlmMessage.tool(call.id, content));
        onProgress?.call(result.summary);
      }
    }
    await repo.addMessage(threadId, 'assistant', '（这个问题需要查询的数据太多，我先停在这里。可以把问题拆小一些再问我。）');
  }

  /// 会话过长时把早期消息压缩成滚动摘要，保留最近若干条原文（spec 3.5.3）。
  Future<void> _maybeSummarize(String threadId) async {
    final thread = (await repo.thread(threadId))!;
    final all = await repo.messages(threadId);
    var start = 0;
    if (thread.summaryUptoMessageId != null) {
      final i = all.indexWhere((m) => m.id == thread.summaryUptoMessageId);
      if (i >= 0) start = i + 1;
    }
    final pending = all.sublist(start);
    if (pending.length <= summarizeAfter) return;
    // 在用户消息处切分，保证工具调用与结果不被拆开
    var cut = pending.length - keepRecent;
    while (cut > 0 && pending[cut].role != 'user') {
      cut--;
    }
    if (cut <= 0) return;
    final old = pending.sublist(0, cut);
    final transcript = StringBuffer();
    for (final m in old) {
      if (m.role == 'tool') {
        final meta = m.toolCalls == null ? const {} : jsonDecode(m.toolCalls!) as Map;
        transcript.writeln('（工具：${meta['summary'] ?? meta['name']}）');
      } else if (m.content.trim().isNotEmpty) {
        transcript.writeln('${m.role == 'user' ? '用户' : '助手'}：${m.content}');
      }
    }
    final llm = await _llm();
    final r = await llm.chat([
      const LlmMessage.system('你负责压缩对话历史。输出一段中文摘要（不超过 400 字），保留：用户的问题与关注点、已得出的结论和关键数字、'
          '用户的偏好与决定、未完成的事项。不要编造。只输出摘要正文。'),
      LlmMessage.user('${thread.summary == null ? '' : '已有摘要：\n${thread.summary}\n\n'}需要并入摘要的新对话：\n$transcript'),
    ]);
    if (r.text.trim().isEmpty) return;
    await repo.updateThread(threadId, summary: Value(r.text.trim()), summaryUpto: Value(old.last.id));
  }

  // ───────────── 确认卡片 ─────────────

  Map<String, dynamic> _meta(AgentMessage m) =>
      m.toolCalls == null ? <String, dynamic>{} : (jsonDecode(m.toolCalls!) as Map).cast<String, dynamic>();

  /// 用户点"保存"：写入日记或记忆。返回新记录 id。
  Future<String> confirmCard(AgentMessage m) async {
    final meta = _meta(m);
    final card = (meta['card'] as Map).cast<String, dynamic>();
    if (card['status'] != 'pending') return card['saved_id'] as String? ?? '';
    final data = (card['data'] as Map).cast<String, dynamic>();
    String id;
    if (card['type'] == 'memory') {
      id = (await repo.addMemory(
        kind: MemoryKind.fromCode(data['kind'] as String?),
        content: data['content'] as String,
        importance: (data['importance'] as num?)?.toInt() ?? 3,
        sourceThreadId: m.threadId,
      ))
          .id;
    } else {
      final e = await journalService.create(
        content: data['content'] as String,
        classification: EntryClass(
          category: data['category'] as String?,
          subcategory: data['subcategory'] as String?,
          stance: data['stance'] as String?,
          horizon: data['horizon'] as String?,
        ),
        instrumentCodes: [for (final c in (data['instrument_codes'] as List? ?? const [])) '$c'],
      );
      id = e.id;
    }
    await repo.updateMeta(m.id, {
      ...meta,
      'card': {...card, 'status': 'saved', 'saved_id': id},
    });
    return id;
  }

  Future<void> dismissCard(AgentMessage m) async {
    final meta = _meta(m);
    await repo.updateMeta(m.id, {
      ...meta,
      'card': {...(meta['card'] as Map), 'status': 'dismissed'},
    });
  }

  // ───────────── 记忆提炼 ─────────────

  /// 离开对话时从新消息中提炼候选记忆（进入待确认列表）。返回新增条数。
  Future<int> extractMemories(String threadId) async {
    final key = 'agent.extracted.$threadId';
    final since = int.tryParse(await settings.raw(key) ?? '') ?? 0;
    final fresh = (await repo.messages(threadId)).where((m) => m.ts > since && m.role != 'tool').toList();
    if (fresh.where((m) => m.role == 'user').isEmpty) return 0;
    final llm = await _llm();
    final existing = await repo.activeMemories();
    final transcript = [
      for (final m in fresh)
        if (m.content.trim().isNotEmpty) '${m.role == 'user' ? '用户' : '助手'}：${m.content}',
    ].join('\n');
    final r = await llm.chat([
      const LlmMessage.system('从对话中提炼关于用户本人的长期稳定信息（交易风格 style、个人规则 rule、偏好 preference、经验教训 lesson、关注标的 watch）。'
          '只提炼用户明确表达或反复体现的内容，不要提炼一次性的问题或行情信息；与已有记忆重复的不要输出。'
          '只输出 JSON：{"memories":[{"kind":"rule","content":"一句话，第三人称","importance":1-5}]}，没有则输出 {"memories":[]}。'),
      LlmMessage.user('已有记忆：\n${existing.map((m) => '- ${m.content}').join('\n')}\n\n对话：\n$transcript'),
    ], json: true);
    await settings.setRaw(key, '${fresh.last.ts}');
    final list = (extractJsonObject(r.text)?['memories'] as List?) ?? const [];
    var n = 0;
    for (final it in list.take(5)) {
      if (it is! Map || '${it['content'] ?? ''}'.trim().isEmpty) continue;
      final content = '${it['content']}'.trim();
      if (existing.any((m) => m.content == content)) continue;
      await repo.addMemory(
        kind: MemoryKind.fromCode(it['kind'] as String?),
        content: content,
        status: 'candidate',
        importance: (it['importance'] as num?)?.toInt() ?? 3,
        sourceThreadId: threadId,
      );
      n++;
    }
    return n;
  }
}
