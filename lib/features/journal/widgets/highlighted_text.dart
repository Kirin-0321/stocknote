import 'package:material_ui/material_ui.dart';

import '../../../domain/journal/entry_parser.dart';

/// 高亮 `#标签` 与 `$标的` 的正文。
class HighlightedText extends StatelessWidget {
  const HighlightedText(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = style ?? Theme.of(context).textTheme.bodyLarge;
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in EntryParser.tokenPattern.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      final isTag = m.group(0)!.startsWith(RegExp('[#＃]'));
      spans.add(TextSpan(
        text: m.group(0),
        style: TextStyle(
          color: isTag ? scheme.primary : scheme.tertiary,
          fontWeight: FontWeight.w600,
        ),
      ));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
