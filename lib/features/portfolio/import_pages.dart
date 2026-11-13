import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../data/ai/llm.dart';
import '../../data/db/app_database.dart';
import '../../data/import/import_service.dart';
import '../../data/import/table_import.dart';
import '../../domain/trade/trade_rules.dart';
import '../market/instrument_search_page.dart';
import 'portfolio_providers.dart';

/// 导入用的账户：当前选中的，否则唯一 / 默认账户；多个账户时让用户选。
Future<Account?> _importAccount(BuildContext context, WidgetRef ref) async {
  final repo = ref.read(accountRepositoryProvider);
  await repo.ensureDefault();
  final list = await repo.all();
  final sel = ref.read(selectedAccountProvider);
  final chosen = list.where((a) => a.id == sel).firstOrNull;
  if (chosen != null) return chosen;
  if (list.length == 1 || !context.mounted) return list.first;
  return showDialog<Account>(
    context: context,
    builder: (c) => SimpleDialog(
      title: const Text('导入到哪个账户'),
      children: [for (final a in list) SimpleDialogOption(onPressed: () => Navigator.pop(c, a), child: Text(a.name))],
    ),
  );
}

void _toast(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

/// 选择交割单文件并打开预览。
Future<void> startTableImport(BuildContext context, WidgetRef ref) async {
  final f = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['csv', 'txt', 'xls', 'xlsx'],
  );
  if (f == null || !context.mounted) return;
  final bytes = await f.readAsBytes();
  if (!context.mounted) return;
  final account = await _importAccount(context, ref);
  if (account == null || !context.mounted) return;
  try {
    final preview = await ref.read(tradeImportServiceProvider).previewTable(bytes, f.name, account);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TableImportPage(preview: preview, account: account)));
  } on UnsupportedFileException catch (e) {
    if (context.mounted) _toast(context, e.message);
  } catch (e) {
    if (context.mounted) _toast(context, '读取失败：$e');
  }
}

/// 选择券商截图并识别。
Future<void> startImageImport(BuildContext context, WidgetRef ref) async {
  final f = await FilePicker.pickFile(type: FileType.image);
  if (f == null || !context.mounted) return;
  final bytes = await f.readAsBytes();
  if (!context.mounted) return;
  final account = await _importAccount(context, ref);
  if (account == null || !context.mounted) return;
  final ext = f.name.split('.').last.toLowerCase();
  final mime = switch (ext) { 'jpg' || 'jpeg' => 'image/jpeg', 'webp' => 'image/webp', _ => 'image/png' };
  final nav = Navigator.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Expanded(child: Text('正在识别截图…'))]),
    ),
  );
  try {
    final preview = await ref.read(tradeImportServiceProvider).previewImage(bytes, mime, account);
    nav.pop();
    if (!context.mounted) return;
    if (preview.rows.isEmpty) {
      _toast(context, '没有识别出证券${preview.rawText == null ? '' : '：${preview.rawText}'}');
      return;
    }
    await nav.push(MaterialPageRoute(builder: (_) => ImageImportPage(preview: preview, account: account)));
  } on LlmException catch (e) {
    nav.pop();
    if (context.mounted) _toast(context, '识别失败：$e');
  } catch (e) {
    nav.pop();
    if (context.mounted) _toast(context, '识别失败：$e');
  }
}

/// 预览行列表（表格与截图共用）。
class ImportRowsView extends ConsumerStatefulWidget {
  const ImportRowsView({super.key, required this.rows, this.editableCode = false, this.onChanged});
  final List<ImportRow> rows;
  final bool editableCode;
  final VoidCallback? onChanged;

  @override
  ConsumerState<ImportRowsView> createState() => _ImportRowsViewState();
}

class _ImportRowsViewState extends ConsumerState<ImportRowsView> {
  Map<String, String> _names = {};

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  @override
  void didUpdateWidget(covariant ImportRowsView old) {
    super.didUpdateWidget(old);
    if (old.rows != widget.rows) _loadNames();
  }

