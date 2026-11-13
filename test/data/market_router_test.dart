import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/sources.dart';

import '../helpers/fake_market.dart';

void main() {
  late DateTime now;
  setUp(() => now = DateTime.utc(2026, 11, 13, 2, 0));
  const emFirst = {Capability.quotes: [SourceId.eastmoney, SourceId.tencent]};

  test('按默认优先级选源，失败自动 fallback', () async {
    final em = FakeSource(SourceId.eastmoney, fail: true);
    final tc = FakeSource(SourceId.tencent);
    final router = MarketRouter([tc, em], priority: emFirst, now: () => now);

    final q = await router.call(Capability.quotes, (s) => s.quotes(['000001.SH']));
    expect(q.single.code, '000001.SH');
    expect(em.calls, 1, reason: '东方财富优先级更高，先被尝试');
    expect(tc.calls, 1);
    expect(router.healthOf(SourceId.eastmoney).consecutiveFailures, 1);
    expect(router.healthOf(SourceId.tencent).healthy, isTrue);
  });

  test('连续失败的源进入退避期被跳过，退避结束后重试', () async {
    final em = FakeSource(SourceId.eastmoney, fail: true);
    final tc = FakeSource(SourceId.tencent);
    final router = MarketRouter([em, tc], priority: emFirst, now: () => now);

    await router.call(Capability.quotes, (s) => s.quotes(['000001.SH']));
    await router.call(Capability.quotes, (s) => s.quotes(['000001.SH']));
    expect(em.calls, 1, reason: '第二次在退避期内，直接跳过');

    now = now.add(const Duration(seconds: 16));
    em.fail = false;
    await router.call(Capability.quotes, (s) => s.quotes(['000001.SH']));
    expect(em.calls, 2);
    expect(router.healthOf(SourceId.eastmoney).healthy, isTrue);
  });

  test('退避按能力区分：报价失败不影响同一源的涨跌家数', () async {
    final ts = FakeSource(SourceId.tushare, fail: true);
    final em = FakeSource(SourceId.eastmoney);
    final router = MarketRouter([ts, em], now: () => now);
    await router.call(Capability.quotes, (s) => s.quotes(['000001.SH']));
    expect(router.coolingDown(SourceId.tushare, Capability.quotes), isTrue);
    expect(router.coolingDown(SourceId.tushare, Capability.breadth), isFalse);
    ts.fail = false;
    await router.call(Capability.breadth, (s) => s.breadth());
    expect(ts.calls, 2, reason: '涨跌家数仍先走 Tushare');
  });

  test('不可用的源（缺 token）不参与；UnsupportedRequest 不计失败', () async {
    final ts = FakeSource(SourceId.tushare, available: false);
    final em = _Unsupported(SourceId.eastmoney);
    final tc = FakeSource(SourceId.tencent);
    final router = MarketRouter([ts, em, tc], now: () => now);

    await router.call(Capability.dailyKline, (s) => s.quotes(['x.SH']));
    expect(ts.calls, 0);
    expect(router.healthOf(SourceId.eastmoney).failures, 0);
  });

  test('默认 Tushare 首选；分时 / 板块实时排行由免费源优先', () {
    final router = MarketRouter([FakeSource(SourceId.eastmoney), FakeSource(SourceId.tencent), FakeSource(SourceId.tushare)]);
    expect(router.orderFor(Capability.quotes).first.id, SourceId.tushare);
    expect(router.orderFor(Capability.breadth).first.id, SourceId.tushare);
    expect(router.orderFor(Capability.intraday).map((s) => s.id).take(2),
        [SourceId.eastmoney, SourceId.tencent]);
    expect(router.orderFor(Capability.sectorRank).last.id, SourceId.tushare);
  });

  test('用户自定义优先级覆盖默认', () {
    final router = MarketRouter(
      [FakeSource(SourceId.eastmoney), FakeSource(SourceId.tencent)],
      priority: {Capability.quotes: [SourceId.tencent, SourceId.eastmoney]},
    );
    expect(router.orderFor(Capability.quotes).map((s) => s.id),
        [SourceId.tencent, SourceId.eastmoney]);
    expect(router.orderFor(Capability.intraday).first.id, SourceId.eastmoney);
  });

  test('全部失败抛 AllSourcesFailed，包含各源错误', () async {
    final router = MarketRouter(
        [FakeSource(SourceId.eastmoney, fail: true), FakeSource(SourceId.tencent, fail: true)],
        now: () => now);
    expect(
      () => router.call(Capability.quotes, (s) => s.quotes(['a.SH'])),
      throwsA(isA<AllSourcesFailed>().having((e) => e.errors.length, 'errors', 2)),
    );
  });
}

class _Unsupported extends FakeSource {
  _Unsupported(super.id);
  @override
  Future<Never> quotes(List<String> codes) async => throw const UnsupportedRequest('no');
}

