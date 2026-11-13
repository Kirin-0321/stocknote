import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calendar/trading_calendar.dart';
import '../data/ai/ai_settings.dart';
import '../data/ai/llm.dart';
import '../data/ai/market_analysis_service.dart';
import '../data/db/app_database.dart';
import '../data/market/eastmoney_source.dart';
import '../data/market/http.dart';
import '../data/market/models.dart';
import '../core/time/market_clock.dart';
import '../core/time/trading_session.dart';
import '../data/market/market_router.dart';
import '../data/market/market_service.dart';
import '../data/market/snapshot_service.dart';
import '../data/market/sources.dart';
import '../data/market/tencent_source.dart';
import '../data/market/tushare_source.dart';
import '../data/repo/ai_analysis_repository.dart';
import '../data/repo/calendar_repository.dart';
import '../data/repo/instrument_repository.dart';
import '../data/repo/journal_repository.dart';
import '../data/repo/market_snapshot_repository.dart';
import '../data/repo/prediction_repository.dart';
import '../data/repo/quick_phrase_repository.dart';
import '../data/repo/threshold_repository.dart';
import '../data/service/journal_service.dart';
import '../data/service/verification_service.dart';
import '../domain/verify/threshold.dart';
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

/// 构建时从项目 .env 注入（`--dart-define-from-file=.env`）。App 内未单独设置 token 时默认使用。
const _envTushareToken = String.fromEnvironment('TUSHARE_TOKEN');

@immutable
class AppConfig {
  const AppConfig({
    this.tushareToken,
    this.tokenFromEnv = false,
    this.priority = const {},
    this.refreshSeconds = 5,
    this.watchlist = const [],
    this.defaultIndex = PredictionRepository.defaultIndexCode,
  });

  final String? tushareToken;
  final bool tokenFromEnv;
  final Map<Capability, List<SourceId>> priority;
  final int refreshSeconds;

  /// 自选（个股 / ETF / 板块混合）
  final List<String> watchlist;

  /// 大盘 / 指数判断未关联标的时的默认判定指数
  final String defaultIndex;

  AppConfig copyWith({
    String? tushareToken,
    bool clearToken = false,
    bool? tokenFromEnv,
    Map<Capability, List<SourceId>>? priority,
    int? refreshSeconds,
    List<String>? watchlist,
    String? defaultIndex,
  }) =>
      AppConfig(
        tushareToken: clearToken ? null : (tushareToken ?? this.tushareToken),
        tokenFromEnv: tokenFromEnv ?? this.tokenFromEnv,
        priority: priority ?? this.priority,
        refreshSeconds: refreshSeconds ?? this.refreshSeconds,
        watchlist: watchlist ?? this.watchlist,
        defaultIndex: defaultIndex ?? this.defaultIndex,
      );

