import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/verify/threshold.dart';
import '../db/app_database.dart';
import '../market/models.dart';

/// 判定阈值的持久化（threshold_rules 表）。
class ThresholdRepository {
  ThresholdRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<ThresholdConfig> load() async {
    final rows = await (_db.select(_db.thresholdRules)..where((r) => r.deletedAt.isNull())).get();
    var cfg = const ThresholdConfig();
    final byType = {...cfg.byType};
    final byTypeHorizon = <(InstrumentType, String), double>{};
    double? global;
    for (final r in rows) {
      final type = r.instrumentType == null ? null : InstrumentType.fromCode(r.instrumentType!);
      switch (r.scope) {
        case 'global':
          global = r.pct;
        case 'type' when type != null:
          byType[type] = r.pct;
        case 'horizon' when type != null && r.horizonType != null:
          byTypeHorizon[(type, r.horizonType!)] = r.pct;
      }
    }
    cfg = cfg.copyWith(global: global, byType: byType, byTypeHorizon: byTypeHorizon);
    return cfg;
  }

  Future<void> save(ThresholdConfig cfg) async {
    final ms = _now().millisecondsSinceEpoch;
    final device = await _db.deviceId();
    await _db.transaction(() async {
      await (_db.update(_db.thresholdRules)..where((r) => r.deletedAt.isNull()))
          .write(ThresholdRulesCompanion(deletedAt: Value(ms), updatedAt: Value(ms)));
      Future<void> add(String scope, double pct, {InstrumentType? type, String? horizon}) =>
          _db.into(_db.thresholdRules).insert(ThresholdRulesCompanion.insert(
                id: newId(),
                createdAt: ms,
                updatedAt: ms,
                deviceId: device,
                scope: scope,
                instrumentType: Value(type?.code),
                horizonType: Value(horizon),
                pct: pct,
              ));
      await add('global', cfg.global);
      for (final e in cfg.byType.entries) {
        await add('type', e.value, type: e.key);
      }
      for (final e in cfg.byTypeHorizon.entries) {
        await add('horizon', e.value, type: e.key.$1, horizon: e.key.$2);
      }
    });
  }
}
