import 'package:drift/drift.dart';

import '../../core/calendar/trading_calendar.dart';
import '../../core/ids.dart';
import '../../core/time/market_clock.dart';
import '../../core/time/trading_session.dart';
import '../../domain/verify/verifier.dart';
import '../db/app_database.dart';
import 'revision_recorder.dart';

/// 判断及其结果、关联日记、复盘笔记的组合视图。
class PredictionView {
  const PredictionView({required this.prediction, this.result, this.entry, this.review});

  final Prediction prediction;
  final PredictionResult? result;
  final JournalEntry? entry;
  final ReviewNote? review;

  VerifyStatus? get status => VerifyStatus.fromCode(result?.status);
  bool get verified => result != null;
  bool get reviewed => review != null;
}

/// 判断仓库（spec 3.3）。
///
/// 用户判断由"判断"类日记自动生成并保持同步：一条日记最多一条判断。
class PredictionRepository {
  PredictionRepository(this._db, this._calendar, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        _revisions = RevisionRecorder(_db, now: now);

  final AppDatabase _db;
  final TradingCalendar _calendar;
  final DateTime Function() _now;
  final RevisionRecorder _revisions;

  int get _ms => _now().millisecondsSinceEpoch;

  // ───────────── 由日记同步 ─────────────

  /// 日记 → 判断的目标代码：大盘默认上证指数；其余取第一个已解析的关联标的。
  static String? targetOf(JournalEntry e) {
    final code = e.instrumentCodes.where((c) => c.contains('.')).firstOrNull;
    if (code != null) return code;
    if (e.subcategory == 'market') return '000001.SH';
    return null;
  }

  static bool qualifies(JournalEntry e) =>
      e.deletedAt == null && e.category == 'judge' && e.stance != null && targetOf(e) != null;

  Future<Prediction?> forEntry(String entryId) => (_db.select(_db.predictions)
        ..where((p) => p.entryId.equals(entryId) & p.deletedAt.isNull() & p.source.equals('user')))
      .getSingleOrNull();

  /// 根据日记创建 / 更新 / 删除对应判断。[snapshot] 用于补全基准价。
  Future<Prediction?> syncFromEntry(JournalEntry e, {MarketSnapshot? snapshot}) async {
    final existing = await forEntry(e.id);
    if (!qualifies(e)) {
      if (existing != null) await _softDelete(existing.id);
      return null;
    }
    final target = targetOf(e)!;
    final horizon = e.horizon ?? 't1';
    final window = PredictionWindow.of(
        _calendar, TradeDate.parse(e.tradeDate), TradingSession.fromCode(e.session), horizon);
    final due = TradeDate.format(window.dueDate);
    final direction = Verifier.directionOf(e.stance!);
    final snap = snapshot ??
        (e.snapshotId == null
            ? null
            : await (_db.select(_db.marketSnapshots)..where((s) => s.id.equals(e.snapshotId!)))
                .getSingleOrNull());
    final base = _priceFromSnapshot(snap, target);

    if (existing == null) {
      final id = newId();
      await _db.into(_db.predictions).insert(PredictionsCompanion.insert(
            id: id,
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            entryId: Value(e.id),
            source: 'user',
            targetCode: target,
            direction: direction,
            horizonType: horizon,
            dueDate: due,
            basePrice: Value(base),
          ));
      return get(id);
    }

    final next = existing.copyWith(
      targetCode: target,
      direction: direction,
      horizonType: horizon,
      dueDate: due,
      basePrice: Value(existing.basePrice ?? base),
    );
    return _applyUpdate(existing, next, userEdit: true);
  }

  static double? _priceFromSnapshot(MarketSnapshot? s, String code) {
    if (s == null) return null;
    final q = s.indices[code] ?? (s.extra?['instruments'] as Map?)?[code];
    final p = (q is Map) ? q['price'] : null;
    return p is num ? p.toDouble() : null;
  }

  /// 修改判断参数（目标价 / 止损价 / 阈值覆盖 / 信心度）。
  Future<Prediction?> updateParams(
    String id, {
    Value<double?> targetPrice = const Value.absent(),
    Value<double?> stopPrice = const Value.absent(),
    Value<double?> thresholdPct = const Value.absent(),
    int? confidence,
  }) async {
    final p = await get(id);
    if (p == null) return null;
    final next = p.copyWith(
      targetPrice: targetPrice.present ? targetPrice : Value(p.targetPrice),
      stopPrice: stopPrice.present ? stopPrice : Value(p.stopPrice),
      thresholdPct: thresholdPct.present ? thresholdPct : Value(p.thresholdPct),
      confidence: confidence ?? p.confidence,
    );
    return _applyUpdate(p, next, userEdit: true);
  }

  /// 写入修改；用户修改会记录历史，到期前修改标记"已修改判断"，并清除自动判定结果以便重新验证。
  Future<Prediction?> _applyUpdate(Prediction before, Prediction next, {required bool userEdit}) {
    return _db.transaction(() async {
      final beforeJson = before.toJson();
      final changed = RevisionRecorder.diff(beforeJson, next.toJson());
      if (changed.isEmpty) return before;
      // 仅补全基准价属于系统行为，不算修改
      final userChanged = changed.where((f) => f != 'basePrice').toList();
      var out = next.copyWith(updatedAt: _ms);
      if (userEdit && userChanged.isNotEmpty) {
        final hasResult = await resultFor(before.id) != null;
        out = out.copyWith(
          revisionCount: before.revisionCount + 1,
          modifiedBeforeDue: before.modifiedBeforeDue || (!hasResult && !_isDuePassed(before.dueDate)),
        );
        await _revisions.record(
          entityType: RevisionEntity.prediction,
          entityId: before.id,
          revisionNo: before.revisionCount + 1,
          before: beforeJson,
          changedFields: userChanged,
        );
        await _deleteAutoResult(before.id);
      }
      await _db.update(_db.predictions).replace(out);
      return out;
    });
  }

  bool _isDuePassed(String dueDate) {
    final now = MarketClock.toMarket(_now());
    final today = TradeDate.format(DateTime.utc(now.year, now.month, now.day));
    return today.compareTo(dueDate) > 0 ||
        (today == dueDate && now.hour * 60 + now.minute >= 15 * 60);
  }

  /// 是否已到可判定时间（到期日 15:30 之后）。
  bool isVerifiable(String dueDate) {
    final now = MarketClock.toMarket(_now());
    final today = TradeDate.format(DateTime.utc(now.year, now.month, now.day));
    return today.compareTo(dueDate) > 0 ||
        (today == dueDate && now.hour * 60 + now.minute >= 15 * 60 + 30);
  }

  Future<void> _softDelete(String id) async {
    await (_db.update(_db.predictions)..where((p) => p.id.equals(id)))
        .write(PredictionsCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));
  }

