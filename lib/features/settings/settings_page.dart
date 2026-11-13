import 'package:material_ui/material_ui.dart';

import 'quick_phrases_page.dart';

/// 设置页。M1 先提供常用短语管理，其余项随里程碑补充（spec §6）。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(children: [
        const _Section('日记'),
        ListTile(
          leading: const Icon(Icons.short_text),
          title: const Text('常用短语'),
          subtitle: const Text('快捷输入栏中一键插入'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const QuickPhrasesPage())),
        ),
        const _Section('数据与 AI'),
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: const Text('数据源（Tushare Pro 等）'),
          subtitle: Text('M2 开放', style: muted),
          enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome_outlined),
          title: const Text('AI 模型（默认 DeepSeek）'),
          subtitle: Text('M4 开放', style: muted),
          enabled: false,
        ),
        const _Section('关于'),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('免责声明'),
          subtitle: Text('本应用仅用于个人交易记录与复盘，AI 分析与建议仅供参考，不构成任何投资建议。'),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
