import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../data/repo/prediction_repository.dart';
import '../settings/threshold_page.dart';
import 'prediction_detail_page.dart';
import 'review_providers.dart';
import 'widgets/prediction_card.dart';
import 'widgets/stats_view.dart';

/// 复盘页（spec 3.3）：待复盘 / 进行中 / 全部 / 统计。
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  var _verifying = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _verify(silent: true));
  }

  Future<void> _verify({bool silent = false}) async {
    if (_verifying) return;
    setState(() => _verifying = true);
    try {
      final r = await ref.read(verificationServiceProvider).runDue();
      if (!mounted) return;
      if (!silent || r.verified > 0) {
        final msg = r.verified > 0
            ? '已验证 ${r.verified} 条判断'
            : r.waiting > 0
                ? '${r.waiting} 条已到期，等待行情数据更新'
                : '没有需要验证的判断';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('验证失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final views = ref.watch(predictionViewsProvider);
    final names = ref.watch(targetNamesProvider).value ?? const {};
    final repo = ref.watch(predictionRepositoryProvider);
    final list = views.value ?? const <PredictionView>[];
    // AI 判断不需要写复盘，只参与验证与统计
    final toReview = list.where((v) => v.prediction.source == 'user' && v.verified && !v.reviewed).toList()
      ..sort((a, b) => b.prediction.dueDate.compareTo(a.prediction.dueDate));
    final ongoing = list.where((v) => !v.verified).toList()
      ..sort((a, b) => a.prediction.dueDate.compareTo(b.prediction.dueDate));

    Widget listOf(List<PredictionView> items, String empty) => items.isEmpty
        ? Center(
            child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(empty,
                textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ))
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 88),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final v = items[i];
              return PredictionCard(
                key: ValueKey(v.prediction.id),
                view: v,
                name: names[v.prediction.targetCode] ?? v.prediction.targetCode,
                verifiable: !v.verified && repo.isCheckpointDue(v.primary, v.plan.primaryDate),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PredictionDetailPage(predictionId: v.prediction.id))),
              );
            },
          );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('复盘'),
          actions: [
            IconButton(
              tooltip: '判定阈值',
              icon: const Icon(Icons.tune),
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThresholdPage())),
            ),
            IconButton(
              tooltip: '立即验证到期判断',
              icon: _verifying
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.fact_check_outlined),
              onPressed: _verifying ? null : _verify,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: '待复盘 ${toReview.length}'),
              Tab(text: '进行中 ${ongoing.length}'),
              const Tab(text: '全部'),
              const Tab(text: '统计'),
            ],
          ),
        ),
        body: views.isLoading && list.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [
                listOf(toReview, '没有待复盘的判断\n判断到期验证后会出现在这里'),
                listOf(ongoing, '没有进行中的判断\n在日记中选"判断"，填写对象、方向、周期即可生成'),
                listOf(list, '还没有判断'),
                StatsView(views: list),
              ]),
      ),
    );
  }
}

