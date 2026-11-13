import '../../data/repo/prediction_repository.dart';
import 'verifier.dart';

/// 一组判断的统计。
class StatBucket {
  int correct = 0;
  int partial = 0;
  int wrong = 0;
  int manualPending = 0;

  int get decided => correct + partial + wrong;

  /// 正确率：完全正确 / 已判定
  double get accuracy => decided == 0 ? 0 : correct / decided;

  /// 方向正确率：(正确 + 部分正确) / 已判定
  double get directional => decided == 0 ? 0 : (correct + partial) / decided;

  void add(VerifyStatus s) {
    switch (s) {
      case VerifyStatus.correct:
        correct++;
      case VerifyStatus.partial:
        partial++;
      case VerifyStatus.wrong:
        wrong++;
      case VerifyStatus.pendingManual:
        manualPending++;
    }
  }
}

/// 判断准确率统计（spec 3.3.5）。
class PredictionStats {
  PredictionStats._();

  final overall = StatBucket();
  final byDirection = <String, StatBucket>{};
  final byTarget = <String, StatBucket>{};
  final byHorizon = <String, StatBucket>{};
  final byConfidence = <int, StatBucket>{};
  int pending = 0;
  int modified = 0;

  /// [excludeModified] 为 true 时排除到期前修改过的判断，保证统计诚实。
  static PredictionStats compute(List<PredictionView> views, {bool excludeModified = false}) {
    final s = PredictionStats._();
    for (final v in views) {
      final p = v.prediction;
      if (p.modifiedBeforeDue) s.modified++;
      if (excludeModified && p.modifiedBeforeDue) continue;
      final status = v.status;
      if (status == null) {
        s.pending++;
        continue;
      }
      s.overall.add(status);
      s.byDirection.putIfAbsent(p.direction, StatBucket.new).add(status);
      s.byTarget.putIfAbsent(v.entry?.subcategory ?? 'other', StatBucket.new).add(status);
      s.byHorizon.putIfAbsent(p.horizonType, StatBucket.new).add(status);
      s.byConfidence.putIfAbsent(p.confidence, StatBucket.new).add(status);
    }
    return s;
  }
}

const directionLabels = {'up': '看多', 'down': '看空', 'range': '震荡'};
