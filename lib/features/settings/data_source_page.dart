import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/time/market_clock.dart';
import '../../data/market/market_router.dart';
import '../../data/market/sources.dart';
import '../../data/market/tushare_source.dart';

/// 数据源设置：Tushare token、刷新频率、基础数据同步、各能力优先级、健康状态（spec 5.3）。
class DataSourcePage extends ConsumerStatefulWidget {
  const DataSourcePage({super.key});

  @override
  ConsumerState<DataSourcePage> createState() => _DataSourcePageState();
}

class _DataSourcePageState extends ConsumerState<DataSourcePage> {
  var _syncing = false;
  String? _syncMessage;
  String? _lastSync;
  int? _instrumentCount;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final last = await ref.read(settingsStoreProvider).lastBaseSyncDate();
    final n = await ref.read(instrumentRepositoryProvider).count();
    if (mounted) {
      setState(() {
        _lastSync = last;
        _instrumentCount = n;
      });
    }
  }

  Future<void> _sync() async {
    setState(() {
      _syncing = true;
      _syncMessage = null;
    });
    final r = await runBaseDataSync(ref, force: true);
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _syncMessage = r.ok
          ? '同步完成：交易日历 ${r.calendarDays} 天，标的 ${r.instruments} 个'
          : '部分失败：${r.errors.join('；')}';
    });
    _loadStats();
  }

  Future<void> _editToken() async {
    final config = ref.read(appConfigProvider);
    final controller = TextEditingController(
        text: config.tokenFromEnv ? '' : (config.tushareToken ?? ''));
    String? testResult;
    final saved = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tushare Pro token'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '粘贴 token',
                helperText: '保存在本机系统安全存储中',
              ),
            ),
            if (testResult != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text(testResult!)),
          ]),
          actions: [
            TextButton(
              onPressed: () async {
                setDialogState(() => testResult = '测试中…');
                try {
                  final today = TradeDate.format(MarketClock.marketDate(DateTime.now()));
                  final days = await TushareSource(controller.text.trim())
                      .calendar(from: '${today.substring(0, 4)}0101', to: today);
                  setDialogState(() => testResult = '✅ 连接成功（今年已过 ${days.length} 个日历日）');
                } catch (e) {
                  setDialogState(() => testResult = '❌ $e');
                }
              },
              child: const Text('测试'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('保存')),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved != null) {
      await ref.read(appConfigProvider.notifier).setTushareToken(saved);
      if (saved.trim().isNotEmpty) _sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final router = ref.watch(marketRouterProvider);
    final theme = Theme.of(context);
    final hasToken = config.tushareToken?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('数据源')),
      body: ListView(children: [
        ListTile(
          leading: const Icon(Icons.key_outlined),
          title: const Text('Tushare Pro token'),
          subtitle: Text(!hasToken
              ? '未设置（代码表、交易日历、日 K 将降级到免费源）'
              : config.tokenFromEnv
                  ? '使用项目 .env 中的 token（默认）'
                  : '已设置'),
          trailing: const Icon(Icons.edit_outlined),
          onTap: _editToken,
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('盘中刷新间隔'),
          subtitle: const Text('指数 / 自选报价；宽度与板块固定 30 秒'),
          trailing: DropdownButton<int>(
            value: config.refreshSeconds,
            underline: const SizedBox(),
            items: [
              for (final s in const [3, 5, 10, 15, 30, 60])
                DropdownMenuItem(value: s, child: Text('$s 秒')),
            ],
            onChanged: (v) => ref.read(appConfigProvider.notifier).setRefreshSeconds(v!),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('同步基础数据'),
          subtitle: Text(_syncMessage ??
              '交易日历 + 代码表，每天自动一次。上次：${_lastSync ?? '从未'}，标的 ${_instrumentCount ?? '…'} 个'),
          trailing: _syncing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right),
          onTap: _syncing ? null : _sync,
        ),
        const Divider(),
        _header(context, '数据源状态'),
        for (final s in router.sources) _HealthTile(source: s, health: router.healthOf(s.id)),
        const Divider(),
        Row(children: [
          Expanded(child: _header(context, '优先级（点击调整顺序）')),
          TextButton(
            onPressed: () => ref.read(appConfigProvider.notifier).resetPriority(),
            child: const Text('恢复默认'),
          ),
        ]),
        for (final c in Capability.values)
          if (router.orderFor(c).length > 1)
            ListTile(
              dense: true,
              title: Text(c.label),
              subtitle: Text(router.orderFor(c).map((s) => s.id.label).join(' → ')),
              trailing: const Icon(Icons.swap_vert),
              onTap: () => _editPriority(c, router),
            ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '免费源（东方财富 / 腾讯）为非官方网页接口，可能变更或被临时限流；失败时自动切换到下一个源，并对连续失败的源退避重试。',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
      ]),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );

  Future<void> _editPriority(Capability c, MarketRouter router) async {
    var order = router.orderFor(c).map((s) => s.id).toList();
    final result = await showDialog<List<SourceId>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${c.label} 优先级'),
          content: SizedBox(
            width: 300,
            height: 64.0 * order.length,
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              onReorderItem: (from, to) =>
                  setDialogState(() => order.insert(to, order.removeAt(from))),
              children: [
                for (final (i, s) in order.indexed)
                  ListTile(
                    key: ValueKey(s),
                    leading: Text('${i + 1}'),
                    title: Text(s.label),
                    trailing: ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, order), child: const Text('保存')),
          ],
        ),
      ),
    );
    if (result != null) await ref.read(appConfigProvider.notifier).setPriority(c, result);
  }
}

class _HealthTile extends StatelessWidget {
  const _HealthTile({required this.source, required this.health});
  final MarketSource source;
  final SourceHealth health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cooling = health.cooldownUntil?.isAfter(DateTime.now()) ?? false;
    final (icon, color, text) = !source.isAvailable
        ? (Icons.block, theme.colorScheme.outline, '未启用（缺少 token）')
        : health.successes + health.failures == 0
            ? (Icons.circle_outlined, theme.colorScheme.outline, '尚未使用')
            : health.healthy
                ? (Icons.check_circle, Colors.green, '正常 · ${health.lastLatency?.inMilliseconds ?? '-'}ms')
                : (Icons.error, theme.colorScheme.error,
                    '${cooling ? '退避中' : '失败'}：${health.lastError ?? ''}');
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(source.id.label),
      subtitle: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text('✓${health.successes} ✗${health.failures}', style: theme.textTheme.labelSmall),
    );
  }
}


