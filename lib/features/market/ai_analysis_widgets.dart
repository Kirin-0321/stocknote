import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../data/ai/llm.dart';
import '../../data/ai/market_analysis_service.dart';
import '../../data/db/app_database.dart';
import '../../data/market/market_service.dart';
import '../../data/market/models.dart';
import '../../data/repo/prediction_repository.dart';
import '../../domain/journal/entry_class.dart';
import '../../domain/verify/stats.dart';
import '../../domain/verify/verifier.dart';
import '../review/prediction_detail_page.dart';
import '../review/review_providers.dart';
import '../review/widgets/prediction_card.dart';
import '../settings/ai_settings_page.dart';
import 'widgets/market_widgets.dart';

final latestAnalysisProvider =
    StreamProvider<AiAnalysis?>((ref) => ref.watch(aiAnalysisRepositoryProvider).watchLatest());

final analysisHistoryProvider =
    StreamProvider<List<AiAnalysis>>((ref) => ref.watch(aiAnalysisRepositoryProvider).watchAll());

/// 分析是否正在进行（看板按钮与定时任务共用，避免重复请求）。
class AnalysisRunningNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final analysisRunningProvider = NotifierProvider<AnalysisRunningNotifier, bool>(AnalysisRunningNotifier.new);

/// 手动触发一次分析；返回错误信息（成功为 null）。
Future<String?> runMarketAnalysis(WidgetRef ref, {MarketOverview? data}) async {
  if (ref.read(analysisRunningProvider)) return null;
  ref.read(analysisRunningProvider.notifier).set(true);
  try {
    await ref.read(marketAnalysisServiceProvider).analyze(data: data);
    return null;
  } on AnalysisNotConfigured catch (e) {
    return e.toString();
  } on LlmException catch (e) {
    return 'AI 分析失败：$e';
  } catch (e) {
    return 'AI 分析失败：$e';
  } finally {
    ref.read(analysisRunningProvider.notifier).set(false);
  }
}

/// AI 判断：分析 id → 判断视图。
PredictionView? aiPredictionOf(WidgetRef ref, String analysisId) =>
    (ref.watch(predictionViewsProvider).value ?? const [])
        .where((v) => v.prediction.analysisId == analysisId)
        .firstOrNull;

String _targetName(String code) => indexShortNames[code] ?? code;

Color trendColor(BuildContext context, String? trend) {
  final mc = marketColors(context);
  return switch (trend) {
    '强势上涨' || '震荡偏强' => mc.up,
    '弱势下跌' || '震荡偏弱' => mc.down,
    _ => Theme.of(context).colorScheme.outline,
  };
}

/// 看板上的 AI 分析卡片（spec 3.1.2）。
class AiAnalysisCard extends ConsumerWidget {
  const AiAnalysisCard({super.key, required this.data});
  final MarketOverview data;

  Future<void> _run(BuildContext context, WidgetRef ref) async {
    final err = await runMarketAnalysis(ref, data: data);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestAnalysisProvider).value;
    final running = ref.watch(analysisRunningProvider);
    final ready = ref.watch(aiAnalysisReadyProvider).value ?? false;
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline);

    final Widget body;
    if (latest == null) {
      body = ready
          ? Text('点击"分析"，让 AI 根据当前盘面给出判断。', style: muted)
          : Row(children: [
              Expanded(child: Text('尚未配置 AI 模型 Key', style: muted)),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const AiSettingsPage())),
                child: const Text('去设置'),
              ),
            ]);
    } else {
      body = InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => AnalysisDetailPage(analysisId: latest.id))),
        child: AnalysisSummary(analysis: latest, compact: true),
      );
    }

    return BoardCard(
      key: const Key('ai-card'),
      title: 'AI 分析',
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (latest != null) Text('${formatDateTime(latest.ts)} · ${latest.model}', style: muted),
        IconButton(
          tooltip: '历史分析',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.history, size: 20),
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AnalysisHistoryPage())),
        ),
        running
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
            : TextButton.icon(
                key: const Key('ai-run'),
                onPressed: ready ? () => _run(context, ref) : null,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('分析'),
              ),
      ]),
      child: Padding(padding: const EdgeInsets.only(top: 8), child: body),
    );
  }
}

/// 分析内容。[compact] 用于看板卡片（不展开要点 / 风险）。
class AnalysisSummary extends ConsumerWidget {
  const AnalysisSummary({super.key, required this.analysis, this.compact = false});
  final AiAnalysis analysis;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final a = MarketAnalysis.of(analysis);
    if (a == null) {
      return Text(
        '模型输出无法解析为结构化结果，原文：\n${analysis.rawText ?? ''}',
        maxLines: compact ? 3 : null,
        overflow: compact ? TextOverflow.ellipsis : null,
        style: theme.textTheme.bodySmall,
      );
    }
    final color = trendColor(context, a.trend);
    final pv = aiPredictionOf(ref, analysis.id);
    final ol = a.outlook;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (a.trend != null) Pill(a.trend!, color: color),
        const SizedBox(width: 8),
        if (a.sentimentScore != null) ...[
          Text('情绪 ${a.sentimentScore}', style: theme.textTheme.labelMedium),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: a.sentimentScore! / 100,
                minHeight: 6,
                color: color,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ]),
      if (a.summary != null) ...[
        const SizedBox(height: 8),
        Text(a.summary!, style: theme.textTheme.bodyMedium),
      ],
      if (ol != null) ...[
        const SizedBox(height: 8),
        _OutlookLine(outlook: ol, view: pv),
      ],
      if (a.support.isNotEmpty || a.resistance.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          [
            if (a.support.isNotEmpty) '支撑 ${a.support.map((e) => e.toStringAsFixed(0)).join(' / ')}',
            if (a.resistance.isNotEmpty) '压力 ${a.resistance.map((e) => e.toStringAsFixed(0)).join(' / ')}',
          ].join('　'),
          style: theme.textTheme.labelSmall,
        ),
      ],
      if (!compact) ...[
        if (a.highlights.isNotEmpty) _Bullets(title: '要点', items: a.highlights, icon: Icons.trending_up),
        if (a.risks.isNotEmpty)
          _Bullets(title: '风险', items: a.risks, icon: Icons.warning_amber, color: theme.colorScheme.error),
      ],
    ]);
  }
}

