import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/app/app.dart';

void main() {
  testWidgets('主框架显示 5 个 Tab，默认打开日记，可切换', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StockNoteApp()));
    await tester.pumpAndSettle();

    for (final label in ['大盘', '日记', '复盘', '持仓', '设置']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('M1 开发中'), findsOneWidget);

    await tester.tap(find.text('大盘').last);
    await tester.pumpAndSettle();
    expect(find.text('M2 开发中'), findsOneWidget);
  });
}