  static Future<AppConfig> load(SettingsStore settings, SecretStore secrets) async {
    var token = await secrets.read(SecretKeys.tushareToken);
    var fromDev = false;
    if ((token == null || token.isEmpty) && _envTushareToken.isNotEmpty) {
      token = _envTushareToken;
      fromDev = true;
    }
    return AppConfig(
      tushareToken: token,
      tokenFromEnv: fromDev,
      priority: await settings.sourcePriority(),
      refreshSeconds: await settings.refreshSeconds(),
      watchlist: await settings.watchlist(),
      defaultIndex: await settings.defaultIndex() ?? PredictionRepository.defaultIndexCode,
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
        ? state.copyWith(clearToken: true, tokenFromEnv: false)
        : state.copyWith(tushareToken: t, tokenFromEnv: false);
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

  Future<void> setDefaultIndex(String code) async {
    await ref.read(settingsStoreProvider).setDefaultIndex(code);
    state = state.copyWith(defaultIndex: code);
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

// ───────────── 判断与验证（M3） ─────────────

final predictionRepositoryProvider = Provider((ref) => PredictionRepository(
      ref.watch(databaseProvider),
      ref.watch(tradingCalendarProvider),
      now: ref.watch(clockProvider),
      defaultIndex: ref.watch(appConfigProvider.select((c) => c.defaultIndex)),
    ));

final thresholdRepositoryProvider =
    Provider((ref) => ThresholdRepository(ref.watch(databaseProvider), now: ref.watch(clockProvider)));

final thresholdConfigProvider =
    FutureProvider<ThresholdConfig>((ref) => ref.watch(thresholdRepositoryProvider).load());

final journalServiceProvider = Provider((ref) => JournalService(
      journal: ref.watch(journalRepositoryProvider),
      predictions: ref.watch(predictionRepositoryProvider),
      snapshots: ref.watch(snapshotServiceProvider),
    ));

final verificationServiceProvider = Provider((ref) => VerificationService(
      repo: ref.watch(predictionRepositoryProvider),
      market: ref.watch(marketServiceProvider),
      calendar: ref.watch(tradingCalendarProvider),
      thresholds: () => ref.read(thresholdConfigProvider.future),
    ));

// ───────────── AI（M4） ─────────────

final aiConfigRepositoryProvider = Provider(
    (ref) => AiConfigRepository(ref.watch(settingsStoreProvider), ref.watch(secretStoreProvider)));

/// AI 设置（非敏感部分）。设置页修改后 invalidate。
final aiSettingsProvider = FutureProvider<AiSettings>((ref) => ref.watch(aiConfigRepositoryProvider).load());

/// 大盘分析是否已配置可用的模型 Key。
final aiAnalysisReadyProvider = FutureProvider<bool>((ref) async {
  final s = await ref.watch(aiSettingsProvider.future);
  return await ref.watch(aiConfigRepositoryProvider).configFor(AiTask.analysis, settings: s) != null;
});

/// 模型客户端工厂（测试中替换为假模型）。
final llmFactoryProvider = Provider<LlmProvider Function(LlmConfig)>((ref) => LlmProvider.of);

final aiAnalysisRepositoryProvider =
    Provider((ref) => AiAnalysisRepository(ref.watch(databaseProvider), now: ref.watch(clockProvider)));

final marketAnalysisServiceProvider = Provider((ref) {
  final market = ref.watch(marketServiceProvider);
  return MarketAnalysisService(
    config: ref.watch(aiConfigRepositoryProvider),
    repo: ref.watch(aiAnalysisRepositoryProvider),
    predictions: ref.watch(predictionRepositoryProvider),
    journal: ref.watch(journalRepositoryProvider),
    market: market,
    calendar: ref.watch(tradingCalendarProvider),
    settings: ref.watch(settingsStoreProvider),
    now: ref.watch(clockProvider),
    providerFactory: ref.watch(llmFactoryProvider),
    overview: () async {
      final latest = ref.read(latestOverviewProvider);
      final now = ref.read(clockProvider)();
      if (latest != null && now.difference(latest.fetchedAt).inMinutes < 2) return latest;
      final cal = ref.read(tradingCalendarProvider);
      final loc = cal.locate(now);
      final date = cal.isTradingDay(loc.tradeDate) &&
              MarketClock.marketDate(now) == loc.tradeDate &&
              loc.session != TradingSession.preMarket
          ? loc.tradeDate
          : cal.previous(MarketClock.marketDate(now));
      final codes = {...defaultBoardIndices, ...ref.read(appConfigProvider).watchlist}.toList();
      return market.overview(codes, TradeDate.format(date));
    },
  );
});

/// 执行基础数据同步并刷新内存中的交易日历。
Future<SyncResult> runBaseDataSync(WidgetRef ref, {bool force = false}) async {
  final (result, calendar) = await ref.read(baseDataSyncProvider).run(force: force);
  if (calendar != null) ref.read(tradingCalendarProvider.notifier).set(calendar);
  return result;
}

