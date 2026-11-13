import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/market/market_router.dart';
import 'package:stocknote/data/market/market_service.dart';
import 'package:stocknote/data/market/models.dart';
import 'package:stocknote/data/market/snapshot_service.dart';
import 'package:stocknote/data/market/sources.dart';
import 'package:stocknote/data/repo/instrument_repository.dart';
import 'package:stocknote/data/repo/market_snapshot_repository.dart';

import '../helpers/fake_market.dart';

void main() {
  late AppDatabase db;
  late InstrumentRepository instruments;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    instruments = InstrumentRepository(db);
    await instruments.upsertAll(const [
      InstrumentInfo(code: '600519.SH', name: '贵州茅台', type: InstrumentType.stock, pinyin: 'gzmt'),
      InstrumentInfo(code: '000001.SZ', name: '平安银行', type: InstrumentType.stock, pinyin: 'payh'),
      InstrumentInfo(code: '000001.SH', name: '上证指数', type: InstrumentType.marketIndex),
      InstrumentInfo(code: '510300.SH', name: '沪深300ETF', type: InstrumentType.etf),
      InstrumentInfo(code: '159919.SZ', name: '沪深300ETF嘉实', type: InstrumentType.etf),
      InstrumentInfo(code: 'BK1036.EM', name: '半导体', type: InstrumentType.sector),
    ]);
  });
  tearDown(() => db.close());

  group('代码表', () {
    test('按代码 / 名称 / 拼音搜索，精确优先', () async {
      expect((await instruments.search('GZMT')).first.code, '600519.SH');
      expect((await instruments.search('茅台')).first.code, '600519.SH');
      expect((await instruments.search('600519')).first.code, '600519.SH');
      final r = await instruments.search('沪深300ETF');
      expect(r.first.code, '510300.SH');
    });

    test('解析 \$ 引用：数字代码优先个股，名称精确 / 唯一模糊匹配', () async {
      final codes = await instruments.resolveRefs(['000001', '茅台', '半导体', '沪深300', '不存在']);
      expect(codes, ['000001.SZ', '600519.SH', 'BK1036.EM', '沪深300', '不存在']);
    });

    test('未入库的 6 位代码按规则推断', () async {
      expect(await instruments.resolveRefs(['601318']), ['601318.SH']);
    });
  });

  group('行情快照', () {
    late MarketService service;
    late MarketSnapshotRepository repo;
    late FakeSource source;
    final now = DateTime.utc(2026, 11, 13, 2, 30);

    setUp(() {
      source = FakeSource(SourceId.eastmoney);
      service = MarketService(MarketRouter([source], now: () => now));
      repo = MarketSnapshotRepository(db, now: () => now);
    });

    test('看板数据新鲜时复用，并只为关联标的额外拉报价', () async {
      final overview = MarketOverview(
        fetchedAt: now.subtract(const Duration(seconds: 10)),
        indices: [FakeSource.quote('000001.SH', 3663.71, 3655.83)],
        breadth: const Breadth(up: 1, down: 2, flat: 3),
      );
      final svc = SnapshotService(
          market: service, repo: repo, latestOverview: () => overview, now: () => now);
      final snap = await svc.capture(['600519.SH', '茅台']);
      expect(snap, isNotNull);
      expect(snap!.indices.keys, ['000001.SH']);
      expect(snap.breadth, {'up': 1, 'down': 2, 'flat': 3});
      expect((snap.extra!['instruments'] as Map).keys, ['600519.SH']);
      expect(source.calls, 1);
    });

    test('看板数据过期时现拉指数', () async {
      final svc = SnapshotService(
          market: service, repo: repo, latestOverview: () => null, now: () => now);
      final snap = await svc.capture(const []);
      expect(snap!.indices.keys, containsAll(defaultBoardIndices));
    });

    test('网络失败返回 null，不抛异常', () async {
      source.fail = true;
      final svc = SnapshotService(
          market: service, repo: repo, latestOverview: () => null, now: () => now);
      expect(await svc.capture(['600519.SH']), isNull);
    });
  });

  test('MarketOverview.mergeOnto 保留失败部分的旧值', () {
    final old = MarketOverview(
        fetchedAt: DateTime(2026), breadth: const Breadth(up: 1, down: 1, flat: 1));
    final fresh = MarketOverview(fetchedAt: DateTime(2027), errors: const {'breadth': 'x'});
    final merged = fresh.mergeOnto(old);
    expect(merged.breadth!.up, 1);
    expect(merged.fetchedAt, DateTime(2027));
    expect(merged.errors, {'breadth': 'x'});
  });
}
