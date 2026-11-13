import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../market/market_router.dart';
import '../market/models.dart';
import '../market/sources.dart';
import '../repo/calendar_repository.dart';
import '../repo/instrument_repository.dart';
import '../settings/settings_store.dart';

class SyncResult {
  const SyncResult({this.calendarDays = 0, this.instruments = 0, this.errors = const []});
  final int calendarDays;
  final int instruments;
  final List<String> errors;

  bool get ok => errors.isEmpty;
}

/// 基础数据同步：交易日历 + 代码表，每天最多一次（spec 5.3）。
class BaseDataSync {
  BaseDataSync({
    required this.router,
    required this.calendarRepo,
    required this.instrumentRepo,
    required this.settings,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MarketRouter router;
  final CalendarRepository calendarRepo;
  final InstrumentRepository instrumentRepo;
  final SettingsStore settings;
  final DateTime Function() _now;

  Future<bool> isDueToday() async {
    final today = TradeDate.format(MarketClock.marketDate(_now()));
    return await settings.lastBaseSyncDate() != today;
  }

  /// 执行同步。返回新的交易日历（若同步成功）以便更新内存状态。
  Future<(SyncResult, TradingCalendar?)> run({bool force = false}) async {
    if (!force && !await isDueToday()) return (const SyncResult(), null);
    final errors = <String>[];
    final today = MarketClock.marketDate(_now());
    var days = 0;
    var count = 0;
    TradingCalendar? calendar;

    try {
      final cal = await router.call(
        Capability.calendar,
        (s) => s.calendar(from: '${today.year - 1}0101', to: '${today.year + 1}1231'),
      );
      await calendarRepo.upsertAll(cal);
      days = cal.length;
      calendar = await calendarRepo.load();
    } catch (e) {
      errors.add('交易日历：$e');
    }

    try {
      final items = <InstrumentInfo>[];
      // 个股 / ETF / 指数（Tushare 优先）
      items.addAll(await router.call(Capability.instruments, (s) async {
        final list = await s.instruments();
        // 东方财富作为备用时只返回板块；此时不算成功拿到个股
        if (list.every((i) => i.type == InstrumentType.sector)) {
          throw const UnsupportedRequest('该源只提供板块');
        }
        return list;
      }));
      count += items.length;
      await instrumentRepo.upsertAll(items);
    } catch (e) {
      errors.add('代码表：$e');
    }

    try {
      // 无 Tushare 时，板块列表改由东方财富提供（Tushare 的东财板块已包含在代码表中）
      final ts = router.sources.where((s) => s.id == SourceId.tushare).firstOrNull;
      final em = router.sources.where((s) => s.id == SourceId.eastmoney).firstOrNull;
      if (em != null && (ts == null || !ts.isAvailable)) {
        final sectors = await em.instruments();
        await instrumentRepo.upsertAll(sectors);
        count += sectors.length;
      }
    } catch (e) {
      errors.add('板块列表：$e');
    }

    if (errors.isEmpty) {
      await settings.setLastBaseSyncDate(TradeDate.format(today));
    }
    return (SyncResult(calendarDays: days, instruments: count, errors: errors), calendar);
  }
}
