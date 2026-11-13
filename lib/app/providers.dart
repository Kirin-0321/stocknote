import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendar/trading_calendar.dart';
import '../data/db/app_database.dart';
import '../data/market/eastmoney_source.dart';
import '../data/market/http.dart';
import '../data/market/market_router.dart';
import '../data/market/market_service.dart';
import '../data/market/snapshot_service.dart';
import '../data/market/sources.dart';
import '../data/market/tencent_source.dart';
import '../data/market/tushare_source.dart';
import '../data/repo/calendar_repository.dart';
import '../data/repo/instrument_repository.dart';
import '../data/repo/journal_repository.dart';
import '../data/repo/market_snapshot_repository.dart';
import '../data/repo/quick_phrase_repository.dart';
import '../data/settings/settings_store.dart';
import '../data/sync/base_data_sync.dart';

/// 数据库单例。在 main / 测试中通过 override 注入。
final databaseProvider = Provider<AppDatabase>(
    (ref) => throw UnimplementedError('databaseProvider must be overridden'));

/// 当前时间来源，测试中可固定。
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// ───────────── 交易日历 ─────────────

/// 交易日历。启动时从数据库加载，基础数据同步后更新。
class CalendarNotifier extends Notifier<TradingCalendar> {
  CalendarNotifier([this._initial]);
  final TradingCalendar? _initial;

  @override
  TradingCalendar build() => _initial ?? TradingCalendar();

  void set(TradingCalendar calendar) => state = calendar;
}

final tradingCalendarProvider =
    NotifierProvider<CalendarNotifier, TradingCalendar>(CalendarNotifier.new);

// ───────────── 配置 ─────────────

final secretStoreProvider = Provider<SecretStore>((ref) => const SecureSecretStore());
final settingsStoreProvider = Provider((ref) => SettingsStore(ref.watch(databaseProvider)));

/// 本地开发用：`--dart-define=TUSHARE_TOKEN=...`，仅 debug 构建且用户未设置时生效，不会持久化。
const _devTushareToken = String.fromEnvironment('TUSHARE_TOKEN');

@immutable
class AppConfig {
  const AppConfig({
    this.tushareToken,
    this.tokenFromDevDefine = false,
    this.priority = const {},
    this.refreshSeconds = 5,
    this.watchlist = const [],
  });

  final String? tushareToken;
  final bool tokenFromDevDefine;
  final Map<Capability, List<SourceId>> priority;
  final int refreshSeconds;

  /// 自选（个股 / ETF / 板块混合）
  final List<String> watchlist;

  AppConfig copyWith({
    String? tushareToken,
    bool clearToken = false,
    bool? tokenFromDevDefine,
    Map<Capability, List<SourceId>>? priority,
    int? refreshSeconds,
    List<String>? watchlist,
  }) =>
      AppConfig(
        tushareToken: clearToken ? null : (tushareToken ?? this.tushareToken),
        tokenFromDevDefine: tokenFromDevDefine ?? this.tokenFromDevDefine,
        priority: priority ?? this.priority,
        refreshSeconds: refreshSeconds ?? this.refreshSeconds,
        watchlist: watchlist ?? this.watchlist,
      );

  static Future<AppConfig> load(SettingsStore settings, SecretStore secrets) async {
    var token = await secrets.read(SecretKeys.tushareToken);
    var fromDev = false;
    if ((token == null || token.isEmpty) && kDebugMode && _devTushareToken.isNotEmpty) {
      token = _devTushareToken;
      fromDev = true;
    }
    return AppConfig(
      tushareToken: token,
      tokenFromDevDefine: fromDev,
      priority: await settings.sourcePriority(),
      refreshSeconds: await settings.refreshSeconds(),
      watchlist: await settings.watchlist(),
    );
  }
}

class AppConfigNotifier extends Notifier<AppConfig> {
  AppConfigNotifier([this._initial]);
  final AppConfig? _initial;

  @override
  AppConfig build() => _initial ?? const AppConfig();

