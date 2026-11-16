import '../../data/agent/agent_service.dart';
import '../agent/agent_chat_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/market_clock.dart';
import '../../data/db/app_database.dart';
import '../../data/market/code_util.dart';
import '../../data/market/models.dart';
import '../../data/repo/prediction_repository.dart';
import '../../domain/verify/stats.dart';
import '../../domain/verify/verifier.dart';
import '../market/ai_analysis_widgets.dart';
import '../journal/widgets/highlighted_text.dart';
import '../journal/widgets/snapshot_line.dart';
import '../market/widgets/charts.dart';
import '../market/widgets/market_widgets.dart';
import 'review_providers.dart';
import 'widgets/prediction_card.dart';

/// 复盘时可选的原因（多选）。
const reviewReasons = ['逻辑正确', '逻辑对时机错', '消息面突变', '判断失误', '追随情绪', '运气成分'];

final _barsProvider = FutureProvider.autoDispose.family<List<KBar>, (String, String)>((ref, args) {
  final (code, from) = args;
  return ref.watch(marketServiceProvider).dailyKline(code, from: from);
});

/// 判断详情：原文、判定结果、K 线、参数、手动判定与复盘笔记。
class PredictionDetailPage extends ConsumerWidget {
  const PredictionDetailPage({super.key, required this.predictionId});
  final String predictionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(predictionViewsProvider).value;
    final v = list?.where((x) => x.prediction.id == predictionId).firstOrNull;
    final names = ref.watch(targetNamesProvider).value ?? const {};
    if (v == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: list == null ? const CircularProgressIndicator() : const Text('判断不存在或已删除')),
      );
    }
    final p = v.prediction;
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final name = names[p.targetCode] ?? p.targetCode;
    final dirColor = switch (p.direction) { 'up' => mc.up, 'down' => mc.down, _ => mc.flat };

    // K 线区间：记录日前 15 个自然日 ~ 今天
    final entryDate = v.entry?.tradeDate ?? p.dueDate;
    final from = TradeDate.format(TradeDate.parse(entryDate).subtract(const Duration(days: 21)));
    final bars = ref.watch(_barsProvider((p.targetCode, from)));

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name),
          Text(p.targetCode, style: theme.textTheme.labelSmall),
        ]),
        actions: [
          IconButton(
            tooltip: '问 AI',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AgentChatPage(
                      pageContext: AgentPageContext(
                        label: '判断：$name ${directionLabels[p.direction] ?? p.direction}',
                        text: '用户正在看一条判断（id: ${p.id}）：$name（${p.targetCode}）'
                            '${directionLabels[p.direction] ?? p.direction}，周期 ${horizonLabels[p.horizonType] ?? p.horizonType}，'
                            '到期 ${p.dueDate}，基准价 ${p.basePrice ?? '未知'}，结果 ${v.status?.label ?? '待验证'}。'
                            '${v.entry == null ? '' : '原始日记（id: ${v.entry!.id}）：${v.entry!.content}'}'
                            '${v.review == null ? '' : ' 复盘笔记：${v.review!.content}'}',
                      ),
                    ))),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(spacing: 6, runSpacing: 4, children: [
            Pill(directionLabels[p.direction] ?? p.direction, color: dirColor),
            Pill('周期 ${horizonLabels[p.horizonType] ?? p.horizonType}', color: theme.colorScheme.primary),
            Pill('到期 ${formatDue(p.dueDate)}', color: theme.colorScheme.outline),
            if (p.modifiedBeforeDue) Pill('到期前修改过 ${p.revisionCount} 次', color: theme.colorScheme.error),
          ]),
        ),
        if (v.entry != null)
          BoardCard(
            title: '原始记录 · ${formatDateTime(v.entry!.ts)}',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HighlightedText(v.entry!.content),
              SnapshotLine(entry: v.entry!),
            ]),
          ),
        if (v.entry == null && p.analysisId != null)
          BoardCard(
            title: 'AI 分析 · ${formatDateTime(p.createdAt)}',
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AnalysisDetailPage(analysisId: p.analysisId!))),
              child: const Text('查看分析'),
            ),
            child: const SizedBox.shrink(),
          ),
        _ResultCard(view: v),
        BoardCard(
          title: '走势（● 记录日 / 到期日）',
          child: bars.when(
            data: (b) => CandleChart(
              bars: b.length > 60 ? b.sublist(b.length - 60) : b,
              height: 200,
              markers: {entryDate: 1, p.dueDate: 1},
            ),
            loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SizedBox(height: 80, child: Center(child: Text('K 线获取失败：$e'))),
          ),
        ),
        _ParamsCard(prediction: p),
        if (p.source == 'user') _ReviewCard(view: v),
      ]),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.view});
  final PredictionView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = view.prediction;
    final r = view.result;
    final s = view.status;
    final repo = ref.read(predictionRepositoryProvider);
    final mc = marketColors(context);

    final primary = view.primary;
    final primaryDate = view.plan.primaryDate;
    return BoardCard(
      title: '主结论 · ${primary.label}',
      trailing: r?.isManual ?? false ? Pill('手动判定', color: theme.colorScheme.tertiary) : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(statusIcon(s), color: statusColor(context, s), size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s?.label ??
                  (repo.isCheckpointDue(primary, primaryDate)
                      ? '已到时点，等待行情数据'
                      : '进行中，${formatDue(TradeDate.format(primaryDate))}${primary.atOpen ? '开盘' : '收盘'}后判定'),
              style: theme.textTheme.titleMedium?.copyWith(color: statusColor(context, s)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 24, runSpacing: 8, children: [
          Metric(label: '基准价', value: formatPrice(p.basePrice)),
          Metric(label: primary.atOpen ? '时点开盘' : '时点收盘', value: formatPrice(r?.actualClose)),
          Metric(
            label: '涨跌幅',
            value: formatPct(r?.changePct),
            color: r?.changePct == null ? null : mc.of(r!.changePct!),
          ),
          if (p.direction != 'range') ...[
            Metric(label: '最大有利', value: formatPct(r?.mfe)),
            Metric(label: '最大不利', value: formatPct(r?.mae)),
          ],
        ]),
        if (p.basePrice == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('记录时未取到行情，基准价将按前一交易日收盘估算',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
          ),
        const Divider(height: 24),
        Text('各时点验证', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        _CheckpointTable(view: view),
        const Divider(height: 24),
        Text('手动判定主结论（覆盖自动结果）', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(spacing: 6, children: [
          for (final st in [VerifyStatus.correct, VerifyStatus.partial, VerifyStatus.wrong])
            ChoiceChip(
              label: Text(st.label),
              selected: (r?.isManual ?? false) && s == st,
              onSelected: (_) => repo.setManualStatus(p.id, primary, st),
            ),
          if (r?.isManual ?? false)
            ActionChip(
              avatar: const Icon(Icons.restart_alt, size: 16),
              label: const Text('恢复自动判定'),
              onPressed: () async {
                await repo.resetResult(p.id, primary);
                await ref.read(verificationServiceProvider).runDue();
              },
            ),
        ]),
      ]),
    );
  }
}

