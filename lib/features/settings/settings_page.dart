import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';

import 'ai_settings_page.dart';
import 'cloud_sync_page.dart';
import 'data_source_page.dart';
import 'quick_phrases_page.dart';
import 'threshold_page.dart';

/// 设置页。M1 先提供常用短语管理，其余项随里程碑补充（spec §6）。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(children: [
        const _Section('账户'),
        const _SyncTile(),
        const _Section('日记'),
        ListTile(
          leading: const Icon(Icons.short_text),
          title: const Text('常用短语'),
          subtitle: const Text('快捷输入栏中一键插入'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const QuickPhrasesPage())),
        ),
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('判定阈值'),
          subtitle: const Text('判断验证时"震荡"区间，按类型 / 周期设置'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ThresholdPage())),
        ),
        const _Section('数据与 AI'),
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: const Text('数据源'),
          subtitle: const Text('Tushare token、刷新频率、源优先级与状态'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const DataSourcePage())),
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome_outlined),
          title: const Text('AI 模型'),
          subtitle: const Text('默认 DeepSeek，各任务可选模型与思考强度，定时分析'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AiSettingsPage())),
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

class _SyncTile extends ConsumerWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncProvider);
    return ListTile(
      key: const Key('settings-sync'),
      leading: Icon(s.user == null ? Icons.cloud_off_outlined : Icons.cloud_done_outlined),
      title: Text(s.user == null ? '登录 / 注册' : (s.user!.displayName ?? s.user!.email)),
      subtitle: Text(s.user == null
          ? '登录后开启云同步，多设备共享数据'
          : s.error != null
              ? '同步失败：${s.error}'
              : s.syncing
                  ? '正在同步…'
                  : '云同步已开启'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CloudSyncPage())),
    );
  }
}
