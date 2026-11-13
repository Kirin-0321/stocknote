import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../db/app_database.dart';

class MarketSnapshotRepository {
  MarketSnapshotRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<MarketSnapshot> create({
    required DateTime ts,
    required Map<String, dynamic> indices,
    Map<String, dynamic>? breadth,
    double? turnover,
    Map<String, dynamic>? extra,
    bool backfilled = false,
  }) async {
    final ms = _now().millisecondsSinceEpoch;
    final id = newId();
    await _db.into(_db.marketSnapshots).insert(MarketSnapshotsCompanion.insert(
          id: id,
          createdAt: ms,
          updatedAt: ms,
          deviceId: await _db.deviceId(),
          ts: ts.millisecondsSinceEpoch,
          indices: indices,
          breadth: Value(breadth),
          turnover: Value(turnover),
          extra: Value(extra),
          isBackfilled: Value(backfilled),
        ));
    return (await get(id))!;
  }

  Future<MarketSnapshot?> get(String id) =>
      (_db.select(_db.marketSnapshots)..where((s) => s.id.equals(id))).getSingleOrNull();
}
