import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/time/market_clock.dart';
import '../../data/backup/backup_service.dart';

final backupServiceProvider = Provider((ref) => BackupService(ref.watch(databaseProvider), now: ref.watch(clockProvider)));

/// 数据备份：导出 / 导入 JSON，导出 Markdown。
class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _busy = false;

  String get _stamp => TradeDate.format(MarketClock.marketDate(ref.read(clockProvider)()));

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _run(Future<void> Function() job) async {
    setState(() => _busy = true);
    try {
      await job();
    } catch (e) {
      if (mounted) _toast('操作失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportJson() => _run(() async {
        final bytes = await ref.read(backupServiceProvider).exportBytes();
        final uri = await FilePicker.saveFile(
          fileName: 'stocknote-backup-$_stamp.json',
          bytes: Uint8List.fromList(bytes),
          mimeType: 'application/json',
        );
        if (uri != null && mounted) _toast('已导出备份（${(bytes.length / 1024).toStringAsFixed(0)} KB）');
      });

  Future<void> _exportMarkdown() => _run(() async {
        final md = await ref.read(backupServiceProvider).exportMarkdown();
        final uri = await FilePicker.saveFile(
          fileName: 'stocknote-journal-$_stamp.md',
          bytes: Uint8List.fromList(utf8.encode(md)),
          mimeType: 'text/markdown',
        );
        if (uri != null && mounted) _toast('已导出日记 Markdown');
      });

  Future<void> _import() => _run(() async {
        final f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
        if (f == null || !mounted) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('导入备份'),
            content: Text('将把"${f.name}"中的数据合并到本机：同一条记录保留较新的版本，本机已有的其他数据不会被删除。'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('导入')),
            ],
          ),
        );
        if (ok != true) return;
        final r = await ref.read(backupServiceProvider).importBytes(await f.readAsBytes());
        if (mounted) _toast('已导入 ${r.applied} 条，跳过 ${r.skipped} 条（本机已是相同或更新版本）');
      });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(title: const Text('数据备份')),
      body: ListView(children: [
        if (_busy) const LinearProgressIndicator(),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('导出备份'),
          subtitle: const Text('日记、判断、AI 分析、交易、助手对话与记忆等全部数据（JSON）'),
          onTap: _busy ? null : _exportJson,
        ),
        ListTile(
          leading: const Icon(Icons.upload_outlined),
          title: const Text('导入备份'),
          subtitle: const Text('合并到本机，保留较新的版本，可重复导入'),
          onTap: _busy ? null : _import,
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('导出日记为 Markdown'),
          subtitle: const Text('按日期整理，附判断验证结果，便于阅读或存档'),
          onTap: _busy ? null : _exportMarkdown,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('备份文件不包含 API Key、Tushare token 和登录信息。登录云同步后数据也会自动保存在服务器上。', style: muted),
        ),
      ]),
    );
  }
}
