/// 日记行内语法解析（spec 3.2.2）。
///
/// - `#标签` / `＃标签`
/// - `$600519` / `$茅台` / `￥510300`（中文输入法下 $ 常打成 ￥）
///
/// 原文保持不变，只提取结构化信息。判断语法 `>3350 T+1` 在 M3 实现。
class EntryParser {
  EntryParser._();

  static final tagPattern = RegExp(r'[#＃]([^\s#＃$￥,，。;；!！?？、]+)');
  static final instrumentPattern =
      RegExp(r'[$￥]([0-9]{6}(?:\.(?:[Ss][Hh]|[Ss][Zz]|[Bb][Jj]))?|[一-龥A-Za-z*][^\s#＃$￥,，。;；!！?？、]*)');

  /// 高亮用：匹配任一种 token。
  static final tokenPattern = RegExp('${tagPattern.pattern}|${instrumentPattern.pattern}');

  static ParsedEntry parse(String input) {
    final text = input.trim();
    return ParsedEntry(
      content: text,
      tags: _unique(tagPattern.allMatches(text).map((m) => m.group(1)!)),
      instrumentRefs: _unique(
          instrumentPattern.allMatches(text).map((m) => m.group(1)!.toUpperCase())),
    );
  }

  static List<String> _unique(Iterable<String> xs) {
    final seen = <String>{};
    return [for (final x in xs) if (seen.add(x)) x];
  }
}

class ParsedEntry {
  const ParsedEntry({
    required this.content,
    required this.tags,
    required this.instrumentRefs,
  });

  final String content;
  final List<String> tags;

  /// 6 位代码或名称原文；名称到代码的解析在接入代码表（M2）后完成。
  final List<String> instrumentRefs;

  bool get isEmpty => content.isEmpty;
}