  Future<void> setTushareToken(String? token) async {
    final t = token?.trim();
    await ref.read(secretStoreProvider).write(SecretKeys.tushareToken, t);
    state = (t == null || t.isEmpty)
        ? state.copyWith(clearToken: true, tokenFromDevDefine: false)
        : state.copyWith(tushareToken: t, tokenFromDevDefine: false);
  }

  Future<void> setPriority(Capability c, List<SourceId> order) async {
    final p = {...state.priority, c: order};
    await ref.read(settingsStoreProvider).setSourcePriority(p);
    state = state.copyWith(priority: p);
  }

  Future<void> resetPriority() async {
    await ref.read(settingsStoreProvider).setSourcePriority({});
    state = state.copyWith(priority: {});
  }

  Future<void> toggleWatch(String code) async {
    final list = [...state.watchlist];
    list.contains(code) ? list.remove(code) : list.add(code);
    await ref.read(settingsStoreProvider).setWatchlist(list);
    state = state.copyWith(watchlist: list);
  }

  Future<void> setRefreshSeconds(int s) async {
    await ref.read(settingsStoreProvider).setRefreshSeconds(s);
    state = state.copyWith(refreshSeconds: s);
  }
}

final appConfigProvider =
    NotifierProvider<AppConfigNotifier, AppConfig>(AppConfigNotifier.new);

// ───────────── 行情 ─────────────

final marketSourcesProvider = Provider<List<MarketSource>>((ref) {
  final token = ref.watch(appConfigProvider.select((c) => c.tushareToken));
  final dio = createMarketDio();
  return [TushareSource(token), EastmoneySource(dio: dio), TencentSource(dio: dio)];
});

final marketRouterProvider = Provider((ref) => MarketRouter(
      ref.watch(marketSourcesProvider),
      priority: ref.watch(appConfigProvider.select((c) => c.priority)),
    ));

final marketServiceProvider = Provider((ref) => MarketService(ref.watch(marketRouterProvider)));

/// 看板最近一次的完整数据，供日记快照复用。
class LatestOverviewNotifier extends Notifier<MarketOverview?> {
  @override
  MarketOverview? build() => null;
  void set(MarketOverview o) => state = o;
}

final latestOverviewProvider =
    NotifierProvider<LatestOverviewNotifier, MarketOverview?>(LatestOverviewNotifier.new);

// ───────────── 仓库 ─────────────

final calendarRepositoryProvider =
    Provider((ref) => CalendarRepository(ref.watch(databaseProvider)));

final instrumentRepositoryProvider =
    Provider((ref) => InstrumentRepository(ref.watch(databaseProvider)));

final snapshotRepositoryProvider = Provider((ref) =>
    MarketSnapshotRepository(ref.watch(databaseProvider), now: ref.watch(clockProvider)));

final snapshotServiceProvider = Provider((ref) => SnapshotService(
      market: ref.watch(marketServiceProvider),
      repo: ref.watch(snapshotRepositoryProvider),
      latestOverview: () => ref.read(latestOverviewProvider),
      now: ref.watch(clockProvider),
    ));

final journalRepositoryProvider = Provider((ref) => JournalRepository(
      ref.watch(databaseProvider),
      ref.watch(tradingCalendarProvider),
      now: ref.watch(clockProvider),
    ));

final quickPhraseRepositoryProvider = Provider((ref) => QuickPhraseRepository(
      ref.watch(databaseProvider),
      now: ref.watch(clockProvider),
    ));

final baseDataSyncProvider = Provider((ref) => BaseDataSync(
      router: ref.watch(marketRouterProvider),
      calendarRepo: ref.watch(calendarRepositoryProvider),
      instrumentRepo: ref.watch(instrumentRepositoryProvider),
      settings: ref.watch(settingsStoreProvider),
      now: ref.watch(clockProvider),
    ));

/// 执行基础数据同步并刷新内存中的交易日历。
Future<SyncResult> runBaseDataSync(WidgetRef ref, {bool force = false}) async {
  final (result, calendar) = await ref.read(baseDataSyncProvider).run(force: force);
  if (calendar != null) ref.read(tradingCalendarProvider.notifier).set(calendar);
  return result;
}
