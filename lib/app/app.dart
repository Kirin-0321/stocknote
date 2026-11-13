import 'package:material_ui/material_ui.dart';

import 'home_shell.dart';
import 'theme.dart';

class StockNoteApp extends StatelessWidget {
  const StockNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '交易日记',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeShell(),
    );
  }
}
