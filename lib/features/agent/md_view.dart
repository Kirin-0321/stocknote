import 'package:material_ui/material_ui.dart';

/// 轻量 Markdown 渲染：标题、列表、表格、分隔线、加粗、行内代码，以及引用标记 [[journal:ID]]。
class MdView extends StatelessWidget {
  const MdView(this.text, {super.key, this.onCite});
  final String text;

  /// 点击引用：(类型, id)
  final void Function(String type, String id)? onCite;

  static final _cite = RegExp(r'\[\[(journal|prediction|trade):([^\]\s]+)\]\]');
  static final _inline = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`|\[\[(journal|prediction|trade):([^\]\s]+)\]\]');
  static const _citeLabels = {'journal': '日记', 'prediction': '判断', 'trade': '交易'};

  List<InlineSpan> _spans(BuildContext context, String s, TextStyle base) {
    final theme = Theme.of(context);
    final out = <InlineSpan>[];
    var i = 0;
    for (final m in _inline.allMatches(s)) {
      if (m.start > i) out.add(TextSpan(text: s.substring(i, m.start)));
      if (m.group(1) != null) {
        out.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
      } else if (m.group(2) != null) {
        out.add(TextSpan(
          text: m.group(2),
          style: TextStyle(fontFamily: 'monospace', backgroundColor: theme.colorScheme.surfaceContainerHighest),
        ));
      } else {
        final type = m.group(3)!, id = m.group(4)!;
        out.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onCite == null ? null : () => onCite!(type, id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_citeLabels[type]!,
                    style: TextStyle(fontSize: (base.fontSize ?? 14) - 3, color: theme.colorScheme.onPrimaryContainer)),
              ),
            ),
          ),
        ));
      }
      i = m.end;
    }
    if (i < s.length) out.add(TextSpan(text: s.substring(i)));
    return out;
  }

  Widget _rich(BuildContext context, String s, TextStyle style) =>
      Text.rich(TextSpan(style: style, children: _spans(context, s, style)));

  static List<String> _cells(String row) {
    var r = row.trim();
    if (r.startsWith('|')) r = r.substring(1);
    if (r.endsWith('|')) r = r.substring(0, r.length - 1);
    return r.split('|').map((c) => c.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium!.copyWith(height: 1.5);
    final lines = text.replaceAll('\r', '').split('\n');
    final blocks = <Widget>[];
    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final t = line.trim();
      if (t.isEmpty) {
        i++;
        continue;
      }
      // 表格
      if (t.startsWith('|') && i + 1 < lines.length && RegExp(r'^\|?\s*:?-{2,}').hasMatch(lines[i + 1].trim())) {
        final header = _cells(t);
        i += 2;
        final rows = <List<String>>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          rows.add(_cells(lines[i]));
          i++;
        }
        final small = base.copyWith(fontSize: (base.fontSize ?? 14) - 1);
        blocks.add(SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: theme.colorScheme.outlineVariant, width: 0.5),
            children: [
              TableRow(
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
                children: [
                  for (final h in header)
                    Padding(padding: const EdgeInsets.all(6), child: _rich(context, h, small.copyWith(fontWeight: FontWeight.w600))),
                ],
              ),
              for (final r in rows)
                TableRow(children: [
                  for (var c = 0; c < header.length; c++)
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: _rich(context, c < r.length ? r[c] : '', small),
                      ),
                    ),
                ]),
            ],
          ),
        ));
        continue;
      }
      final h = RegExp(r'^(#{1,4})\s+(.*)$').firstMatch(t);
      if (h != null) {
        final level = h.group(1)!.length;
        final style = (level <= 1
                ? theme.textTheme.titleMedium
                : level == 2
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.labelLarge)!
            .copyWith(fontWeight: FontWeight.w700);
        blocks.add(Padding(padding: const EdgeInsets.only(top: 6), child: _rich(context, h.group(2)!, style)));
        i++;
        continue;
      }
      if (RegExp(r'^(-{3,}|\*{3,})$').hasMatch(t)) {
        blocks.add(const Divider(height: 12));
        i++;
        continue;
      }
      final li = RegExp(r'^(\s*)([-*•]|\d+[.)])\s+(.*)$').firstMatch(line);
      if (li != null) {
        final indent = li.group(1)!.length >= 2 ? 16.0 : 0.0;
        final marker = RegExp(r'^\d').hasMatch(li.group(2)!) ? li.group(2)! : '•';
        blocks.add(Padding(
          padding: EdgeInsets.only(left: indent),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 20, child: Text(marker, style: base)),
            Expanded(child: _rich(context, li.group(3)!, base)),
          ]),
        ));
        i++;
        continue;
      }
      // 段落：合并连续普通行
      final para = <String>[t];
      i++;
      while (i < lines.length) {
        final n = lines[i].trim();
        if (n.isEmpty || n.startsWith('#') || n.startsWith('|') || RegExp(r'^([-*•]|\d+[.)])\s').hasMatch(n)) break;
        para.add(n);
        i++;
      }
      blocks.add(_rich(context, para.join('\n'), base));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final b in blocks) Padding(padding: const EdgeInsets.only(bottom: 6), child: b)],
    );
  }

  /// 去掉引用标记的纯文本（复制用）。
  static String plain(String s) => s.replaceAll(_cite, '');
}
