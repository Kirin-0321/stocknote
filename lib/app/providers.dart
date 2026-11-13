import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendar/trading_calendar.dart';
import '../data/db/app_database.dart';
import '../data/repo/calendar_repository.dart';
import '../data/repo/journal_repository.dart';
import '../data/repo/quick_phrase_repository.dart';

/// 数据库单例。在 main / 测试中通过 override 注入。
final databaseProvider = Provider<AppDatabase>(
    (ref) => throw UnimplementedError('databaseProvider must be overridden'));

/// 当前时间来源，测试中可固定。
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// 交易日历。启动时从数据库加载，Tushare 同步后（M2）调用 [CalendarNotifier.set] 更新。
class CalendarNotifier extends Notifier<TradingCalendar> {
  CalendarNotifier([this._initial]);
  final TradingCalendar? _initial;

  @override
  TradingCalendar build() => _initial ?? TradingCalendar();

  void set(TradingCalendar calendar) => state = calendar;
}

final tradingCalendarProvider =
    NotifierProvider<CalendarNotifier, TradingCalendar>(CalendarNotifier.new);

final calendarRepositoryProvider =
    Provider((ref) => CalendarRepository(ref.watch(databaseProvider)));

final journalRepositoryProvider = Provider((ref) => JournalRepository(
      ref.watch(databaseProvider),
      ref.watch(tradingCalendarProvider),
      now: ref.watch(clockProvider),
    ));

final quickPhraseRepositoryProvider = Provider((ref) => QuickPhraseRepository(
      ref.watch(databaseProvider),
      now: ref.watch(clockProvider),
    ));
