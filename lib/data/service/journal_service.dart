import 'dart:async';

import '../../domain/journal/entry_class.dart';
import '../db/app_database.dart';
import '../market/snapshot_service.dart';
import '../repo/journal_repository.dart';
import '../repo/prediction_repository.dart';

/// 日记的业务编排：保存条目 → 同步判断 → 后台抓行情快照并补全判断基准价。
class JournalService {
  JournalService({required this.journal, required this.predictions, required this.snapshots});

  final JournalRepository journal;
  final PredictionRepository predictions;
  final SnapshotService snapshots;

  Future<JournalEntry> create({
    required String content,
    EntryClass classification = EntryClass.empty,
    List<String> tags = const [],
    List<String> instrumentCodes = const [],
    bool captureSnapshot = true,
  }) async {
    final entry = await journal.create(
      content: content,
      classification: classification,
      tags: tags,
      instrumentCodes: instrumentCodes,
    );
    await predictions.syncFromEntry(entry);
    if (captureSnapshot) {
      // 后台抓取，不阻塞连续记录
      unawaited(_attachSnapshot(entry.id, instrumentCodes).catchError((_) {}));
    }
    return entry;
  }

  Future<void> _attachSnapshot(String entryId, List<String> codes) async {
    final targets = {...codes, ?predictions.targetOf((await journal.get(entryId))!)}.toList();
    final s = await snapshots.capture(targets);
    if (s == null) return;
    await journal.attachSnapshot(entryId, s.id);
    final e = await journal.get(entryId);
    if (e != null) await predictions.syncFromEntry(e, snapshot: s);
  }

  Future<JournalEntry> update(
    String id, {
    String? content,
    DateTime? at,
    EntryClass? classification,
    List<String>? tags,
    List<String>? instrumentCodes,
  }) async {
    final e = await journal.update(id,
        content: content,
        at: at,
        classification: classification,
        tags: tags,
        instrumentCodes: instrumentCodes);
    await predictions.syncFromEntry(e);
    return e;
  }

  /// 为尚未生成判断的"判断"类日记补建判断（如功能上线前记录的条目）。返回补建数量。
  Future<int> backfillPredictions() async {
    var n = 0;
    for (final e in await journal.judgeEntries()) {
      if (await predictions.forEntry(e.id) != null) continue;
      if (await predictions.syncFromEntry(e) != null) n++;
    }
    return n;
  }

  Future<void> delete(String id) async {
    await journal.delete(id);
    final e = await journal.get(id);
    if (e != null) await predictions.syncFromEntry(e);
  }

  Future<void> restore(String id) async {
    await journal.restore(id);
    final e = await journal.get(id);
    if (e != null) await predictions.syncFromEntry(e);
  }
}
