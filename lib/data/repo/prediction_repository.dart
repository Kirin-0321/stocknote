import 'package:drift/drift.dart';

import '../../core/calendar/trading_calendar.dart';
import '../../core/ids.dart';
import '../../core/time/market_clock.dart';
import '../../core/time/trading_session.dart';
import '../../domain/verify/checkpoints.dart';
import '../../domain/verify/verifier.dart';
import '../db/app_database.dart';
import 'revision_recorder.dart';

/// 判断及其各时点结果、关联日记、复盘笔记的组合视图。
class PredictionView {
  const PredictionView({
    required this.prediction,
    required this.plan,
    this.results = const {},
    this.entry,
    this.review,
  });

  final Prediction prediction;
  final CheckpointPlan plan;

  /// 时点 → 结果
  final Map<Checkpoint, PredictionResult> results;
  final JournalEntry? entry;
  final ReviewNote? review;

  Checkpoint get primary => plan.primary;

  /// 主时点结果（判断的主结论）
  PredictionResult? get result => results[primary];
  VerifyStatus? get status => VerifyStatus.fromCode(result?.status);
  VerifyStatus? statusAt(Checkpoint c) => VerifyStatus.fromCode(results[c]?.status);

  bool get verified => result != null;
  bool get allDone => plan.points.keys.every(results.containsKey);
  bool get reviewed => review != null;
}

/// 判断仓库（spec 3.3）。
///
/// 用户判断由"判断"类日记自动生成并保持同步：一条日记最多一条判断；
/// 每条判断按 [CheckpointPlan] 在多个时点各有一条结果。
class PredictionRepository {
  PredictionRepository(this._db, this._calendar,
      {DateTime Function()? now, this.defaultIndex = defaultIndexCode})
      : _now = now ?? DateTime.now,
        _revisions = RevisionRecorder(_db, now: now);

  static const defaultIndexCode = '000001.SH';

  /// 大盘 / 指数判断未关联标的时的默认判定指数（设置中可调）。
  final String defaultIndex;

  final AppDatabase _db;
  final TradingCalendar _calendar;
  final DateTime Function() _now;
  final RevisionRecorder _revisions;

  int get _ms => _now().millisecondsSinceEpoch;

  // ───────────── 验证计划 ─────────────

  /// 判断的验证计划：有日记按记录时刻；无日记（如 AI 判断）按创建时刻。
  CheckpointPlan planOf(Prediction p, JournalEntry? e) {
    if (e != null) {
      return CheckpointPlan.of(
          _calendar, TradeDate.parse(e.tradeDate), TradingSession.fromCode(e.session), p.horizonType);
    }
    final loc = _calendar.locate(DateTime.fromMillisecondsSinceEpoch(p.createdAt, isUtc: true));
    return CheckpointPlan.of(_calendar, loc.tradeDate, loc.session, p.horizonType);
  }

  /// 某时点是否已可判定：收盘时点在该日 15:05 后，开盘时点在该日 9:26 后。
  bool isCheckpointDue(Checkpoint c, DateTime date) {
    final now = MarketClock.toMarket(_now());
    final today = TradeDate.format(DateTime.utc(now.year, now.month, now.day));
    final d = TradeDate.format(date);
    if (today.compareTo(d) > 0) return true;
    if (today != d) return false;
    final minutes = now.hour * 60 + now.minute;
    return c.atOpen ? minutes >= 9 * 60 + 26 : minutes >= 15 * 60 + 5;
  }

  // ───────────── 由日记同步 ─────────────

  /// 日记 → 判断的目标代码：取第一个已解析的关联标的；
  /// 大盘 / 指数判断未关联时用 [defaultIndex]。
  String? targetOf(JournalEntry e) {
    final code = e.instrumentCodes.where((c) => c.contains('.')).firstOrNull;
    if (code != null) return code;
    if (e.subcategory == 'market' || e.subcategory == 'index') return defaultIndex;
    return null;
  }

  bool qualifies(JournalEntry e) =>
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
    final plan = CheckpointPlan.of(
        _calendar, TradeDate.parse(e.tradeDate), TradingSession.fromCode(e.session), horizon);
    final due = TradeDate.format(plan.primaryDate);
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
    if (q is! Map || q['approx'] == true) return null; // 估算价不作为基准
    final p = q['price'];
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

