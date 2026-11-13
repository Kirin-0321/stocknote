import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stocknote/app/app.dart';
import 'package:stocknote/app/providers.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/features/journal/widgets/composer_toolbar.dart';
import 'package:stocknote/features/market/market_page.dart';
import 'package:stocknote/features/review/prediction_detail_page.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/prediction_repository.dart';
import 'package:stocknote/data/repo/quick_phrase_repository.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/data/settings/settings_store.dart';

import 'package:stocknote/data/ai/ai_settings.dart';

import 'helpers/fake_llm.dart';
import 'helpers/fake_market.dart';

void main() {
  late AppDatabase db;
  late FakeSource source;
  DateTime? clockOverride;
  // 2026-11-13 周五 10:05（上海）
  final clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);

  setUp(() {
    source = FakeSource(SourceId.eastmoney);
    db = AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ));
  });

  Future<void> pumpApp(WidgetTester tester, {List<Override> extra = const []}) async {
    await tester.runAsync(() => QuickPhraseRepository(db, now: () => clock).seedDefaultsIfNeeded());
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => clockOverride ?? clock),
        secretStoreProvider.overrideWithValue(MemorySecretStore()),
        marketSourcesProvider.overrideWithValue([source]),
        ...extra,
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

    // 输入栏一排四个按钮：一级 / 二级 / 标签 / 快捷；未打开时不显示列表
    for (final k in ['tb-category', 'tb-sub', 'tb-tags', 'tb-phrases']) {
      expect(find.byKey(Key(k)), findsOneWidget);
    }
    expect(find.byKey(const Key('opt-category-judge')), findsNothing);

    // 一级 → 选"判断"后自动展开二级列表 → 选"大盘"后自动展开标签列表 → 选"看多""T+1"
    await tester.tap(find.byKey(const Key('tb-category')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('opt-category-judge')));
    await tester.pump();
    expect(find.byKey(const Key('opt-subcategory-market')), findsOneWidget);
    await tester.tap(find.byKey(const Key('opt-subcategory-market')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('opt-stance-bull')));
    await tester.pump();
    await tester.scrollUntilVisible(find.byKey(const Key('opt-horizon-t1')), 60,
        scrollable: find.descendant(of: find.byType(ChoicePanel), matching: find.byType(Scrollable)));
    await tester.tap(find.byKey(const Key('opt-horizon-t1')));
    await tester.pump();
    // 按钮显示当前选择
    expect(find.descendant(of: find.byKey(const Key('tb-category')), matching: find.text('判断')),
        findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('tb-sub')), matching: find.text('大盘')),
        findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('tb-tags')), matching: find.text('看多·T+1')),
        findsOneWidget);

    // 快捷：插入短语后列表关闭
    await tester.tap(find.byKey(const Key('tb-phrases')));
    await tester.pump();
    await tester.tap(find.text('放量突破'));
    await tester.pump();
    expect(find.text('缩量回调'), findsNothing);
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

  testWidgets('AI 分析：看板触发 → 卡片 → 详情引用到日记 → 复盘出现 AI 判断', (tester) async {
    final llm = FakeLlm([validAnalysisJson]);
    clockOverride = MarketClock.fromMarket(2026, 11, 13, 10, 40); // 不在定时分析时点内
    addTearDown(() => clockOverride = null);
    await pumpApp(tester, extra: [
      aiConfigRepositoryProvider.overrideWith((ref) => AiConfigRepository(
          ref.watch(settingsStoreProvider), ref.watch(secretStoreProvider),
          envDeepseekKey: 'sk-test')),
      llmFactoryProvider.overrideWithValue((_) => llm),
    ]);
    await tester.tap(find.text('大盘').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final scroll = find.descendant(of: find.byType(MarketPage), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const Key('ai-run')), 200, scrollable: scroll);
    await tester.pump();
    expect(tester.widget<TextButton>(find.byKey(const Key('ai-run'))).onPressed, isNotNull, reason: 'Key 已配置');
    await tester.tap(find.byKey(const Key('ai-run')));
    for (var i = 0; i < 20 && find.text('偏强震荡').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(llm.calls, hasLength(1));
    expect(find.text('偏强震荡'), findsOneWidget);
    expect(find.text('展望：上证指数 T+1 看多 · 信心 60%'), findsOneWidget);

    await tester.tap(find.text('偏强震荡'));
    await tester.pumpAndSettle();
    expect(find.text('高位股分歧'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ai-quote')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    expect(find.textContaining('写入今天的日记'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('复盘').last);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('待复盘 0'), findsOneWidget);
    await tester.tap(find.text('进行中 1'));
    await tester.pumpAndSettle();
    expect(find.text('AI'), findsOneWidget);
    await tester.tap(find.text('日记').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('AI 分析（震荡偏强，情绪 62）'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('复盘：到期判断自动验证 → 待复盘 → 详情写复盘 → 统计', (tester) async {
    // 前一交易日（11/12）盘中的判断：$600519 看多 T+1，到期 11/13；当前时钟 11/13 10:05 尚未到期
    final cal = TradingCalendar();
    await tester.runAsync(() async {
      final journal = JournalRepository(db, cal, now: () => MarketClock.fromMarket(2026, 11, 12, 10, 0));
      final e = await journal.create(
        content: '放量突破看多',
        instrumentCodes: ['600519.SH'],
        classification: const EntryClass(category: 'judge', subcategory: 'stock', stance: 'bull', horizon: 't1'),
      );
      await PredictionRepository(db, cal, now: () => clock).syncFromEntry(e);
    });
    source.klines['600519.SH'] = [
      const KBar(date: '20261111', open: 1400, high: 1400, low: 1400, close: 1400),
      const KBar(date: '20261112', open: 1405, high: 1420, low: 1398, close: 1410),
      const KBar(date: '20261113', open: 1412, high: 1440, low: 1408, close: 1435),
    ];
    clockOverride = MarketClock.fromMarket(2026, 11, 13, 16, 0);
    await pumpApp(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    // 复盘 Tab 角标
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('1')), findsOneWidget);
    await tester.tap(find.text('复盘').last);
    await tester.pumpAndSettle();
    expect(find.text('待复盘 1'), findsOneWidget);
    expect(find.text('正确'), findsOneWidget);
    expect(find.text('+2.50%'), findsOneWidget); // 基准取前一日收盘 1400 → 1435

    await tester.tap(find.textContaining('放量突破看多'));
    await tester.pumpAndSettle();
    expect(find.byType(PredictionDetailPage), findsOneWidget);
    await tester.dragUntilVisible(
        find.byKey(const Key('review-save')),
        find.descendant(of: find.byType(PredictionDetailPage), matching: find.byType(ListView)).first,
        const Offset(0, -200));
    await tester.drag(
        find.descendant(of: find.byType(PredictionDetailPage), matching: find.byType(ListView)).first,
        const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('逻辑正确'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('review-save')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(PredictionDetailPage))).pop();
    await tester.pumpAndSettle();
    expect(find.text('待复盘 0'), findsOneWidget);

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsWidgets);
    await disposeApp(tester);
    clockOverride = null;
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










