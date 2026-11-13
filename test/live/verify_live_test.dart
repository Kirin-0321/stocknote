@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/tushare_source.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/service/verification_service.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/verify/threshold.dart';

/// 用 Tushare 真实日 K 验证历史判断。
void main() {
  final token = Platform.environment['TUSHARE_TOKEN'];
  test('11/10 盘中判断（个股 / 大盘 / 板块），用真实日 K 判定', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final ts = TushareSource(token);
    final cal = TradingCalendar(await ts.calendar(from: '20261001', to: '20261231'));
    final journal = JournalRepository(db, cal, now: () => MarketClock.fromMarket(2026, 11, 10, 10, 30));
    final now = MarketClock.fromMarket(2026, 11, 13, 16, 0);
    final preds = PredictionRepository(db, cal, now: () => now);
    for (final (codes, sub, stance, horizon) in [
      (['600519.SH'], 'stock', 'bull', 't1'),
      (<String>[], 'market', 'bear', 't1'),
      (['BK1036.EM'], 'sector', 'range', 'close'),
    ]) {
      final e = await journal.create(
          content: 'live',
          instrumentCodes: codes,
          classification: EntryClass(category: 'judge', subcategory: sub, stance: stance, horizon: horizon));
      await preds.syncFromEntry(e);
    }
    final svc = VerificationService(
      repo: preds,
      market: MarketService(MarketRouter([ts])),
      calendar: cal,
      thresholds: () async => const ThresholdConfig(),
    );
    final r = await svc.runDue();
    for (final v in await preds.all()) {
      final p = v.prediction;
      // ignore: avoid_print
      print('${p.targetCode} ${p.direction} ${p.horizonType} due=${p.dueDate} base=${p.basePrice} '
          '→ ${v.result?.actualClose} ${v.result?.changePct?.toStringAsFixed(2)}% ${v.result?.status}');
    }
    expect(r.verified, 3, reason: 'errors=${r.errors} waiting=${r.waiting}');
    await db.close();
  }, skip: token == null ? '未设置 TUSHARE_TOKEN' : null, timeout: const Timeout(Duration(minutes: 2)));
}

