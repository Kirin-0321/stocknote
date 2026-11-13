import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/journal/journal_page.dart';
import '../features/market/market_page.dart';
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

  @override
  void initState() {
    super.initState();
    // 启动后在后台同步交易日历与代码表（每天一次）
    Future.microtask(() async {
      try {
        await runBaseDataSync(ref);
      } catch (_) {
        // 离线或源不可用：下次启动再试
      }
    });
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
          const _PlaceholderPage(title: '复盘', icon: Icons.fact_check, milestone: 'M3'),
          const _PlaceholderPage(
              title: '持仓', icon: Icons.account_balance_wallet, milestone: 'M5'),
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
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.icon, required this.milestone});
  final String title;
  final IconData icon;
  final String milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('$milestone 开发中', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
