@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/agent/agent_service.dart';
import 'package:stocknote/data/agent/agent_tools.dart';
import 'package:stocknote/data/ai/ai_settings.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/snapshot_service.dart';
import 'package:stocknote/data/market/tushare_source.dart';
import 'package:stocknote/data/repo/agent_repository.dart';
import 'package:stocknote/data/repo/ai_analysis_repository.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/market_snapshot_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/repo/trade_repository.dart';
import 'package:stocknote/data/service/journal_service.dart';
import 'package:stocknote/data/service/verification_service.dart';
import 'package:stocknote/data/settings/settings_store.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/trade/portfolio.dart';
import 'package:stocknote/domain/verify/threshold.dart';

/// 真实 DeepSeek（deepseek-flash，思考 max）+ Tushare：模拟一周的判断，问"我本周判断准确率与原因"。
void main() {
  final token = Platform.environment['TUSHARE_TOKEN'];
  final key = Platform.environment['DEEPSEEK_API_KEY'];

  test('Agent 基于本地数据回答本周判断准确率与原因（M6 验收）', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final ts = TushareSource(token);
    final cal = TradingCalendar(await ts.calendar(from: '20261001', to: '20261231'));
    final market = MarketService(MarketRouter([ts]));
    final now = MarketClock.fromMarket(2026, 11, 16, 16, 0); // 周一盘后，"本周"取上周
    var clock = MarketClock.fromMarket(2026, 11, 9, 10, 0);
    final journal = JournalRepository(db, cal, now: () => clock);
    final preds = PredictionRepository(db, cal, now: () => clock);
    final instruments = InstrumentRepository(db);
    await instruments.upsertAll(const [
      InstrumentInfo(code: '600519.SH', name: '贵州茅台', type: InstrumentType.stock),
      InstrumentInfo(code: '510300.SH', name: '沪深300ETF', type: InstrumentType.etf),
    ]);
    // 上周（11/9–11/13）的判断
    for (final (day, codes, sub, stance, horizon, content) in [
      (9, <String>[], 'market', 'bull', 't1', '量能放大，大盘明天继续涨'),
      (10, ['600519.SH'], 'stock', 'bull', 't1', '茅台回踩到位，看多'),
      (11, ['510300.SH'], 'index', 'bull', 't3', '沪深300 站上均线，三天内看涨'),
      (12, <String>[], 'market', 'bear', 'close', '尾盘跳水风险大，今天收跌'),
      (13, ['600519.SH'], 'stock', 'range', 't1', '茅台震荡整理'),
    ]) {
      clock = MarketClock.fromMarket(2026, 11, day, 10, 30);
      final e = await journal.create(
          content: content,
          instrumentCodes: codes,
          classification: EntryClass(category: 'judge', subcategory: sub, stance: stance, horizon: horizon));
      await preds.syncFromEntry(e);
    }
    clock = now;
    await VerificationService(
      repo: preds,
      market: market,
      calendar: cal,
      thresholds: () async => const ThresholdConfig(),
      now: () => now,
    ).runDue();

    final settings = SettingsStore(db);
    final agentRepo = AgentRepository(db, now: () => now);
    final trades = TradeRepository(db);
    final svc = AgentService(
      repo: agentRepo,
      toolDeps: AgentToolDeps(
        journal: journal,
        predictions: preds,
        trades: trades,
        instruments: instruments,
        analyses: AiAnalysisRepository(db),
        agent: agentRepo,
        market: market,
        calendar: cal,
        overview: () => market.overview(defaultBoardIndices, '20261116'),
        costMethod: () => CostMethod.diluted,
        now: () => now,
      ),
      aiConfig: AiConfigRepository(settings, MemorySecretStore(), envDeepseekKey: key),
      settings: settings,
      journalService: JournalService(
        journal: journal,
        predictions: preds,
        snapshots: SnapshotService(market: market, repo: MarketSnapshotRepository(db), latestOverview: () => null),
      ),
      calendar: cal,
      now: () => now,
    );
    await agentRepo.addMemory(kind: MemoryKind.rule, content: '不追涨停板', importance: 4);

    final thread = await agentRepo.createThread();
    final sw = Stopwatch()..start();
    final progress = <String>[];
    await svc.send(thread.id, '我上周（11月9日到13日）的判断准确率怎么样？错在哪里？', onProgress: progress.add);
    final msgs = await agentRepo.messages(thread.id);
    final tools = [for (final m in msgs.where((m) => m.role == 'tool')) (jsonDecode(m.toolCalls!) as Map)['name']];
    final answer = msgs.last;
    // ignore: avoid_print
    print('耗时 ${sw.elapsed.inSeconds}s，工具：$tools\n进度：$progress\n---\n${answer.content}');
    expect(answer.role, 'assistant');
    expect(tools, anyOf(contains('get_prediction_stats'), contains('get_predictions')));
    expect(answer.content, contains('%'));
    expect((await agentRepo.thread(thread.id))!.title, isNot('新对话'));

    // 记住 → 生成确认卡片，确认后写入记忆
    await svc.send(thread.id, '记住：我不在尾盘最后半小时做判断。');
    final cardMsg = (await agentRepo.messages(thread.id))
        .lastWhere((m) => m.role == 'tool' && m.toolCalls!.contains('"card"'), orElse: () => msgs.first);
    expect(cardMsg.role, 'tool', reason: '应生成记忆确认卡片');
    await svc.confirmCard(cardMsg);
    final mems = await agentRepo.activeMemories();
    // ignore: avoid_print
    print('记忆：${mems.map((m) => m.content).toList()}');
    expect(mems.length, 2);
    await db.close();
  },
      skip: token == null || key == null ? '需要 TUSHARE_TOKEN 与 DEEPSEEK_API_KEY' : null,
      timeout: const Timeout(Duration(minutes: 8)));
}
