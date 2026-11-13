import '../../core/calendar/trading_calendar.dart';
import '../db/app_database.dart';

/// 交易日历的持久化。数据由 Tushare `trade_cal` 同步写入（M2）。
class CalendarRepository {
  CalendarRepository(this._db);

  final AppDatabase _db;

  Future<TradingCalendar> load() async {
    final rows = await _db.select(_db.tradingDays).get();
    return TradingCalendar({for (final r in rows) r.date: r.isOpen});
  }

  /// 批量写入（覆盖同日期）。key: yyyyMMdd。
  Future<void> upsertAll(Map<String, bool> days) => _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.tradingDays,
          [
            for (final e in days.entries)
              TradingDaysCompanion.insert(date: e.key, isOpen: e.value),
          ],
        );
      });
}