  Future<void> setBasePrice(String id, double base) async {
    await (_db.update(_db.predictions)..where((p) => p.id.equals(id)))
        .write(PredictionsCompanion(basePrice: Value(base), updatedAt: Value(_ms)));
  }

  // ───────────── 查询 ─────────────

  Future<Prediction?> get(String id) =>
      (_db.select(_db.predictions)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<PredictionResult?> resultFor(String predictionId) => (_db.select(_db.predictionResults)
        ..where((r) => r.predictionId.equals(predictionId) & r.deletedAt.isNull()))
      .getSingleOrNull();

  JoinedSelectStatement<HasResultSet, dynamic> _joined() {
    final q = _db.select(_db.predictions).join([
      leftOuterJoin(
          _db.predictionResults,
          _db.predictionResults.predictionId.equalsExp(_db.predictions.id) &
              _db.predictionResults.deletedAt.isNull()),
      leftOuterJoin(_db.journalEntries, _db.journalEntries.id.equalsExp(_db.predictions.entryId)),
      leftOuterJoin(
          _db.reviewNotes,
          _db.reviewNotes.predictionId.equalsExp(_db.predictions.id) &
              _db.reviewNotes.deletedAt.isNull()),
    ])
      ..where(_db.predictions.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(_db.predictions.createdAt)]);
    return q;
  }

  PredictionView _map(TypedResult r) => PredictionView(
        prediction: r.readTable(_db.predictions),
        result: r.readTableOrNull(_db.predictionResults),
        entry: r.readTableOrNull(_db.journalEntries),
        review: r.readTableOrNull(_db.reviewNotes),
      );

