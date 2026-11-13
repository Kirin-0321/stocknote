import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stocknote/app/app.dart';
import 'package:stocknote/app/providers.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/repo/quick_phrase_repository.dart';

void main() {
  late AppDatabase db;
  // 2026-11-13 周五 10:05（上海）
  final clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);

  setUp(() {
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

    // 选"看多"，插入短语"放量突破"，再补充文字后回车
    await tester.tap(find.widgetWithText(ChoiceChip, '看多'));
    await tester.tap(find.widgetWithText(ActionChip, '放量突破'));
    await tester.pump();
    await tester.enterText(input, '放量突破 #突破');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text('早盘'), findsOneWidget);
    expect(find.text('10:05'), findsOneWidget);
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
    await tester.tap(find.byKey(const Key('edit-save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('第二条（改）'), findsOneWidget);
    expect(find.text('已修改 1 次'), findsOneWidget);
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
