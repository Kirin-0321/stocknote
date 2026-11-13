import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../db/app_database.dart';

/// 可记录修改历史的实体类型（spec 3.2.2 / 3.4.3）。
abstract final class RevisionEntity {
  static const journalEntry = 'journal_entry';
  static const prediction = 'prediction';
  static const trade = 'trade';
  static const positionSnapshot = 'position_snapshot';
}

/// 通用修改历史记录器：保存修改前的完整快照与变动字段。
class RevisionRecorder {
  RevisionRecorder(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// 这些字段每次更新都会变，不算"内容修改"。
  static const _ignoredFields = {
    'updatedAt',
    'revisionCount',
    'modifiedBeforeDue',
    'deviceId',
  };

  /// 比较前后两份 JSON，返回内容发生变化的字段名。
  static List<String> diff(Map<String, dynamic> before, Map<String, dynamic> after) {
    const eq = DeepCollectionEquality();
    final keys = {...before.keys, ...after.keys}.difference(_ignoredFields);
    return keys.where((k) => !eq.equals(before[k], after[k])).toList()..sort();
  }

  /// 记录一次修改；[revisionNo] 为修改后的修订号（从 1 开始）。
  Future<void> record({
    required String entityType,
    required String entityId,
    required int revisionNo,
    required Map<String, dynamic> before,
    required List<String> changedFields,
  }) async {
    final ts = _now().millisecondsSinceEpoch;
    await _db.into(_db.revisions).insert(RevisionsCompanion.insert(
          id: newId(),
          createdAt: ts,
          updatedAt: ts,
          deviceId: await _db.deviceId(),
          entityType: entityType,
          entityId: entityId,
          revisionNo: revisionNo,
          before: before,
          changedFields: changedFields,
          ts: ts,
        ));
  }

  Future<List<Revision>> history(String entityType, String entityId) =>
      (_db.select(_db.revisions)
            ..where((r) => r.entityType.equals(entityType) & r.entityId.equals(entityId))
            ..orderBy([(r) => OrderingTerm.asc(r.revisionNo)]))
          .get();
}
