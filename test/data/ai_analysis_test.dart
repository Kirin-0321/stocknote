import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/ai/ai_settings.dart';
import 'package:stocknote/data/ai/llm.dart';
import 'package:stocknote/data/ai/market_analysis_service.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/ai_analysis_repository.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';
import 'package:stocknote/domain/journal/entry_class.dart';

import '../helpers/fake_llm.dart';
import '../helpers/fake_market.dart';

const _valid = validAnalysisJson;

void main() {
  test('解析：容忍代码块，规范化周期 / 方向 / 信心度', () {
    final a = MarketAnalysis.fromJson(extractJsonObject(_valid)!)!;
    expect(a.sentimentScore, 62);
    expect(a.support, [3280, 3250]);
    expect(a.outlook!.horizon, 't1');
    expect(a.outlook!.direction, 'up');
    expect(a.outlook!.confidence, closeTo(0.6, 1e-9));
    expect(extractJsonObject('抱歉无法分析'), isNull);
    expect(MarketAnalysis.fromJson({'foo': 1}), isNull);
  });

  group('MarketAnalysisService', () {
    late AppDatabase db;
    late DateTime clock;
    late FakeLlm llm;
    late MarketAnalysisService svc;
    late PredictionRepository preds;
    late AiConfigRepository config;
    late SettingsStore settings;
    late JournalRepository journal;
    final cal = TradingCalendar();

    MarketOverview overview() => MarketOverview(
          fetchedAt: clock,
          indices: [FakeSource.quote('000001.SH', 3300, 3280), FakeSource.quote('399006.SZ', 2100, 2120)],
          breadth: const Breadth(up: 3000, down: 1800, flat: 200),
          turnover: const Turnover(today: 1.2e12, yesterdaySameTime: 1.0e12),
        );

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);
      settings = SettingsStore(db);
      config = AiConfigRepository(settings, MemorySecretStore(), envDeepseekKey: 'sk-test');
      preds = PredictionRepository(db, cal, now: () => clock);
      journal = JournalRepository(db, cal, now: () => clock);
      final source = FakeSource(SourceId.tushare)
        ..klines['000001.SH'] = [
          KBar(date: '20261111', open: 3250, high: 3260, low: 3240, close: 3255, amount: 9e11),
          KBar(date: '20261112', open: 3255, high: 3285, low: 3250, close: 3280, amount: 1e12),
        ];
      svc = MarketAnalysisService(
        config: config,
        repo: AiAnalysisRepository(db, now: () => clock),
        predictions: preds,
        journal: journal,
        market: MarketService(MarketRouter([source], now: () => clock)),
        calendar: cal,
        settings: settings,
        overview: () async => overview(),
        providerFactory: (_) => llm,
        now: () => clock,
      );
    });
    tearDown(() => db.close());

    test('分析：输入含盘面与日记；保存记录并生成 AI 判断', () async {
      await journal.create(
          content: '半导体放量，看多', classification: const EntryClass(category: 'judge', stance: 'bull'));
      llm = FakeLlm([_valid]);
      final row = await svc.analyze();

      final input = llm.calls.single[1].content;
      expect(input, contains('上证指数(000001.SH) 3300.00 +0.61%'));
      expect(input, contains('上涨 3000 家'));
      expect(input, contains('20261112 3280.00 +0.77%'));
      expect(input, contains('[判断] 半导体放量，看多'));

      expect(row.model, 'fake');
      expect(row.output!['trend'], '震荡偏强');
      final p = (await preds.forAnalysis(row.id))!;
      expect((p.source, p.targetCode, p.direction, p.horizonType), ('ai', '000001.SH', 'up', 't1'));
      expect(p.basePrice, 3300);
      expect(p.dueDate, '20261116');
      expect(p.confidence, 3);
    });

    test('输出不是 JSON 时重试一次；仍失败则保存原文，不生成判断', () async {
      llm = FakeLlm(['今天大盘不错', _valid]);
      var row = await svc.analyze();
      expect(llm.calls, hasLength(2));
      expect(llm.calls[1].last.content, contains('JSON'));
      expect(row.output, isNotNull);
      expect((row.tokensIn, row.tokensOut), (200, 100));

      llm = FakeLlm(['不知道', '还是不知道']);
      row = await svc.analyze();
      expect(row.output, isNull);
      expect(row.rawText, '还是不知道');
      expect(await preds.forAnalysis(row.id), isNull);
    });

    test('未配置 Key 时报错', () async {
      final noKey = AiConfigRepository(settings, MemorySecretStore(), envDeepseekKey: '');
      expect(await noKey.configFor(AiTask.analysis), isNull);
    });

    test('定时分析：每个时点只执行一次，过时不补，开关关闭不执行', () async {
      llm = FakeLlm(List.filled(5, _valid));
      clock = MarketClock.fromMarket(2026, 11, 13, 9, 30);
      expect(await svc.runScheduledIfDue(), isFalse);
      clock = MarketClock.fromMarket(2026, 11, 13, 9, 36);
      expect(svc.dueSlot(), '20261113-0935');
      expect(await svc.runScheduledIfDue(), isTrue);
      expect(await svc.runScheduledIfDue(), isFalse);
      clock = MarketClock.fromMarket(2026, 11, 13, 11, 0);
      expect(svc.dueSlot(), isNull, reason: '9:35 时点超过 60 分钟');
      clock = MarketClock.fromMarket(2026, 11, 13, 15, 10);
      await config.save(const AiSettings(scheduleEnabled: false));
      expect(await svc.runScheduledIfDue(), isFalse);
      clock = MarketClock.fromMarket(2026, 11, 14, 9, 40); // 周六
      expect(svc.dueSlot(), isNull);
      expect(llm.calls, hasLength(1));
    });
  });

  group('AI 设置', () {
    test('默认 deepseek-flash + 思考 max；Key 优先用 App 内填写的，否则用 .env', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final secrets = MemorySecretStore();
      final repo = AiConfigRepository(SettingsStore(db), secrets, envDeepseekKey: 'sk-env');
      var c = (await repo.configFor(AiTask.analysis))!;
      expect((c.presetId, c.model, c.effort, c.apiKey), ('deepseek', 'deepseek-flash', 'max', 'sk-env'));
      expect(await repo.keyFromEnv('deepseek'), isTrue);

      await repo.setApiKey('deepseek', 'sk-user');
      await repo.save(const AiSettings(tasks: {AiTask.analysis: TaskModel('deepseek', 'deepseek-v4-pro', effort: '')}));
      c = (await repo.configFor(AiTask.analysis))!;
      expect((c.model, c.effort, c.apiKey), ('deepseek-v4-pro', null, 'sk-user'));
      expect(await repo.configFor(AiTask.agent), isNotNull, reason: '其他任务仍用默认');

      await repo.save(const AiSettings(tasks: {AiTask.analysis: TaskModel('kimi', 'kimi-latest')}));
      expect(await repo.configFor(AiTask.analysis), isNull, reason: 'Kimi 未配置 Key');
      await db.close();
    });

    test('OpenAI 兼容请求：Bearer 鉴权、JSON 模式、reasoning_effort、用量', () async {
      late RequestOptions sent;
      final dio = Dio()
        ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
          sent = o;
          h.resolve(Response(requestOptions: o, statusCode: 200, data: {
            'model': 'deepseek-flash',
            'choices': [
              {'message': {'content': '{"ok":true}'}},
            ],
            'usage': {'prompt_tokens': 12, 'completion_tokens': 34},
          }));
        }));
      final p = OpenAiCompatibleProvider(
        const LlmConfig(
            presetId: 'deepseek',
            protocol: LlmProtocol.openai,
            baseUrl: 'https://api.deepseek.com/',
            model: 'deepseek-flash',
            apiKey: 'sk-x',
            effort: 'max'),
        dio: dio,
      );
      final r = await p.chat([const LlmMessage.system('s'), const LlmMessage.user('u')], json: true);
      expect(sent.uri.toString(), 'https://api.deepseek.com/chat/completions');
      expect(sent.headers['Authorization'], 'Bearer sk-x');
      final body = sent.data as Map;
      expect(body['reasoning_effort'], 'max');
      expect(body['response_format'], {'type': 'json_object'});
      expect(body['max_tokens'], greaterThanOrEqualTo(32000));
      expect(jsonDecode(r.text), {'ok': true});
      expect((r.tokensIn, r.tokensOut), (12, 34));
    });

    test('Anthropic 请求：system 单独传、版本头、effort、refusal 报错', () async {
      late RequestOptions sent;
      var stop = 'end_turn';
      final dio = Dio()
        ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
          sent = o;
          h.resolve(Response(requestOptions: o, statusCode: 200, data: {
            'model': 'claude-opus-5-5',
            'stop_reason': stop,
            'content': [
              {'type': 'thinking', 'thinking': ''},
              {'type': 'text', 'text': 'hi'},
            ],
            'usage': {'input_tokens': 5, 'output_tokens': 6},
          }));
        }));
      final p = AnthropicProvider(
        const LlmConfig(
            presetId: 'anthropic',
            protocol: LlmProtocol.anthropic,
            baseUrl: 'https://api.anthropic.com',
            model: 'claude-opus-5-5',
            apiKey: 'k',
            effort: 'high'),
        dio: dio,
      );
      final r = await p.chat([const LlmMessage.system('s'), const LlmMessage.user('u')]);
      expect(sent.uri.toString(), 'https://api.anthropic.com/v1/messages');
      expect(sent.headers['x-api-key'], 'k');
      expect(sent.headers['anthropic-version'], '2026-10-21');
      final body = sent.data as Map;
      expect(body['system'], 's');
      expect((body['messages'] as List).single, {'role': 'user', 'content': 'u'});
      expect(body['output_config'], {'effort': 'high'});
      expect(r.text, 'hi');
      stop = 'refusal';
      expect(() => p.chat([const LlmMessage.user('u')]), throwsA(isA<LlmException>()));
    });
  });
}
