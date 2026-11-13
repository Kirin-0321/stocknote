@Tags(['live'])
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/ai/ai_settings.dart';
import 'package:stocknote/data/ai/llm.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/import/import_service.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/tushare_source.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/data/repo/trade_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';

/// 券商 App 常见显示名 → 期望代码。现价取期望代码的实时行情，模拟截图中的现价。
const brokerNames = [
  ('贵州茅台', '600519.SH'),
  ('沪深300ETF华泰柏瑞', '510300.SH'),
  ('证券ETF国泰', '512880.SH'),
  ('创业板ETF易方达', '159915.SZ'),
  ('科创50ETF华夏', '588000.SH'),
  ('中证500ETF南方', '510500.SH'),
  ('酒ETF鹏华', '512690.SH'),
  ('纳指ETF国泰', '513100.SH'),
];

void main() {
  final token = Platform.environment['TUSHARE_TOKEN'];
  test('券商名称解析为代码，并用现价确认', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final ts = TushareSource(token);
    final instruments = InstrumentRepository(db);
    await instruments.upsertAll(await ts.instruments());
    final market = MarketService(MarketRouter([ts]));
    final svc = TradeImportService(
      trades: TradeRepository(db),
      mappings: ColumnMappingRepository(db),
      instruments: instruments,
      market: market,
      aiConfig: AiConfigRepository(SettingsStore(db), MemorySecretStore(), envDeepseekKey: ''),
      llmFactory: LlmProvider.of,
    );
    var ok = 0;
    for (final (name, expected) in brokerNames) {
      final price = (await market.quotes([expected])).single.price;
      final code = await svc.resolveName(name, price: price);
      final i = code == null ? null : await instruments.get(code);
      if (code == expected) ok++;
      // ignore: avoid_print
      print('${code == expected ? '✓' : '✗'} $name → $code ${i?.name}（期望 $expected，现价 $price）');
    }
    expect(ok, brokerNames.length);
    await db.close();
  }, skip: token == null ? '需要 TUSHARE_TOKEN' : null, timeout: const Timeout(Duration(minutes: 3)));
}