  /// 写入修改；用户修改会记录历史，主时点判定前修改标记"已修改判断"，并清除自动判定结果以便重新验证。
  Future<Prediction?> _applyUpdate(Prediction before, Prediction next, {required bool userEdit}) {
    return _db.transaction(() async {
      final beforeJson = before.toJson();
      final changed = RevisionRecorder.diff(beforeJson, next.toJson());
      if (changed.isEmpty) return before;
      // 仅补全基准价属于系统行为，不算修改
      final userChanged = changed.where((f) => f != 'basePrice').toList();
      var out = next.copyWith(updatedAt: _ms);
      if (userEdit && userChanged.isNotEmpty) {
        final decided = await _hasAnyResult(before.id);
        out = out.copyWith(
          revisionCount: before.revisionCount + 1,
          modifiedBeforeDue: before.modifiedBeforeDue || !decided,
        );
        await _revisions.record(
          entityType: RevisionEntity.prediction,
          entityId: before.id,
          revisionNo: before.revisionCount + 1,
          before: beforeJson,
          changedFields: userChanged,
        );
        await _deleteAutoResults(before.id);
      }
      await _db.update(_db.predictions).replace(out);
      return out;
    });
  }

  Future<bool> _hasAnyResult(String predictionId) async =>
      (await (_db.select(_db.predictionResults)
                ..where((r) => r.predictionId.equals(predictionId) & r.deletedAt.isNull())
                ..limit(1))
              .get())
          .isNotEmpty;

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

  Future<List<PredictionResult>> resultsFor(String predictionId) => (_db.select(_db.predictionResults)
        ..where((r) => r.predictionId.equals(predictionId) & r.deletedAt.isNull()))
      .get();

  JoinedSelectStatement<HasResultSet, dynamic> _joined() {
    return _db.select(_db.predictions).join([
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
  }

  /// 联表结果按判断聚合（一条判断对应多条时点结果）。
  List<PredictionView> _group(List<TypedResult> rows) {
    final order = <String>[];
    final preds = <String, Prediction>{};
    final entries = <String, JournalEntry?>{};
    final reviews = <String, ReviewNote?>{};
    final results = <String, Map<Checkpoint, PredictionResult>>{};
    for (final r in rows) {
      final p = r.readTable(_db.predictions);
      if (!preds.containsKey(p.id)) {
        order.add(p.id);
        preds[p.id] = p;
        entries[p.id] = r.readTableOrNull(_db.journalEntries);
        reviews[p.id] = r.readTableOrNull(_db.reviewNotes);
        results[p.id] = {};
      }
      final res = r.readTableOrNull(_db.predictionResults);
      final cp = Checkpoint.fromCode(res?.checkpoint);
      if (res != null && cp != null) results[p.id]![cp] = res;
    }
    return [
      for (final id in order)
        PredictionView(
          prediction: preds[id]!,
          plan: planOf(preds[id]!, entries[id]),
          results: results[id]!,
          entry: entries[id],
          review: reviews[id],
        ),
    ];
  }

  Stream<List<PredictionView>> watchAll() => _joined().watch().map(_group);

  Future<List<PredictionView>> all() async => _group(await _joined().get());

  Future<PredictionView?> view(String id) async {
    final q = _joined()..where(_db.predictions.id.equals(id));
    final list = _group(await q.get());
    return list.firstOrNull;
  }

  /// 还有时点未判定且已到可判定时间的判断（含各自待判定的时点）。
  Future<List<(PredictionView, List<Checkpoint>)>> pendingCheckpoints() async {
    final out = <(PredictionView, List<Checkpoint>)>[];
    for (final v in await all()) {
      final due = [
        for (final e in v.plan.points.entries)
          if (!v.results.containsKey(e.key) && isCheckpointDue(e.key, e.value)) e.key,
      ];
      if (due.isNotEmpty) out.add((v, due));
    }
    return out;
  }

  // ───────────── 结果 ─────────────

  Future<void> saveResult(String predictionId, Checkpoint cp, VerifyOutcome o, {int ruleVersion = 1}) async {
    await _db.transaction(() async {
      await _deleteResults(predictionId, cp);
      await _db.into(_db.predictionResults).insert(PredictionResultsCompanion.insert(
            id: newId(),
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            predictionId: predictionId,
            checkpoint: Value(cp.code),
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

  /// 手动判定某时点（覆盖自动结果，标记为手动，重新验证时保留）。
  Future<void> setManualStatus(String predictionId, Checkpoint cp, VerifyStatus status) async {
    final existing = (await resultsFor(predictionId)).where((r) => r.checkpoint == cp.code).firstOrNull;
    await _db.transaction(() async {
      await _deleteResults(predictionId, cp);
      await _db.into(_db.predictionResults).insert(PredictionResultsCompanion.insert(
            id: newId(),
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            predictionId: predictionId,
            checkpoint: Value(cp.code),
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

  /// 清除某时点的结果（含手动），之后由验证服务重新自动判定。
  Future<void> resetResult(String predictionId, Checkpoint cp) => _deleteResults(predictionId, cp);

  Future<void> _deleteResults(String predictionId, Checkpoint cp) async {
    await (_db.update(_db.predictionResults)
          ..where((r) =>
              r.predictionId.equals(predictionId) & r.checkpoint.equals(cp.code) & r.deletedAt.isNull()))
        .write(PredictionResultsCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));
  }

  Future<void> _deleteAutoResults(String predictionId) async {
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
