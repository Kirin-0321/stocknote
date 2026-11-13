import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../core/time/trading_session.dart';
import '../../data/market/market_service.dart';
import '../../data/market/models.dart';

/// 市场状态（看板标题副文案与刷新节奏）。
class MarketStatus {
  const MarketStatus(this.label, {required this.live, required this.dataDate});

  final String label;

  /// 是否需要高频刷新（集合竞价 / 连续竞价）
  final bool live;

  /// 涨停池等按日数据应查询的交易日（yyyyMMdd）
  final String dataDate;

  static MarketStatus of(TradingCalendar cal, DateTime now) {
    final date = MarketClock.marketDate(now);
    if (!cal.isTradingDay(date)) {
      return MarketStatus('休市', live: false, dataDate: TradeDate.format(cal.previous(date)));
    }
    final session = TradingSession.ofTradingDay(now);
    final today = TradeDate.format(date);
    return switch (session) {
      TradingSession.preMarket =>
        MarketStatus('未开盘', live: false, dataDate: TradeDate.format(cal.previous(date))),
      TradingSession.callAuction => MarketStatus('集合竞价', live: true, dataDate: today),
      TradingSession.noonBreak => MarketStatus('午间休市', live: false, dataDate: today),
      TradingSession.afterMarket => MarketStatus('已收盘', live: false, dataDate: today),
      _ => MarketStatus('交易中', live: true, dataDate: today),
    };
  }
}

/// 看板要拉的报价代码：指数 + 自选（不含板块，板块报价走同一接口亦可）。
final boardCodesProvider = Provider<List<String>>((ref) {
  final watch = ref.watch(appConfigProvider.select((c) => c.watchlist));
  return {...defaultBoardIndices, ...watch}.toList();
});

/// 看板数据流。交易时段内指数按设置间隔刷新，完整看板（宽度 / 板块 / ETF）每 30 秒刷新；
/// 非交易时段每 5 分钟刷新一次。应用在后台时暂停。
final marketOverviewProvider = StreamProvider.autoDispose<MarketOverview>((ref) {
  final service = ref.watch(marketServiceProvider);
  final codes = ref.watch(boardCodesProvider);
  final refresh = ref.watch(appConfigProvider.select((c) => c.refreshSeconds));
  final clock = ref.watch(clockProvider);

  final controller = StreamController<MarketOverview>();
  var disposed = false;
  Timer? timer;
  MarketOverview? last;
  DateTime? lastFull;

  Future<void> tick() async {
    if (disposed) return;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    final status = MarketStatus.of(ref.read(tradingCalendarProvider), clock());
    if (foreground) {
      final now = clock();
      final needFull = last == null ||
          lastFull == null ||
          now.difference(lastFull!) >= Duration(seconds: status.live ? 30 : 300);
      try {
        final r = needFull
            ? await service.overview(codes, status.dataDate)
            : await service.indicesOnly(codes);
        if (needFull) lastFull = now;
        if (disposed) return;
        last = r.mergeOnto(last);
        ref.read(latestOverviewProvider.notifier).set(last!);
        controller.add(last!);
      } catch (e, st) {
        if (!disposed && last == null) controller.addError(e, st);
      }
    }
    if (!disposed) {
      timer = Timer(Duration(seconds: status.live ? refresh : 300), tick);
    }
  }

  tick();
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});