  Stream<List<PredictionView>> watchAll() => _joined().watch().map((rows) => rows.map(_map).toList());

  Future<List<PredictionView>> all() async => (await _joined().get()).map(_map).toList();

  Future<PredictionView?> view(String id) async {
    final q = _joined()..where(_db.predictions.id.equals(id));
    final rows = await q.get();
    return rows.isEmpty ? null : _map(rows.first);
  }

  /// 已到期、尚无结果的判断。
  Future<List<Prediction>> dueUnverified() async {
    final list = await (_db.select(_db.predictions)..where((p) => p.deletedAt.isNull())).get();
    final out = <Prediction>[];
    for (final p in list) {
      if (!isVerifiable(p.dueDate)) continue;
      if (await resultFor(p.id) == null) out.add(p);
    }
    return out;
  }

  // ───────────── 结果 ─────────────

  Future<void> saveResult(String predictionId, VerifyOutcome o, {int ruleVersion = 1}) async {
    await _db.transaction(() async {
      await _deleteResults(predictionId);
      await _db.into(_db.predictionResults).insert(PredictionResultsCompanion.insert(
            id: newId(),
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            predictionId: predictionId,
            status: o.status.code,
            actualClose: Value(o.actualClose),
            changePct: Value(o.changePct),
            mfe: Value(o.mfe),
            mae: Value(o.mae),
            decidedAt: _ms,
            ruleVersion: Value(ruleVersion),
          ));
    });
  }

  /// 手动判定（覆盖自动结果，标记为手动，重新验证时保留）。
  Future<void> setManualStatus(String predictionId, VerifyStatus status) async {
    final existing = await resultFor(predictionId);
    await _db.transaction(() async {
      await _deleteResults(predictionId);
      await _db.into(_db.predictionResults).insert(PredictionResultsCompanion.insert(
            id: newId(),
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            predictionId: predictionId,
            status: status.code,
            actualClose: Value(existing?.actualClose),
            changePct: Value(existing?.changePct),
            mfe: Value(existing?.mfe),
            mae: Value(existing?.mae),
            decidedAt: _ms,
            isManual: const Value(true),
          ));
    });
  }

  /// 清除某条判断的结果（含手动），之后由验证服务重新自动判定。
  Future<void> resetResult(String predictionId) => _deleteResults(predictionId);

  Future<void> _deleteResults(String predictionId) async {
    await (_db.update(_db.predictionResults)
          ..where((r) => r.predictionId.equals(predictionId) & r.deletedAt.isNull()))
        .write(PredictionResultsCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));
  }

  Future<void> _deleteAutoResult(String predictionId) async {
    await (_db.update(_db.predictionResults)
          ..where((r) =>
              r.predictionId.equals(predictionId) & r.deletedAt.isNull() & r.isManual.equals(false)))
        .write(PredictionResultsCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));
  }

  /// 清除全部自动判定结果（阈值变更后重新判定）。
  Future<int> clearAutoResults() => (_db.update(_db.predictionResults)
        ..where((r) => r.deletedAt.isNull() & r.isManual.equals(false)))
      .write(PredictionResultsCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));

  // ───────────── 复盘 ─────────────

  Future<void> saveReview(String predictionId, {String content = '', List<String> reasons = const []}) async {
    final existing = await (_db.select(_db.reviewNotes)
          ..where((n) => n.predictionId.equals(predictionId) & n.deletedAt.isNull()))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.reviewNotes)..where((n) => n.id.equals(existing.id))).write(
          ReviewNotesCompanion(content: Value(content), reasons: Value(reasons), updatedAt: Value(_ms)));
      return;
    }
    final p = await get(predictionId);
    await _db.into(_db.reviewNotes).insert(ReviewNotesCompanion.insert(
          id: newId(),
          createdAt: _ms,
          updatedAt: _ms,
          deviceId: await _db.deviceId(),
          predictionId: Value(predictionId),
          entryId: Value(p?.entryId),
          content: content,
          reasons: Value(reasons),
        ));
  }

  Future<List<Revision>> history(String id) => _revisions.history(RevisionEntity.prediction, id);
}