  Future<void> _loadNames() async {
    final codes = {for (final r in widget.rows) ?r.draft?.code};
    final m = await ref.read(instrumentRepositoryProvider).getMany(codes);
    if (mounted) setState(() => _names = {for (final e in m.entries) e.key: e.value.name});
  }

  Future<void> _changeCode(ImportRow r) async {
    final i = await Navigator.of(context).push<Instrument>(
        MaterialPageRoute(builder: (_) => const InstrumentSearchPage(pick: true)));
    if (i == null) return;
    setState(() {
      r.draft!.code = i.code;
      _names[i.code] = i.name;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline);
    final ok = widget.rows.where((r) => r.draft != null).toList();
    final bad = widget.rows.where((r) => r.error != null).toList();
    final skipped = widget.rows.where((r) => r.skipped != null).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final r in ok)
        CheckboxListTile(
          dense: true,
          value: r.selected,
          onChanged: (v) {
            setState(() => r.selected = v ?? false);
            widget.onChanged?.call();
          },
          title: Row(children: [
            Flexible(
              child: Text(
                '${_names[r.draft!.code] ?? r.draft!.name ?? r.draft!.code}  ${r.draft!.side.label}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (r.duplicate) ...[
              const SizedBox(width: 6),
              Text('已存在', style: muted?.copyWith(color: theme.colorScheme.error)),
            ],
          ]),
          subtitle: Text(
            [
              r.draft!.code,
              if (r.draft!.side != TradeSide.init) formatDateTime(r.draft!.ts),
              if (r.draft!.side == TradeSide.dividend)
                '金额 ${formatMoney(r.draft!.amount)}'
              else
                '${formatPrice(r.draft!.price)} × ${r.draft!.qty}',
              if (r.draft!.fees.total > 0) '费用 ${formatMoney(r.draft!.fees.total)}',
              if (r.draft!.name != null && _names[r.draft!.code] != null && r.draft!.name != _names[r.draft!.code])
                '原名 ${r.draft!.name}',
            ].join(' · '),
          ),
          secondary: widget.editableCode
              ? IconButton(tooltip: '更换标的', icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _changeCode(r))
              : null,
        ),
      if (bad.isNotEmpty)
        ExpansionTile(
          initiallyExpanded: ok.isEmpty,
          title: Text('无法解析 ${bad.length} 行', style: TextStyle(color: theme.colorScheme.error)),
          children: [
            for (final r in bad)
              ListTile(dense: true, title: Text(r.error!), subtitle: Text(r.raw.where((c) => c.isNotEmpty).join(' | '))),
          ],
        ),
      if (skipped.isNotEmpty)
        ExpansionTile(
          title: Text('跳过 ${skipped.length} 行（非交易业务）', style: muted),
          children: [
            for (final r in skipped)
              ListTile(dense: true, title: Text(r.skipped!), subtitle: Text(r.raw.where((c) => c.isNotEmpty).join(' | '))),
          ],
        ),
    ]);
  }
}

/// 表格导入预览：列映射（可让 AI 推荐）+ 逐行确认。
class TableImportPage extends ConsumerStatefulWidget {
  const TableImportPage({super.key, required this.preview, required this.account});
  final TablePreview preview;
  final Account account;

  @override
  ConsumerState<TableImportPage> createState() => _TableImportPageState();
}

class _TableImportPageState extends ConsumerState<TableImportPage> {
  late Map<ImportField, int> _mapping = {...widget.preview.layout.mapping};
  late bool _showMapping = !widget.preview.layout.complete;
  bool _busy = false;

  TablePreview get p => widget.preview;

