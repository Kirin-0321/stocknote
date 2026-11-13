import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/db/app_database.dart';
import 'data/repo/calendar_repository.dart';
import 'data/repo/quick_phrase_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  final calendar = await CalendarRepository(db).load();
  await QuickPhraseRepository(db).seedDefaultsIfNeeded();

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      tradingCalendarProvider.overrideWith(() => CalendarNotifier(calendar)),
    ],
    child: const StockNoteApp(),
  ));
}
