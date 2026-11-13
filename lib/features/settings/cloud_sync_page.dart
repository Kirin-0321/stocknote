import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../data/sync/cloud_sync.dart';

/// 账户与云同步（spec 5.6 / M7）：注册登录后自动同步，退出后本机数据保留。
class CloudSyncPage extends ConsumerStatefulWidget {
  const CloudSyncPage({super.key});

  @override
  ConsumerState<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends ConsumerState<CloudSyncPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _server = TextEditingController();
  final _cert = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _showServer = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final sync = ref.read(cloudSyncProvider);
    sync.server().then((v) {
      if (!mounted) return;
      _server.text = v;
      setState(() => _showServer = v.isEmpty);
    });
    sync.certSha256().then((v) => _cert.text = v);
  }

  @override
  void dispose() {
    _password.clear();
    super.dispose();
  }

  Future<void> _submit() async {
    final sync = ref.read(cloudSyncProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_server.text.trim().isEmpty) throw const SyncException('请填写同步服务器地址');
      await sync.setServer(_server.text, cert: _cert.text);
      // 本机已有数据且上次同步的不是这个账户：确认合并
      final hasData = await sync.hasLocalData();
      final previous = await sync.syncedUserId();
      if (hasData && previous == null && mounted) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('上传本机数据？'),
            content: const Text('本机已有日记、交易等数据。登录后这些数据会上传并合并到该账户，之后在其他设备登录同一账户即可看到。'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('合并并同步')),
            ],
          ),
        );
        if (ok != true) return;
      }
      final email = _email.text.trim();
      final pw = _password.text;
      final u = _register
          ? await sync.register(email, pw, displayName: _name.text.trim().isEmpty ? null : _name.text.trim())
          : await sync.login(email, pw);
      _password.clear();
      await ref.read(syncProvider.notifier).signedIn(u);
    } on SyncException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _serverFields() => Column(children: [
        TextField(
          key: const Key('sync-server'),
          controller: _server,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: '服务器地址', hintText: 'https://example.com:8443'),
        ),
        TextField(
          controller: _cert,
          decoration: const InputDecoration(
            labelText: '证书指纹 SHA-256（自签证书时填写）',
            helperText: '服务器使用正规证书时留空',
          ),
        ),
        const SizedBox(height: 8),
      ]);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(syncProvider);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);

    if (s.user != null) {
      final u = s.user!;
      return Scaffold(
        appBar: AppBar(title: const Text('账户与云同步')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(u.displayName ?? u.email),
            subtitle: Text(u.displayName == null ? '已登录' : u.email),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('云同步已开启'),
            subtitle: Text(s.syncing
                ? '正在同步…'
                : s.lastSyncAt == null
                    ? '尚未同步'
                    : '上次同步 ${formatDateTime(s.lastSyncAt!.millisecondsSinceEpoch)}'
                        '${s.lastResult == null ? '' : '（上传 ${s.lastResult!.$1} / 下载 ${s.lastResult!.$2} 条）'}'),
            trailing: s.syncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : FilledButton.tonal(
                    key: const Key('sync-now'),
                    onPressed: () => ref.read(syncProvider.notifier).syncNow(),
                    child: const Text('立即同步'),
                  ),
          ),
          if (s.error != null) Text('同步失败：${s.error}', style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          Text('日记、判断与验证、AI 分析、交易与账户等数据会自动同步（打开应用时、回到前台时及每 3 分钟）。'
              'API Key、Tushare token 等密钥不会上传。', style: muted),
          const SizedBox(height: 24),
          OutlinedButton(
            key: const Key('sync-logout'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  content: const Text('退出登录后停止同步，本机数据保留。'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('退出登录')),
                  ],
                ),
              );
              if (ok == true) await ref.read(syncProvider.notifier).logout();
            },
            child: const Text('退出登录'),
          ),
        ]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('账户与云同步')),
      body: AutofillGroup(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: false, label: Text('登录')), ButtonSegment(value: true, label: Text('注册'))],
            selected: {_register},
            onSelectionChanged: (v) => setState(() => _register = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('sync-email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: '邮箱'),
          ),
          TextField(
            key: const Key('sync-password'),
            controller: _password,
            obscureText: true,
            autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
            decoration: InputDecoration(labelText: '密码', helperText: _register ? '至少 8 位' : null),
            onSubmitted: (_) => _submit(),
          ),
          if (_register)
            TextField(controller: _name, decoration: const InputDecoration(labelText: '昵称（可选）')),
          const SizedBox(height: 8),
          if (_showServer) _serverFields() else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: () => setState(() => _showServer = true), child: const Text('服务器设置')),
            ),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ),
          FilledButton(
            key: const Key('sync-submit'),
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? '请稍候…' : (_register ? '注册并开启同步' : '登录并开启同步')),
          ),
          const SizedBox(height: 16),
          Text('不登录也可以正常使用，数据只保存在本机。登录后数据会加密传输到同步服务器，可在多台设备间同步。', style: muted),
        ]),
      ),
    );
  }
}
