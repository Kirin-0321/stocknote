import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/trade/trade_rules.dart';
import '../db/app_database.dart';
import 'revision_recorder.dart';

/// 待入库的一笔交易（手动录入 / 导入预览共用）。
class TradeDraft {
  TradeDraft({
    required this.accountId,
    required this.code,
    required this.side,
    required this.ts,
    required this.price,
    required this.qty,
    double? amount,
    this.fees = Fees.zero,
    this.note,
    this.entryId,
    this.name,
  }) : amount = amount ?? round2(price * qty);

  String accountId;
  String code;
  TradeSide side;
  int ts;
  double price;
  int qty;
  double amount;
  Fees fees;
  String? note;
  String? entryId;

  /// 显示用名称（导入时来自文件）
  String? name;

  /// 去重键：成交分钟 + 标的 + 方向 + 价格 + 数量（spec 3.4.2）
  String get dedupeKey => tradeKey(code, side.code, ts, price, qty);
}

String tradeKey(String code, String side, int ts, double price, int qty) =>
    '$code|$side|${ts ~/ 60000}|${price.toStringAsFixed(3)}|$qty';

/// 账户（spec 3.4.1 多账户）。
class AccountRepository {
  AccountRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;

  Stream<List<Account>> watchAll() => (_db.select(_db.accounts)
        ..where((a) => a.deletedAt.isNull())
        ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
      .watch();

  Future<List<Account>> all() => (_db.select(_db.accounts)
        ..where((a) => a.deletedAt.isNull())
        ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
      .get();

  /// 没有账户时创建"默认账户"。
  Future<Account> ensureDefault() async {
    final list = await all();
    if (list.isNotEmpty) return list.first;
    return create(name: '默认账户');
  }

  Future<Account> create({
    required String name,
    String? broker,
    FeeRates rates = const FeeRates(),
  }) async {
    final ms = _now().millisecondsSinceEpoch;
    return _db.into(_db.accounts).insertReturning(AccountsCompanion.insert(
          id: newId(),
          createdAt: ms,
          updatedAt: ms,
          deviceId: await _db.deviceId(),
          name: name,
          broker: Value(broker),
          commissionRate: Value(rates.commission),
          minCommission: Value(rates.minCommission),
          stampTaxRate: Value(rates.stampTax),
          transferFeeRate: Value(rates.transferFee),
        ));
  }

  Future<void> update(Account a) => (_db.update(_db.accounts)..where((t) => t.id.equals(a.id)))
      .write(a.toCompanion(false).copyWith(updatedAt: Value(_now().millisecondsSinceEpoch)));

  Future<void> delete(String id) async {
    final ms = _now().millisecondsSinceEpoch;
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
        .write(AccountsCompanion(deletedAt: Value(ms), updatedAt: Value(ms)));
  }
}

extension AccountRates on Account {
  FeeRates get rates => FeeRates(
        commission: commissionRate,
        minCommission: minCommission,
        stampTax: stampTaxRate,
        transferFee: transferFeeRate,
      );
}

/// 交易流水（spec 3.4）。修改保留历史。
class TradeRepository {
  TradeRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        _revisions = RevisionRecorder(_db, now: now);

  final AppDatabase _db;
  final DateTime Function() _now;
  final RevisionRecorder _revisions;

  int get _ms => _now().millisecondsSinceEpoch;

  SimpleSelectStatement<$TradesTable, Trade> _alive({String? accountId}) {
    final q = _db.select(_db.trades)..where((t) => t.deletedAt.isNull());
    if (accountId != null) q.where((t) => t.accountId.equals(accountId));
    return q;
  }

  Stream<List<Trade>> watchAll({String? accountId}) =>
      (_alive(accountId: accountId)..orderBy([(t) => OrderingTerm.desc(t.ts)])).watch();

  Future<List<Trade>> all({String? accountId}) =>
      (_alive(accountId: accountId)..orderBy([(t) => OrderingTerm.desc(t.ts)])).get();

  Future<Trade?> get(String id) =>
      (_db.select(_db.trades)..where((t) => t.id.equals(id))).getSingleOrNull();

  TradesCompanion _companion(TradeDraft d, String source, String? batchId, String deviceId) =>
      TradesCompanion.insert(
        id: newId(),
        createdAt: _ms,
        updatedAt: _ms,
        deviceId: deviceId,
        accountId: d.accountId,
        instrumentCode: d.code,
        side: d.side.code,
        ts: d.ts,
        price: d.price,
        qty: d.qty,
        amount: d.amount,
        commission: Value(d.fees.commission),
        stampTax: Value(d.fees.stampTax),
        transferFee: Value(d.fees.transferFee),
        entryId: Value(d.entryId),
        source: source,
        importBatchId: Value(batchId),
        note: Value(d.note),
      );

  Future<Trade> add(TradeDraft d, {String source = 'manual'}) async =>
      _db.into(_db.trades).insertReturning(_companion(d, source, null, await _db.deviceId()));

  /// 已有交易的去重键
  Future<Set<String>> existingKeys() async => {
        for (final t in await _alive().get()) tradeKey(t.instrumentCode, t.side, t.ts, t.price, t.qty),
      };

  /// 批量导入：建导入批次并写入交易，返回批次 id。
  Future<String> importBatch({
    required String kind,
    required List<TradeDraft> drafts,
    String? fileName,
    String? mappingId,
  }) async {
    final device = await _db.deviceId();
    final batchId = newId();
    await _db.transaction(() async {
      await _db.into(_db.importBatches).insert(ImportBatchesCompanion.insert(
            id: batchId,
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: device,
            kind: kind,
            fileName: Value(fileName),
            mappingId: Value(mappingId),
            ts: _ms,
            rowCount: Value(drafts.length),
            status: 'done',
          ));
      await _db.batch((b) => b.insertAll(_db.trades, [for (final d in drafts) _companion(d, kind, batchId, device)]));
    });
    return batchId;
  }

  /// 修改交易，保留修改前快照。
  Future<Trade?> update(String id, TradeDraft d) async {
    final old = await get(id);
    if (old == null) return null;
    final next = old.copyWith(
      accountId: d.accountId,
      instrumentCode: d.code,
      side: d.side.code,
      ts: d.ts,
      price: d.price,
      qty: d.qty,
      amount: d.amount,
      commission: d.fees.commission,
      stampTax: d.fees.stampTax,
      transferFee: d.fees.transferFee,
      note: Value(d.note),
      entryId: Value(d.entryId),
    );
    final changed = RevisionRecorder.diff(old.toJson(), next.toJson());
    if (changed.isEmpty) return old;
    final rev = old.revisionCount + 1;
    await _db.transaction(() async {
      await _revisions.record(
        entityType: RevisionEntity.trade,
        entityId: id,
        revisionNo: rev,
        before: old.toJson(),
        changedFields: changed,
      );
      await (_db.update(_db.trades)..where((t) => t.id.equals(id)))
          .write(next.copyWith(revisionCount: rev, updatedAt: _ms).toCompanion(false));
    });
    return get(id);
  }

  Future<void> delete(String id) => (_db.update(_db.trades)..where((t) => t.id.equals(id)))
      .write(TradesCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));

  Future<void> restore(String id) => (_db.update(_db.trades)..where((t) => t.id.equals(id)))
      .write(TradesCompanion(deletedAt: const Value(null), updatedAt: Value(_ms)));

  Future<List<Revision>> history(String id) => (_db.select(_db.revisions)
        ..where((r) => r.entityType.equals(RevisionEntity.trade) & r.entityId.equals(id))
        ..orderBy([(r) => OrderingTerm.desc(r.revisionNo)]))
      .get();
}

/// 表格列映射方案（spec 3.4.2：映射可保存复用）。
class ColumnMappingRepository {
  ColumnMappingRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;

  /// 按表头签名查找已保存的映射。
  Future<ColumnMapping?> findBySignature(String signature) async {
    final rows = await (_db.select(_db.columnMappings)..where((m) => m.deletedAt.isNull())).get();
    return rows.where((m) => m.mapping['signature'] == signature).firstOrNull;
  }

  Future<ColumnMapping> save({required String name, required Map<String, dynamic> mapping}) async {
    final sig = mapping['signature'];
    final existing = sig is String ? await findBySignature(sig) : null;
    final ms = _now().millisecondsSinceEpoch;
    if (existing != null) {
      await (_db.update(_db.columnMappings)..where((m) => m.id.equals(existing.id)))
          .write(ColumnMappingsCompanion(mapping: Value(mapping), name: Value(name), updatedAt: Value(ms)));
      return (await (_db.select(_db.columnMappings)..where((m) => m.id.equals(existing.id))).getSingle());
    }
    return _db.into(_db.columnMappings).insertReturning(ColumnMappingsCompanion.insert(
          id: newId(),
          createdAt: ms,
          updatedAt: ms,
          deviceId: await _db.deviceId(),
          name: name,
          mapping: mapping,
        ));
  }
}
