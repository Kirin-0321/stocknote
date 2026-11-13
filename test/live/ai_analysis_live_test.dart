@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/ai/ai_settings.dart';
import 'package:stocknote/data/ai/market_analysis_service.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/tushare_source.dart';
import 'package:stocknote/data/repo/ai_analysis_repository.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';

/// 真实 Tushare 行情 + DeepSeek（deepseek-flash，思考 max）跑一次大盘分析。
void main() {
  final token = Platform.environment['TUSHARE_TOKEN'];
  final key = Platform.environment['DEEPSEEK_API_KEY'];
  test('AI 大盘分析：结构化输出并生成 AI 判断', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final ts = TushareSource(token);
    final now = DateTime.now();
    final cal = TradingCalendar(await ts.calendar(from: '20261001', to: '20261231'));
    final market = MarketService(MarketRouter([ts]));
    final settings = SettingsStore(db);
    final config = AiConfigRepository(settings, MemorySecretStore(), envDeepseekKey: key);
    final preds = PredictionRepository(db, cal);
    final svc = MarketAnalysisService(
      config: config,
      repo: AiAnalysisRepository(db),
      predictions: preds,
      journal: JournalRepository(db, cal),
      market: market,
      calendar: cal,
      settings: settings,
      overview: () {
        final d = cal.isTradingDay(MarketClock.marketDate(now)) ? MarketClock.marketDate(now) : cal.previous(MarketClock.marketDate(now));
        return market.overview(defaultBoardIndices, TradeDate.format(d));
      },
    );
    final sw = Stopwatch()..start();
    final row = await svc.analyze();
    // ignore: avoid_print
    print('model=${row.model} tokens=${row.tokensIn}/${row.tokensOut} ${sw.elapsed.inSeconds}s');
    // ignore: avoid_print
    print(row.rawText);
    final a = MarketAnalysis.of(row);
    expect(a, isNotNull, reason: row.rawText);
    expect(MarketAnalysis.trends, contains(a!.trend));
    expect(a.outlook, isNotNull);
    final p = await preds.forAnalysis(row.id);
    expect(p!.source, 'ai');
    // ignore: avoid_print
    print('AI 判断：${p.targetCode} ${p.direction} ${p.horizonType} 到期 ${p.dueDate} base=${p.basePrice} 信心=${p.confidence}');
    await db.close();
  },
      skip: token == null || key == null ? '需要 TUSHARE_TOKEN 与 DEEPSEEK_API_KEY' : null,
      timeout: const Timeout(Duration(minutes: 5)));
}
