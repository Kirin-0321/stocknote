import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stocknote/app/app.dart';
import 'package:stocknote/app/providers.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/features/market/market_page.dart';
import 'package:stocknote/data/repo/quick_phrase_repository.dart';
import 'package:stocknote/data/settings/settings_store.dart';

import 'helpers/fake_market.dart';

void main() {
  late AppDatabase db;
  late FakeSource source;
  // 2026-11-13 周五 10:05（上海）
  final clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);

  setUp(() {
    source = FakeSource(SourceId.eastmoney);
    db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.runAsync(() => QuickPhraseRepository(db, now: () => clock).seedDefaultsIfNeeded());
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => clock),
        secretStoreProvider.overrideWithValue(MemorySecretStore()),
        marketSourcesProvider.overrideWithValue([source]),
      ],
      child: const StockNoteApp(),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await db.close();
  }

  testWidgets('默认打开日记页，显示今天与 5 个 Tab', (tester) async {
    await pumpApp(tester);
    expect(find.text('11月13日 周五'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    for (final label in ['大盘', '日记', '复盘', '持仓', '设置']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.textContaining('今天还没有记录'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('快捷输入：回车保存、按时段分组、选要素、插入短语，然后编辑产生修改历史',
      (tester) async {
    await pumpApp(tester);

    final input = find.byKey(const Key('composer-input'));
    await tester.tap(input);
    await tester.pumpAndSettle();

    // 输入栏只有一排：分类按钮 + 常用短语
    expect(find.byKey(const Key('category-button')), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '看多'), findsNothing);

    // 打开分类列表：一级"判断" → 二级"大盘""看多" → 完成
    await tester.tap(find.byKey(const Key('category-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '判断'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, '大盘'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, '看多'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('category-done')));
    await tester.pumpAndSettle();
    expect(find.text('判断·大盘 · 看多'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, '放量突破'));
    await tester.pump();
    await tester.enterText(input, '放量突破 #突破');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text('早盘'), findsOneWidget);
    expect(find.text('10:05'), findsOneWidget);
    expect(find.text('判断·大盘'), findsOneWidget);
    expect(find.text('看多'), findsWidgets);

    // 连续第二条
    await tester.enterText(input, '第二条');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.textContaining('第二条'), findsOneWidget);

    // 点击编辑第二条
    await tester.tap(find.textContaining('第二条'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('edit-content')), '第二条（改）');
    await tester.ensureVisible(find.byKey(const Key('edit-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('第二条（改）'), findsOneWidget);
    expect(find.text('已修改 1 次'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('大盘看板显示指数、宽度、成交额、板块与 ETF', (tester) async {
    await pumpApp(tester);
    Finder boardScroll() => find.descendant(of: find.byType(MarketPage), matching: find.byType(Scrollable)).first;
    await tester.tap(find.text('大盘').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('上证指数'), findsOneWidget);
    expect(find.text('交易中 · 更新于', findRichText: false), findsNothing);
    expect(find.textContaining('交易中'), findsOneWidget);
    expect(find.text('涨 3000'), findsOneWidget);
    expect(find.text('60'), findsOneWidget); // 涨停
    expect(find.text('25.0%'), findsOneWidget); // 炸板率
    await tester.scrollUntilVisible(find.text('+11.11%'), 200, scrollable: boardScroll()); // 较昨日同时段
    expect(find.text('放量'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('行业涨0'), 200, scrollable: boardScroll());
    expect(find.text('龙头0'), findsOneWidget);
    await tester.ensureVisible(find.text('跌幅'));
    await tester.pump();
    await tester.tap(find.text('跌幅'));
    await tester.pump();
    expect(find.text('行业跌0'), findsOneWidget);

    // 离开大盘页后停止轮询
    await tester.tap(find.text('日记').last);
    await tester.pump();
    final calls = source.calls;
    await tester.pump(const Duration(seconds: 30));
    expect(source.calls, calls);
    await disposeApp(tester);
  });

  testWidgets('记录日记时自动绑定行情快照', (tester) async {
    await pumpApp(tester);
    final input = find.byKey(const Key('composer-input'));
    await tester.enterText(input, '看一下 \$600519');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.textContaining('上证 '), findsOneWidget);
    expect(find.textContaining('600519.SH '), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('输入 \$ 弹出标的联想，按首字母匹配并选择', (tester) async {
    await tester.runAsync(() => InstrumentRepository(db).upsertAll(const [
          InstrumentInfo(code: '600519.SH', name: '贵州茅台', type: InstrumentType.stock),
          InstrumentInfo(code: 'BK1036.EM', name: '半导体', type: InstrumentType.sector),
          InstrumentInfo(code: '512480.SH', name: '半导体ETF', type: InstrumentType.etf),
        ]));
    await pumpApp(tester);
    final input = find.byKey(const Key('composer-input'));
    await tester.tap(input);
    await tester.pumpAndSettle();

    await tester.enterText(input, '关注 \$');
    await tester.pump();
    expect(find.textContaining('输入代码 / 名称 / 首字母'), findsOneWidget);

    await tester.enterText(input, '关注 \$BDT');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    expect(find.byKey(const Key('suggest-BK1036.EM')), findsOneWidget);
    expect(find.byKey(const Key('suggest-512480.SH')), findsOneWidget);
    expect(find.text('板块'), findsOneWidget);

    await tester.tap(find.byKey(const Key('suggest-512480.SH')));
    await tester.pump();
    expect(find.text('关注 \$半导体ETF '), findsOneWidget);
    expect(find.byKey(const Key('suggest-BK1036.EM')), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    final entry = (await tester.runAsync(() => db.select(db.journalEntries).getSingle()))!;
    expect(entry.instrumentCodes, ['512480.SH']);
    await disposeApp(tester);
  });

  testWidgets('切换到设置页可打开常用短语', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('常用短语'));
    await tester.pumpAndSettle();
    expect(find.text('缩量回调'), findsOneWidget);
    await disposeApp(tester);
  });
}