class _OutlookLine extends StatelessWidget {
  const _OutlookLine({required this.outlook, this.view});
  final AiOutlook outlook;
  final PredictionView? view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = view?.status;
    final text = '展望：${_targetName(view?.prediction.targetCode ?? outlook.target)} '
        '${horizonLabels[outlook.horizon] ?? outlook.horizon} '
        '${directionLabels[outlook.direction] ?? outlook.direction}'
        '${outlook.confidence == null ? '' : ' · 信心 ${(outlook.confidence! * 100).round()}%'}';
    return Row(children: [
      Expanded(child: Text(text, style: theme.textTheme.labelLarge)),
      if (view != null)
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PredictionDetailPage(predictionId: view!.prediction.id))),
          child: Pill(st?.label ?? '待验证',
              color: st == null ? theme.colorScheme.outline : statusColor(context, st), icon: statusIcon(st)),
        ),
    ]);
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.title, required this.items, required this.icon, this.color});
  final String title;
  final List<String> items;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: theme.textTheme.titleSmall),
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 16, color: color ?? theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(s, style: theme.textTheme.bodyMedium)),
            ]),
          ),
      ]),
    );
  }
}

/// 历史分析列表。
class AnalysisHistoryPage extends ConsumerWidget {
  const AnalysisHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(analysisHistoryProvider).value;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('历史 AI 分析')),
      body: list == null
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? const Center(child: Text('还没有分析记录'))
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = list[i];
                    final a = MarketAnalysis.of(r);
                    final pv = aiPredictionOf(ref, r.id);
                    return ListTile(
                      title: Row(children: [
                        Text(formatDateTime(r.ts)),
                        const SizedBox(width: 8),
                        if (a?.trend != null) Pill(a!.trend!, color: trendColor(context, a.trend)),
                        if (r.trigger == 'scheduled') ...[
                          const SizedBox(width: 6),
                          Pill('定时', color: theme.colorScheme.outline),
                        ],
                        const Spacer(),
                        if (pv?.status != null) Icon(statusIcon(pv!.status), size: 18, color: statusColor(context, pv.status)),
                      ]),
                      subtitle: Text(a?.summary ?? r.rawText ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => AnalysisDetailPage(analysisId: r.id))),
                    );
                  },
                ),
    );
  }
}

/// 单次分析详情：完整内容、AI 判断验证结果、引用到日记、原始输入输出。
class AnalysisDetailPage extends ConsumerWidget {
  const AnalysisDetailPage({super.key, required this.analysisId});
  final String analysisId;

  Future<void> _quote(BuildContext context, WidgetRef ref, AiAnalysis r) async {
    final a = MarketAnalysis.of(r);
    final text = a == null
        ? 'AI 分析：${r.rawText ?? ''}'
        : 'AI 分析（${a.trend ?? ''}${a.sentimentScore == null ? '' : '，情绪 ${a.sentimentScore}'}）：${a.summary ?? ''}';
    await ref.read(journalServiceProvider).create(
          content: text,
          classification: const EntryClass(category: 'observe', subcategory: 'market'),
          tags: const ['AI'],
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已作为"观察 · 盘面"写入今天的日记')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = (ref.watch(analysisHistoryProvider).value ?? const []).where((a) => a.id == analysisId).firstOrNull;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        title: Text(r == null ? 'AI 分析' : formatDateTime(r.ts)),
        actions: [
          if (r != null)
            IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    content: const Text('删除这条分析？对应的 AI 判断保留。'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('删除')),
                    ],
                  ),
                );
                if (ok != true) return;
                await ref.read(aiAnalysisRepositoryProvider).delete(r.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
      body: r == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              AnalysisSummary(analysis: r),
              const SizedBox(height: 16),
              Row(children: [
                FilledButton.tonalIcon(
                  key: const Key('ai-quote'),
                  onPressed: () => _quote(context, ref, r),
                  icon: const Icon(Icons.format_quote),
                  label: const Text('引用到日记'),
                ),
              ]),
              const SizedBox(height: 16),
              Text(
                '${r.trigger == 'scheduled' ? '定时' : '手动'}分析 · ${r.provider} / ${r.model} · 提示词 ${r.promptVersion}'
                '${r.tokensIn == null ? '' : ' · ${r.tokensIn}/${r.tokensOut} tokens'}',
                style: muted,
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('发送给模型的盘面数据'),
                children: [SelectableText(r.inputDigest ?? '', style: theme.textTheme.bodySmall)],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('模型原始输出'),
                children: [SelectableText(r.rawText ?? '', style: theme.textTheme.bodySmall)],
              ),
              const SizedBox(height: 8),
              Text('AI 分析仅供参考，不构成投资建议。', style: muted),
            ]),
    );
  }
}
