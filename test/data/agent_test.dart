import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/agent/agent_service.dart';
import 'package:stocknote/data/agent/agent_tools.dart';
import 'package:stocknote/data/ai/ai_settings.dart';
import 'package:stocknote/data/ai/llm.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/snapshot_service.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/agent_repository.dart';
import 'package:stocknote/data/repo/ai_analysis_repository.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/market_snapshot_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/repo/trade_repository.dart';
import 'package:stocknote/data/service/journal_service.dart';
import 'package:stocknote/data/settings/settings_store.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/trade/portfolio.dart';

import '../helpers/fake_llm.dart';
import '../helpers/fake_market.dart';

void main() {
  late AppDatabase db;
  late AgentRepository repo;
  late JournalRepository journal;
  late PredictionRepository preds;
  late SettingsStore settings;
  late ScriptedLlm llm;
  late AgentService svc;
  final clock = MarketClock.fromMarket(2026, 11, 13, 16, 0);
  final cal = TradingCalendar();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = AgentRepository(db, now: () => clock);
    journal = JournalRepository(db, cal, now: () => clock);
    preds = PredictionRepository(db, cal, now: () => clock);
    settings = SettingsStore(db);
    final market = MarketService(MarketRouter([FakeSource(SourceId.tushare)]));
    llm = ScriptedLlm([answer('好的')]);
    svc = AgentService(
      repo: repo,
      toolDeps: AgentToolDeps(
        journal: journal,
        predictions: preds,
        trades: TradeRepository(db),
        instruments: InstrumentRepository(db),
        analyses: AiAnalysisRepository(db),
        agent: repo,
        market: market,
        calendar: cal,
        overview: () => market.overview(const ['000001.SH'], '20261113'),
        costMethod: () => CostMethod.diluted,
        now: () => clock,
      ),
      aiConfig: AiConfigRepository(settings, MemorySecretStore(), envDeepseekKey: 'sk'),
      settings: settings,
      journalService: JournalService(
        journal: journal,
        predictions: preds,
        snapshots: SnapshotService(market: market, repo: MarketSnapshotRepository(db), latestOverview: () => null),
      ),
      calendar: cal,
      providerFactory: (_) => llm,
      now: () => clock,
    );
  });
  tearDown(() => db.close());

  Map<String, dynamic> meta(AgentMessage m) => (jsonDecode(m.toolCalls!) as Map).cast<String, dynamic>();

  test('工具循环：查询本地数据后回答；消息、工具摘要与会话标题都被保存', () async {
    final e = await journal.create(
        content: '半导体放量看多',
        instrumentCodes: const ['600519.SH'],
        classification: const EntryClass(category: 'judge', subcategory: 'stock', stance: 'bull', horizon: 't1'));
    await preds.syncFromEntry(e);
    llm = ScriptedLlm([
      LlmResponse(text: '', model: 'fake', toolCalls: const [
        LlmToolCall(id: 'c1', name: 'get_prediction_stats', arguments: {'date_from': '2026-11-09'}),
        LlmToolCall(id: 'c2', name: 'search_journal', arguments: {'keyword': '半导体'}),
      ]),
      answer('本周 1 条判断尚未验证 [[journal:${e.id}]]'),
    ]);
    final t = await repo.createThread();
    final progress = <String>[];
    await svc.send(t.id, '我本周判断准确率怎样？', onProgress: progress.add);

    final msgs = await repo.messages(t.id);
    expect(msgs.map((m) => m.role), ['user', 'assistant', 'tool', 'tool', 'assistant']);
    expect(progress, ['统计了 1 条判断的准确率', '查询了 1 条日记']);
    final stats = jsonDecode(msgs[2].content) as Map;
    expect(stats['total'], 1);
    expect(stats['pending'], 1);
    final found = jsonDecode(msgs[3].content) as Map;
    expect((found['items'] as List).single['id'], e.id);
    expect(msgs.last.content, contains(e.id));
    expect((await repo.thread(t.id))!.title, '我本周判断准确率怎样？');

    // 第二轮请求带上了工具结果，且工具调用与结果配对
    final second = llm.calls[1];
    expect(second.first.role, 'system');
    expect(second.where((m) => m.role == 'tool').map((m) => m.toolCallId), ['c1', 'c2']);
    expect(second.firstWhere((m) => m.role == 'assistant').toolCalls, hasLength(2));
  });

  test('数据权限：关闭的类别不提供对应工具', () async {
    await svc.saveSettings(const AgentSettings(denied: {AgentPermission.trades, AgentPermission.journal}));
    final t = await repo.createThread();
    await svc.send(t.id, '看看我的持仓');
    final names = llm.toolLists.single;
    expect(names, contains('get_market_overview'));
    expect(names, isNot(contains('get_positions')));
    expect(names, isNot(contains('search_journal')));
    expect(llm.calls.single.first.content, contains('持仓与交易'));
  });

  test('确认卡片：记忆与日记草稿须用户确认才写入；判断类日记生成判断', () async {
    llm = ScriptedLlm([
      LlmResponse(text: '', model: 'fake', toolCalls: const [
        LlmToolCall(id: 'm1', name: 'memory_save', arguments: {'kind': 'rule', 'content': '不追涨停板', 'importance': 5}),
        LlmToolCall(id: 'j1', name: 'draft_journal_entry', arguments: {
          'content': '明天大盘看多',
          'category': 'judge',
          'subcategory': 'market',
          'stance': 'bull',
          'horizon': 't1',
        }),
      ]),
      answer('已生成两张卡片，请确认'),
    ]);
    final t = await repo.createThread();
    await svc.send(t.id, '记住我不追涨停，另外帮我记一条明天看多');
    expect(await repo.activeMemories(), isEmpty, reason: '未确认前不写入');
    expect(await journal.search(const JournalQuery()), isEmpty);

    final cards = (await repo.messages(t.id)).where((m) => m.role == 'tool').toList();
    await svc.confirmCard(cards[0]);
    final mem = (await repo.activeMemories()).single;
    expect((mem.kind, mem.content, mem.importance, mem.sourceThreadId), ('rule', '不追涨停板', 5, t.id));

    final entryId = await svc.confirmCard(cards[1]);
    final e = (await journal.get(entryId))!;
    expect((e.category, e.stance, e.horizon), ('judge', 'bull', 't1'));
    expect((await preds.forEntry(entryId))!.targetCode, '000001.SH');
    final saved = meta((await repo.messages(t.id)).firstWhere((m) => m.id == cards[1].id));
    expect(saved['card']['status'], 'saved');
    // 重复确认不会重复写入
    await svc.confirmCard((await repo.messages(t.id)).firstWhere((m) => m.id == cards[1].id));
    expect(await journal.search(const JournalQuery()), hasLength(1));
  });

  test('长期记忆注入系统提示：置顶 + 与问题相关', () async {
    final pinned = await repo.addMemory(kind: MemoryKind.style, content: '偏好短线');
    await repo.updateMemory(pinned.id, pinned: true);
    await repo.addMemory(kind: MemoryKind.rule, content: '半导体只做龙头');
    await repo.addMemory(kind: MemoryKind.lesson, content: '消费股抄底容易亏');
    final t = await repo.createThread();
    await svc.send(t.id, '半导体现在能买吗');
    final system = llm.calls.single.first.content;
    expect(system, contains('偏好短线'));
    expect(system, contains('半导体只做龙头'));
    expect(system, isNot(contains('消费股抄底')));
    expect(memoryTerms('半导体现在能买吗'), containsAll(['半导', '导体']));
  });

  test('滚动摘要：消息过多时压缩早期部分，保留最近原文', () async {
    final t = await repo.createThread(title: '长对话');
    for (var i = 0; i < 25; i++) {
      await repo.addMessage(t.id, 'user', '问题 $i');
      await repo.addMessage(t.id, 'assistant', '回答 $i');
    }
    llm = ScriptedLlm([answer('最新回答'), answer('用户问了很多问题，结论是…')]);
    await svc.send(t.id, '新问题');
    final thread = (await repo.thread(t.id))!;
    expect(thread.summary, '用户问了很多问题，结论是…');
    expect(thread.summaryUptoMessageId, isNotNull);

    llm = ScriptedLlm([answer('继续')]);
    await svc.send(t.id, '再问');
    final sent = llm.calls.single;
    expect(sent.first.content, contains('用户问了很多问题'));
    expect(sent.where((m) => m.role != 'system').length, lessThan(20));
    expect(sent[1].role, 'user', reason: '保留部分从用户消息开始');
  });

  test('离开对话后提炼候选记忆', () async {
    final t = await repo.createThread();
    await repo.addMessage(t.id, 'user', '我从来不追涨停板，也不做 ST');
    await repo.addMessage(t.id, 'assistant', '明白');
    llm = ScriptedLlm([answer('{"memories":[{"kind":"rule","content":"不追涨停板、不做 ST","importance":4}]}')]);
    expect(await svc.extractMemories(t.id), 1);
    final all = await repo.watchMemories().first;
    expect((all.single.status, all.single.content), ('candidate', '不追涨停板、不做 ST'));
    expect(await svc.extractMemories(t.id), 0, reason: '没有新消息不重复提炼');
  });

  test('中途失败遗留的未回应工具调用不会发给模型', () async {
    final t = await repo.createThread();
    await repo.addMessage(t.id, 'user', 'a');
    await repo.addMessage(t.id, 'assistant', '', meta: {
      'calls': [
        {'id': 'x', 'name': 'get_positions', 'arguments': {}},
      ],
    });
    await svc.send(t.id, 'b');
    final roles = llm.calls.single.map((m) => m.role).toList();
    expect(roles, ['system', 'user', 'user']);
  });

  group('协议', () {
    Dio capture(void Function(RequestOptions) onReq, Map<String, dynamic> reply) => Dio()
      ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        onReq(o);
        h.resolve(Response(requestOptions: o, statusCode: 200, data: reply));
      }));

    test('OpenAI 兼容：工具定义、tool_calls 回传、reasoning_content 原样带回', () async {
      late RequestOptions sent;
      final p = OpenAiCompatibleProvider(
        const LlmConfig(presetId: 'deepseek', protocol: LlmProtocol.openai, baseUrl: 'https://x', model: 'm', apiKey: 'k'),
        dio: capture((o) => sent = o, {
          'choices': [
            {
              'message': {
                'content': '',
                'reasoning_content': 'think',
                'tool_calls': [
                  {'id': 't1', 'type': 'function', 'function': {'name': 'get_quotes', 'arguments': '{"codes":["600519.SH"]}'}},
                ],
              },
            },
          ],
        }),
      );
      final r = await p.chat([const LlmMessage.user('q')],
          tools: const [LlmTool(name: 'get_quotes', description: 'd', parameters: {'type': 'object'})]);
      expect((sent.data as Map)['tools'][0]['function']['name'], 'get_quotes');
      expect(r.toolCalls.single.arguments['codes'], ['600519.SH']);
      await p.chat([const LlmMessage.user('q'), r.toMessage(), const LlmMessage.tool('t1', '{"price":1}')]);
      final msgs = (sent.data as Map)['messages'] as List;
      expect(msgs[1]['tool_calls'][0]['function']['arguments'], '{"codes":["600519.SH"]}');
      expect(msgs[1]['reasoning_content'], 'think');
      expect(msgs[2], {'role': 'tool', 'tool_call_id': 't1', 'content': '{"price":1}'});
    });

    test('Anthropic：tool_use 解析，原始内容块回传，连续工具结果合并为一条 user 消息', () async {
      late RequestOptions sent;
      final blocks = [
        {'type': 'thinking', 'thinking': '', 'signature': 'sig'},
        {'type': 'tool_use', 'id': 'u1', 'name': 'a', 'input': {'x': 1}},
        {'type': 'tool_use', 'id': 'u2', 'name': 'b', 'input': {}},
      ];
      final p = AnthropicProvider(
        const LlmConfig(presetId: 'anthropic', protocol: LlmProtocol.anthropic, baseUrl: 'https://x', model: 'm', apiKey: 'k'),
        dio: capture((o) => sent = o, {'stop_reason': 'tool_use', 'content': blocks}),
      );
      final r = await p.chat([const LlmMessage.system('s'), const LlmMessage.user('q')],
          tools: const [LlmTool(name: 'a', description: 'd', parameters: {'type': 'object'})]);
      expect((sent.data as Map)['tools'][0]['input_schema'], {'type': 'object'});
      expect(r.toolCalls.map((c) => c.id), ['u1', 'u2']);
      await p.chat([
        const LlmMessage.user('q'),
        r.toMessage(),
        const LlmMessage.tool('u1', 'r1'),
        const LlmMessage.tool('u2', 'r2'),
      ]);
      final msgs = (sent.data as Map)['messages'] as List;
      expect(msgs[1]['content'], blocks, reason: '思考块原样回传');
      expect(msgs, hasLength(3));
      expect((msgs[2]['content'] as List).map((b) => b['tool_use_id']), ['u1', 'u2']);
    });
  });
}
