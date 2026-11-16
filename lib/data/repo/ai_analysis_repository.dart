import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../../core/ids.dart';

/// AI 大盘分析记录（spec 3.1.2 / 5.5 ai_analysis）。
class AiAnalysisRepository {
  AiAnalysisRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<AiAnalysis> insert({
    required String trigger,
    required String provider,
    required String model,
    required String promptVersion,
    String? input,
    Map<String, dynamic>? output,
    String? rawText,
    int? tokensIn,
    int? tokensOut,
  }) async {
    final ms = _now().millisecondsSinceEpoch;
    return _db.into(_db.aiAnalyses).insertReturning(AiAnalysesCompanion.insert(
          id: newId(),
          createdAt: ms,
          updatedAt: ms,
          deviceId: await _db.deviceId(),
          ts: ms,
          trigger: trigger,
          provider: provider,
          model: model,
          promptVersion: promptVersion,
          inputDigest: Value(input),
          output: Value(output),
          rawText: Value(rawText),
          tokensIn: Value(tokensIn),
          tokensOut: Value(tokensOut),
        ));
  }

  SimpleSelectStatement<$AiAnalysesTable, AiAnalysis> _alive() =>
      _db.select(_db.aiAnalyses)..where((a) => a.deletedAt.isNull());

  Stream<AiAnalysis?> watchLatest() => (_alive()
        ..orderBy([(a) => OrderingTerm.desc(a.ts)])
        ..limit(1))
      .watchSingleOrNull();

  Stream<List<AiAnalysis>> watchAll({int limit = 200}) => (_alive()
        ..orderBy([(a) => OrderingTerm.desc(a.ts)])
        ..limit(limit))
      .watch();

  Future<List<AiAnalysis>> recent({int limit = 10}) => (_alive()
        ..orderBy([(a) => OrderingTerm.desc(a.ts)])
        ..limit(limit))
      .get();

  Future<AiAnalysis?> get(String id) =>
      (_db.select(_db.aiAnalyses)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> delete(String id) async {
    final ms = _now().millisecondsSinceEpoch;
    await (_db.update(_db.aiAnalyses)..where((a) => a.id.equals(id)))
        .write(AiAnalysesCompanion(deletedAt: Value(ms), updatedAt: Value(ms)));
  }

  /// 累计 token 用量（输入, 输出）
  Future<(int, int)> tokenUsage() async {
    final i = _db.aiAnalyses.tokensIn.sum();
    final o = _db.aiAnalyses.tokensOut.sum();
    final row = await (_db.selectOnly(_db.aiAnalyses)..addColumns([i, o])).getSingle();
    return (row.read(i) ?? 0, row.read(o) ?? 0);
  }
}