  Future<void> _apply() async {
    setState(() => _busy = true);
    p.layout = p.layout.withMapping(_mapping);
    if (p.layout.complete) {
      await ref.read(tradeImportServiceProvider).reparse(p, widget.account);
      _showMapping = false;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _aiSuggest() async {
    setState(() => _busy = true);
    try {
      final m = await ref.read(tradeImportServiceProvider).suggestMapping(p);
      setState(() => _mapping = {..._mapping, ...m});
    } catch (e) {
      if (mounted) _toast(context, 'AI 推荐失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    setState(() => _busy = true);
    await ref.read(tradeImportServiceProvider).commitTable(p);
    if (!mounted) return;
    final n = p.parsed.where((r) => r.selected).length;
    Navigator.pop(context);
    _toast(context, '已导入 $n 笔交易');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = p.parsed.where((r) => r.selected && r.draft != null).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          if (!_showMapping) TextButton(onPressed: () => setState(() => _showMapping = true), child: const Text('列映射')),
        ],
      ),
      bottomNavigationBar: _showMapping
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  key: const Key('import-commit'),
                  onPressed: selected == 0 || _busy ? null : _commit,
                  child: Text('导入 $selected 笔到「${widget.account.name}」'),
                ),
              ),
            ),
      body: ListView(children: [
        if (_busy) const LinearProgressIndicator(),
        if (p.mappingName != null && !_showMapping)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('已套用保存的列映射', style: theme.textTheme.labelSmall),
          ),
        if (_showMapping) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              p.layout.complete ? '确认各字段对应的列' : '未能自动识别全部字段，请指定各字段对应的列（日期、价格、数量、代码或名称必填）',
              style: theme.textTheme.bodySmall,
            ),
          ),
          for (final f in ImportField.values)
            ListTile(
              dense: true,
              title: Text(f.label +
                  (ImportField.required.contains(f) || f == ImportField.secCode ? ' *' : '')),
              trailing: DropdownButton<int>(
                value: _mapping[f] ?? -1,
                items: [
                  const DropdownMenuItem(value: -1, child: Text('（无）')),
                  for (final (i, h) in p.layout.headers.indexed)
                    DropdownMenuItem(value: i, child: Text(h.isEmpty ? '第 ${i + 1} 列' : h)),
                ],
                onChanged: (v) => setState(() => v == null || v < 0 ? _mapping.remove(f) : _mapping[f] = v),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _aiSuggest,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('AI 推荐映射'),
              ),
              const Spacer(),
              FilledButton(onPressed: _busy ? null : _apply, child: const Text('应用')),
            ]),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '共 ${p.parsed.where((r) => r.draft != null).length} 笔，'
              '其中 ${p.parsed.where((r) => r.duplicate).length} 笔与已有交易重复（默认不导入）',
              style: theme.textTheme.bodySmall,
            ),
          ),
          ImportRowsView(rows: p.parsed, onChanged: () => setState(() {})),
        ],
      ]),
    );
  }
}

/// 截图识别预览。
class ImageImportPage extends ConsumerStatefulWidget {
  const ImageImportPage({super.key, required this.preview, required this.account});
  final ImagePreview preview;
  final Account account;

  @override
  ConsumerState<ImageImportPage> createState() => _ImageImportPageState();
}

class _ImageImportPageState extends ConsumerState<ImageImportPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.preview;
    final selected = p.rows.where((r) => r.selected && r.draft != null).length;
    final positions = p.kind == 'positions';
    return Scaffold(
      appBar: AppBar(title: Text(positions ? '识别结果 · 持仓' : '识别结果 · 成交')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            key: const Key('image-commit'),
            onPressed: selected == 0 || _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await ref.read(tradeImportServiceProvider).commitImage(p);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _toast(context, '已导入 $selected 条');
                  },
            child: Text('导入 $selected 条到「${widget.account.name}」'),
          ),
        ),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            positions
                ? '持仓截图将作为"期初持仓"导入（按成本价视为买入，不计费用），用于初始化或对账。请逐条核对名称匹配到的代码，可点右侧按钮更换。'
                : '请逐条核对；截图里没有日期的按当前时间记录。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        ImportRowsView(rows: p.rows, editableCode: true, onChanged: () => setState(() {})),
      ]),
    );
  }
}
