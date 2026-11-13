import 'package:drift/drift.dart';

import '../../core/calendar/trading_calendar.dart';
import '../../core/ids.dart';
import '../../core/time/market_clock.dart';
import '../../domain/journal/entry_class.dart';
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
    EntryClass classification = EntryClass.empty,
    List<String> tags = const [],
    List<String> instrumentCodes = const [],
    String? snapshotId,
    String? templateId,
  }) async {
    final instant = at ?? _now();
    final loc = _calendar.locate(instant);
    final nowMs = _now().millisecondsSinceEpoch;
    final id = newId();
    final cls = classification.normalized();
    await _db.into(_db.journalEntries).insert(JournalEntriesCompanion.insert(
          id: id,
          createdAt: nowMs,
          updatedAt: nowMs,
          deviceId: await _db.deviceId(),
          tradeDate: TradeDate.format(loc.tradeDate),
          session: loc.session.code,
          ts: instant.millisecondsSinceEpoch,
          content: content,
          category: Value(cls.category),
          subcategory: Value(cls.subcategory),
          stance: Value(cls.stance),
          action: Value(cls.action),
          horizon: Value(cls.horizon),
          emotion: Value(cls.emotion),
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
    EntryClass? classification,
    List<String>? tags,
    List<String>? instrumentCodes,
  }) {
    return _db.transaction(() async {
      final current = await get(id);
      if (current == null) throw StateError('Journal entry $id not found');

      var next = current.copyWith(
        content: content ?? current.content,
        tags: tags ?? current.tags,
        instrumentCodes: instrumentCodes ?? current.instrumentCodes,
      );
      if (classification != null) {
        final c = classification.normalized();
        next = next.copyWith(
          category: Value(c.category),
          subcategory: Value(c.subcategory),
          stance: Value(c.stance),
          action: Value(c.action),
          horizon: Value(c.horizon),
          emotion: Value(c.emotion),
        );
      }
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

  /// 关联行情快照。属于系统字段，不产生修改历史。
  Future<void> attachSnapshot(String id, String snapshotId) async {
    await (_db.update(_db.journalEntries)..where((e) => e.id.equals(id)))
        .write(JournalEntriesCompanion(snapshotId: Value(snapshotId)));
  }

  /// 撤销软删除。
  Future<void> restore(String id) async {
    await (_db.update(_db.journalEntries)..where((e) => e.id.equals(id))).write(
        JournalEntriesCompanion(
            deletedAt: const Value(null),
            updatedAt: Value(_now().millisecondsSinceEpoch)));
  }

  /// 搜索：关键词（空格分隔，全部命中）匹配内容 / 标签 / 关联标的，并可按要素过滤。
  Future<List<JournalEntry>> search(JournalQuery q) {
    final query = _db.select(_db.journalEntries)..where((e) => e.deletedAt.isNull());
    for (final term in q.terms) {
      final p = '%${term.replaceAll('%', '').replaceAll('_', '')}%';
      query.where((e) => e.content.like(p) | e.tags.like(p) | e.instrumentCodes.like(p));
    }
    if (q.category != null) query.where((e) => e.category.equals(q.category!));
    if (q.subcategory != null) query.where((e) => e.subcategory.equals(q.subcategory!));
    if (q.stance != null) query.where((e) => e.stance.equals(q.stance!));
    if (q.action != null) query.where((e) => e.action.equals(q.action!));
    if (q.emotion != null) query.where((e) => e.emotion.equals(q.emotion!));
    if (q.tag != null) query.where((e) => e.tags.like('%"${q.tag}"%'));
    if (q.instrument != null) {
      query.where((e) => e.instrumentCodes.like('%"${q.instrument}"%'));
    }
    query
      ..orderBy([(e) => OrderingTerm.desc(e.ts)])
      ..limit(q.limit);
    return query.get();
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

class JournalQuery {
  const JournalQuery({
    this.text = '',
    this.category,
    this.subcategory,
    this.stance,
    this.action,
    this.emotion,
    this.tag,
    this.instrument,
    this.limit = 200,
  });

  final String text;
  final String? category;
  final String? subcategory;
  final String? stance;
  final String? action;
  final String? emotion;
  final String? tag;
  final String? instrument;
  final int limit;

  List<String> get terms =>
      text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  bool get isEmpty =>
      terms.isEmpty &&
      category == null &&
      subcategory == null &&
      stance == null &&
      action == null &&
      emotion == null &&
      tag == null &&
      instrument == null;
}

extension JournalEntryClass on JournalEntry {
  EntryClass get classification => EntryClass(
        category: category,
        subcategory: subcategory,
        stance: stance,
        action: action,
        horizon: horizon,
        emotion: emotion,
      );
}