/// 各时点结果表：时点 / 日期 / 价格 / 涨跌幅 / 结果，主时点加粗。
class _CheckpointTable extends StatelessWidget {
  const _CheckpointTable({required this.view});
  final PredictionView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final small = theme.textTheme.bodySmall;
    return Column(children: [
      for (final MapEntry(key: cp, value: date) in view.plan.points.entries)
        () {
          final r = view.results[cp];
          final s = view.statusAt(cp);
          final isPrimary = cp == view.primary;
          final style = isPrimary ? small?.copyWith(fontWeight: FontWeight.w700) : small;
          return Padding(
            key: Key('cp-${cp.code}'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 72, child: Text(cp.label + (isPrimary ? ' ★' : ''), style: style)),
              SizedBox(width: 48, child: Text(mmdd(TradeDate.format(date)), style: small)),
              Expanded(child: Text(formatPrice(r?.actualClose), style: small)),
              SizedBox(
                width: 64,
                child: Text(formatPct(r?.changePct),
                    textAlign: TextAlign.right,
                    style: small?.copyWith(color: r?.changePct == null ? null : mc.of(r!.changePct!))),
              ),
              const SizedBox(width: 10),
              Icon(statusIcon(s), size: 16, color: statusColor(context, s)),
              const SizedBox(width: 4),
              SizedBox(
                width: 52,
                child: Text(s?.label ?? '待定',
                    style: small?.copyWith(color: statusColor(context, s)), overflow: TextOverflow.ellipsis),
              ),
            ]),
          );
        }(),
    ]);
  }
}

