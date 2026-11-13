import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/market/models.dart';
import '../../data/repo/prediction_repository.dart';

final predictionViewsProvider = StreamProvider<List<PredictionView>>(
    (ref) => ref.watch(predictionRepositoryProvider).watchAll());

/// 待复盘数量（复盘 Tab 角标）。
final pendingReviewCountProvider = Provider<int>((ref) {
  final list = ref.watch(predictionViewsProvider).value ?? const [];
  return list.where((v) => v.verified && !v.reviewed).length;
});

/// 判断目标代码 → 显示名称。
final targetNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final list = ref.watch(predictionViewsProvider).value ?? const [];
  final codes = list.map((v) => v.prediction.targetCode).toSet();
  final rows = await ref.watch(instrumentRepositoryProvider).getMany(codes);
  return {
    for (final c in codes) c: indexShortNames[c] ?? rows[c]?.name ?? c,
  };
});
