import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/core/time/trading_session.dart';

void main() {
  // 2026-11-13 周五
  DateTime sh(int h, int m) => MarketClock.fromMarket(2026, 11, 13, h, m);

  test('按上海时间划分时段（含边界）', () {
    final cases = {
      sh(0, 0): TradingSession.preMarket,
      sh(9, 14): TradingSession.preMarket,
      sh(9, 15): TradingSession.callAuction,
      sh(9, 29): TradingSession.callAuction,
      sh(9, 30): TradingSession.morning,
      sh(11, 29): TradingSession.morning,
      sh(11, 30): TradingSession.noonBreak,
      sh(12, 59): TradingSession.noonBreak,
      sh(13, 0): TradingSession.afternoon,
      sh(14, 56): TradingSession.afternoon,
      sh(14, 57): TradingSession.closingAuction,
      sh(14, 59): TradingSession.closingAuction,
      sh(15, 0): TradingSession.afterMarket,
      sh(23, 59): TradingSession.afterMarket,
    };
    cases.forEach((instant, expected) {
      expect(TradingSession.ofTradingDay(instant), expected,
          reason: MarketClock.toMarket(instant).toString());
    });
  });

  test('与设备本地时区无关：同一时刻的 UTC 与本地表示结果一致', () {
    final instant = sh(10, 0);
    expect(TradingSession.ofTradingDay(instant.toLocal()), TradingSession.morning);
    expect(TradingSession.ofTradingDay(instant.toUtc()), TradingSession.morning);
  });

  test('code 可往返', () {
    for (final s in TradingSession.values) {
      expect(TradingSession.fromCode(s.code), s);
    }
  });

  test('TradeDate 格式化与解析', () {
    final d = DateTime.utc(2026, 1, 5);
    expect(TradeDate.format(d), '20260105');
    expect(TradeDate.parse('20260105'), d);
    expect(() => TradeDate.parse('2026-01-05'), throwsFormatException);
  });
}