class _ParamsCard extends ConsumerStatefulWidget {
  const _ParamsCard({required this.prediction});
  final Prediction prediction;

  @override
  ConsumerState<_ParamsCard> createState() => _ParamsCardState();
}

class _ParamsCardState extends ConsumerState<_ParamsCard> {
  late final _target = TextEditingController(text: _fmt(widget.prediction.targetPrice));
  late final _stop = TextEditingController(text: _fmt(widget.prediction.stopPrice));
  late final _threshold = TextEditingController(text: _fmt(widget.prediction.thresholdPct));
  late var _confidence = widget.prediction.confidence;

  static String _fmt(double? v) => v == null ? '' : v.toString();

  @override
  void dispose() {
    _target.dispose();
    _stop.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    double? parse(TextEditingController c) => double.tryParse(c.text.trim());
    await ref.read(predictionRepositoryProvider).updateParams(
          widget.prediction.id,
          targetPrice: Value(parse(_target)),
          stopPrice: Value(parse(_stop)),
          thresholdPct: Value(parse(_threshold)),
          confidence: _confidence,
        );
    await ref.read(verificationServiceProvider).runDue();
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存判断参数')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cfg = ref.watch(thresholdConfigProvider).value;
    final p = widget.prediction;
    final defaultTh = cfg?.resolve(Codes.guessType(p.targetCode), p.horizonType);
    InputDecoration deco(String label, {String? hint}) =>
        InputDecoration(labelText: label, hintText: hint, isDense: true, border: const OutlineInputBorder());

    return BoardCard(
      title: '判断参数',
      trailing: TextButton(onPressed: _save, child: const Text('保存')),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: deco('目标价', hint: '可选'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _stop,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: deco('止损 / 失效价', hint: '可选'),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _threshold,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: deco('震荡阈值 ±%',
              hint: defaultTh == null ? '默认' : '默认 ${defaultTh.toStringAsFixed(2)}（在 复盘 → 阈值 中调整）'),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Text('信心度', style: theme.textTheme.labelLarge),
          const SizedBox(width: 8),
          for (var i = 1; i <= 5; i++)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(i <= _confidence ? Icons.star : Icons.star_border,
                  color: i <= _confidence ? Colors.amber.shade700 : null),
              onPressed: () => setState(() => _confidence = i),
            ),
        ]),
        Text('设置目标价 / 止损价后，按观察期内先触及哪个判定；到期前修改会被标记。',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
      ]),
    );
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  const _ReviewCard({required this.view});
  final PredictionView view;

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  late final _content = TextEditingController(text: widget.view.review?.content ?? '');
  late final _reasons = {...?widget.view.review?.reasons};

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(predictionRepositoryProvider)
        .saveReview(widget.view.prediction.id, content: _content.text.trim(), reasons: _reasons.toList());
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('复盘已保存')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BoardCard(
      title: widget.view.reviewed ? '复盘笔记 ✓' : '复盘笔记',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (final r in reviewReasons)
            FilterChip(
              label: Text(r),
              selected: _reasons.contains(r),
              visualDensity: VisualDensity.compact,
              onSelected: (on) => setState(() => on ? _reasons.add(r) : _reasons.remove(r)),
            ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _content,
          minLines: 2,
          maxLines: 6,
          decoration: const InputDecoration(
              hintText: '这次判断对 / 错在哪里？下次怎么做？', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            key: const Key('review-save'),
            onPressed: _save,
            child: Text(widget.view.reviewed ? '更新复盘' : '完成复盘'),
          ),
        ),
      ]),
    );
  }
}


