import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendar/trading_calendar.dart';
import '../data/db/app_database.dart';
import '../data/repo/calendar_repository.dart';
import '../data/repo/journal_repository.dart';

/// 数据库单例。测试中可 override 为内存库。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final calendarRepositoryProvider =
    Provider((ref) => CalendarRepository(ref.watch(databaseProvider)));

final tradingCalendarProvider = FutureProvider<TradingCalendar>(
    (ref) => ref.watch(calendarRepositoryProvider).load());

final journalRepositoryProvider = FutureProvider<JournalRepository>((ref) async {
  final calendar = await ref.watch(tradingCalendarProvider.future);
  return JournalRepository(ref.watch(databaseProvider), calendar);
});
