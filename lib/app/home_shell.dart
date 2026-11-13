import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/journal/journal_page.dart';
import '../features/market/ai_analysis_widgets.dart';
import '../features/market/market_page.dart';
import '../features/portfolio/portfolio_page.dart';
import '../features/review/review_page.dart';
import '../features/review/review_providers.dart';
import '../features/settings/settings_page.dart';
import 'providers.dart';

/// 主框架：底部 5 个 Tab + 全局 Agent 入口（spec §6）。
///
/// 日记页底部有快捷输入栏，因此 Agent 入口放在输入栏内，其余页面用悬浮按钮。
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _tabs = [
  _Tab('大盘', Icons.show_chart_outlined, Icons.show_chart),
  _Tab('日记', Icons.edit_note_outlined, Icons.edit_note),
  _Tab('复盘', Icons.fact_check_outlined, Icons.fact_check),
  _Tab('持仓', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
  _Tab('设置', Icons.settings_outlined, Icons.settings),
];

const _journalIndex = 1;

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = _journalIndex;
  Timer? _verifyTimer;
  Timer? _analysisTimer;
  Timer? _syncTimer;
  late final AppLifecycleListener _lifecycle;

  @override
  void dispose() {
    _verifyTimer?.cancel();
    _analysisTimer?.cancel();
    _syncTimer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 应用打开期间每 10 分钟检查一次到期判断（启动时复盘页也会检查一次）
    _verifyTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      try {
        await ref.read(verificationServiceProvider).runDue();
      } catch (_) {
        // 网络不可用时下次再试
      }
    });
    // 云同步：每 3 分钟、回到前台时
    _syncTimer = Timer.periodic(const Duration(minutes: 3), (_) => ref.read(syncProvider.notifier).syncNow());
    _lifecycle = AppLifecycleListener(onResume: () => ref.read(syncProvider.notifier).syncNow());
    // 定时 AI 分析：交易日 9:35 / 11:35 / 15:05（应用打开时；后台定时在 M7）
    _analysisTimer = Timer.periodic(const Duration(minutes: 1), (_) => _scheduledAnalysis());
    // 启动后在后台同步交易日历与代码表（每天一次）
    Future.microtask(() async {
      try {
        await ref.read(journalServiceProvider).backfillPredictions();
      } catch (_) {}
      try {
        await runBaseDataSync(ref);
      } catch (_) {
        // 离线或源不可用：下次启动再试
      }
      await ref.read(syncProvider.notifier).syncNow();
      await _scheduledAnalysis();
    });
  }

  Future<void> _scheduledAnalysis() async {
    if (ref.read(analysisRunningProvider)) return;
    final svc = ref.read(marketAnalysisServiceProvider);
    if (svc.dueSlot() == null) return;
    ref.read(analysisRunningProvider.notifier).set(true);
    try {
      await svc.runScheduledIfDue();
    } catch (_) {
      // 失败不阻塞；该时点不再重试
    } finally {
      if (mounted) ref.read(analysisRunningProvider.notifier).set(false);
    }
  }

  /// 复盘 Tab 显示待复盘数量。
  Widget _badged(int index, Widget icon) {
    if (index != 2) return icon;
    final n = ref.watch(pendingReviewCountProvider);
    return n == 0 ? icon : Badge(label: Text('$n'), child: icon);
  }

  void _openAgent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('全局 Agent 助手将在 M6 实现')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // 大盘页仅在可见时构建，离开即停止行情轮询
          _index == 0 ? const MarketPage() : const SizedBox.shrink(),
          JournalPage(onOpenAgent: _openAgent),
          const ReviewPage(),
          const PortfolioPage(),
          const SettingsPage(),
        ],
      ),
      floatingActionButton: _index == _journalIndex
          ? null
          : FloatingActionButton(
              tooltip: 'AI 助手',
              onPressed: _openAgent,
              child: const Icon(Icons.auto_awesome),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final (i, t) in _tabs.indexed)
            NavigationDestination(
              icon: _badged(i, Icon(t.icon)),
              selectedIcon: _badged(i, Icon(t.selectedIcon)),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
