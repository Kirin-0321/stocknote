import 'package:drift/drift.dart';

import '../../core/calendar/trading_calendar.dart';
import '../../core/ids.dart';
import '../../core/time/market_clock.dart';
import '../db/app_database.dart';
import 'revision_recorder.dart';

/// 日记条目的读写。创建时自动分配交易日与时段，修改时自动记录历史。
class JournalRepository {
  JournalRepository(
    this._db,
    this._calendar, {
    DateTime Function()? now,
  })  : _now = now ?? DateTime.now,
        _revisions = RevisionRecorder(_db, now: now);

  final AppDatabase _db;
  final TradingCalendar _calendar;
  final DateTime Function() _now;
  final RevisionRecorder _revisions;

  Future<JournalEntry> create({
    required String content,
    DateTime? at,
    String? stance,
    String? action,
    String? emotion,
    List<String> tags = const [],
    List<String> instrumentCodes = const [],
    String? snapshotId,
    String? templateId,
  }) async {
    final instant = at ?? _now();
    final loc = _calendar.locate(instant);
    final nowMs = _now().millisecondsSinceEpoch;
    final id = newId();
    await _db.into(_db.journalEntries).insert(JournalEntriesCompanion.insert(
          id: id,
          createdAt: nowMs,
          updatedAt: nowMs,
          deviceId: await _db.deviceId(),
          tradeDate: TradeDate.format(loc.tradeDate),
          session: loc.session.code,
          ts: instant.millisecondsSinceEpoch,
          content: content,
          stance: Value(stance),
          action: Value(action),
          emotion: Value(emotion),
          tags: Value(tags),
          instrumentCodes: Value(instrumentCodes),
          snapshotId: Value(snapshotId),
          templateId: Value(templateId),
        ));
    return (await get(id))!;
  }

  Future<JournalEntry?> get(String id) =>
      (_db.select(_db.journalEntries)..where((e) => e.id.equals(id)))
          .getSingleOrNull();

  /// 修改条目内容；若有实际变化则写入修改历史并递增修订号。
  /// 时间戳 [ts] 变化时会重新计算交易日与时段。
  Future<JournalEntry> update(
    String id, {
    String? content,
    DateTime? at,
    Value<String?> stance = const Value.absent(),
    Value<String?> action = const Value.absent(),
    Value<String?> emotion = const Value.absent(),
    List<String>? tags,
    List<String>? instrumentCodes,
  }) {
    return _db.transaction(() async {
      final current = await get(id);
      if (current == null) throw StateError('Journal entry $id not found');

      var next = current.copyWith(
        content: content ?? current.content,
        stance: stance.present ? stance : Value(current.stance),
        action: action.present ? action : Value(current.action),
        emotion: emotion.present ? emotion : Value(current.emotion),
        tags: tags ?? current.tags,
        instrumentCodes: instrumentCodes ?? current.instrumentCodes,
      );
      if (at != null) {
        final loc = _calendar.locate(at);
        next = next.copyWith(
          ts: at.millisecondsSinceEpoch,
          tradeDate: TradeDate.format(loc.tradeDate),
          session: loc.session.code,
        );
      }

      final before = current.toJson();
      final changed = RevisionRecorder.diff(before, next.toJson());
      if (changed.isEmpty) return current;

      final revisionNo = current.revisionCount + 1;
      next = next.copyWith(
        revisionCount: revisionNo,
        updatedAt: _now().millisecondsSinceEpoch,
      );
      await _db.update(_db.journalEntries).replace(next);
      await _revisions.record(
        entityType: RevisionEntity.journalEntry,
        entityId: id,
        revisionNo: revisionNo,
        before: before,
        changedFields: changed,
      );
      return next;
    });
  }

  /// 软删除。
  Future<void> delete(String id) async {
    final ms = _now().millisecondsSinceEpoch;
    await (_db.update(_db.journalEntries)..where((e) => e.id.equals(id)))
        .write(JournalEntriesCompanion(deletedAt: Value(ms), updatedAt: Value(ms)));
  }

  /// 某交易日的全部条目，按时间排序。
  Stream<List<JournalEntry>> watchDay(DateTime tradeDate) =>
      (_db.select(_db.journalEntries)
            ..where((e) =>
                e.tradeDate.equals(TradeDate.format(tradeDate)) & e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.asc(e.ts)]))
          .watch();

  Future<List<Revision>> history(String id) =>
      _revisions.history(RevisionEntity.journalEntry, id);
}
