import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/core/time/trading_session.dart';

void main() {
  DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

  group('无数据时退化为工作日规则', () {
    final cal = TradingCalendar();

    test('周末不开市', () {
      expect(cal.isTradingDay(d(2026, 11, 13)), isTrue); // 周五
      expect(cal.isTradingDay(d(2026, 11, 14)), isFalse); // 周六
      expect(cal.isTradingDay(d(2026, 11, 15)), isFalse); // 周日
    });

    test('next / previous 跨周末', () {
      expect(cal.next(d(2026, 11, 13)), d(2026, 11, 16));
      expect(cal.previous(d(2026, 11, 16)), d(2026, 11, 13));
    });

    test('T+N', () {
      expect(cal.addTradingDays(d(2026, 11, 13), 0), d(2026, 11, 13));
      expect(cal.addTradingDays(d(2026, 11, 13), 1), d(2026, 11, 16));
      expect(cal.addTradingDays(d(2026, 11, 13), 5), d(2026, 11, 20));
      // 周六为基准：T 取下周一
      expect(cal.addTradingDays(d(2026, 11, 14), 0), d(2026, 11, 16));
      expect(cal.addTradingDays(d(2026, 11, 14), 1), d(2026, 11, 17));
    });
  });

  group('使用交易日历数据（节假日）', () {
    // 模拟国庆：10/1(周四)–10/8(周四) 休市，10/9 周五开市
    final days = <String, bool>{
      for (var i = 1; i <= 8; i++) TradeDate.format(d(2026, 10, i)): false,
      '20261009': true,
    };
    final cal = TradingCalendar(days);

    test('节假日工作日也不开市', () {
      expect(cal.isTradingDay(d(2026, 10, 5)), isFalse); // 周一，但休市
      expect(cal.isTradingDay(d(2026, 10, 9)), isTrue);
    });

    test('跨长假的 T+1', () {
      expect(cal.addTradingDays(d(2026, 9, 30), 1), d(2026, 10, 9));
      expect(cal.next(d(2026, 9, 30)), d(2026, 10, 9));
      expect(cal.previous(d(2026, 10, 9)), d(2026, 9, 30));
    });

    test('假日中的记录归入下一个交易日，时段为假日复盘', () {
      final loc = cal.locate(MarketClock.fromMarket(2026, 10, 3, 20, 0));
      expect(loc.tradeDate, d(2026, 10, 9));
      expect(loc.session, TradingSession.holiday);
    });
  });

  test('locate 使用上海日期：UTC 前一天 16:30 = 上海次日 00:30 盘前', () {
    final cal = TradingCalendar();
    final instant = DateTime.utc(2026, 11, 12, 16, 30); // 上海 11/13 00:30
    final loc = cal.locate(instant);
    expect(loc.tradeDate, d(2026, 11, 13));
    expect(loc.session, TradingSession.preMarket);
  });

  test('盘后记录仍属当天交易日', () {
    final cal = TradingCalendar();
    final loc = cal.locate(MarketClock.fromMarket(2026, 11, 13, 21, 0));
    expect(loc.tradeDate, d(2026, 11, 13));
    expect(loc.session, TradingSession.afterMarket);
  });
}
