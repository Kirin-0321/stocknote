import 'package:material_ui/material_ui.dart';

/// 主框架：底部 5 个 Tab + 全局 Agent 入口（spec §6）。
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon, this.milestone);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String milestone;
}

const _tabs = [
  _Tab('大盘', Icons.show_chart_outlined, Icons.show_chart, 'M2'),
  _Tab('日记', Icons.edit_note_outlined, Icons.edit_note, 'M1'),
  _Tab('复盘', Icons.fact_check_outlined, Icons.fact_check, 'M3'),
  _Tab('持仓', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'M5'),
  _Tab('设置', Icons.settings_outlined, Icons.settings, 'M1'),
];

class _HomeShellState extends State<HomeShell> {
  int _index = 1; // 默认打开日记

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_index];
    return Scaffold(
      appBar: AppBar(title: Text(tab.label)),
      body: _PlaceholderPage(tab: tab),
      floatingActionButton: FloatingActionButton(
        tooltip: 'AI 助手',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('全局 Agent 助手将在 M6 实现')),
        ),
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
  const _PlaceholderPage({required this.tab});
  final _Tab tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.selectedIcon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(tab.label, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${tab.milestone} 开发中', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
