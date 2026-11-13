import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/domain/journal/entry_parser.dart';

void main() {
  test('提取 #标签 与 \$标的，原文不变', () {
    final p = EntryParser.parse('  \$600519 放量突破 #突破 #白酒，继续持有  ');
    expect(p.content, '\$600519 放量突破 #突破 #白酒，继续持有');
    expect(p.tags, ['突破', '白酒']);
    expect(p.instrumentRefs, ['600519']);
  });

  test('支持全角 ＃ 与 ￥，以及名称引用', () {
    final p = EntryParser.parse('￥510300 和 \$茅台 都不错 ＃观察');
    expect(p.tags, ['观察']);
    expect(p.instrumentRefs, ['510300', '茅台']);
  });

  test('带交易所后缀的代码统一大写', () {
    expect(EntryParser.parse('\$600519.sh').instrumentRefs, ['600519.SH']);
  });

  test('标签遇到中文标点结束，重复去重', () {
    final p = EntryParser.parse('#情绪退潮，#情绪退潮。#a!');
    expect(p.tags, ['情绪退潮', 'a']);
  });

  test('名称可含括号、罗马数字、*ST，遇空白或标点结束', () {
    expect(EntryParser.parse('\$智算中心（AIDC） 走强').instrumentRefs, ['智算中心（AIDC）']);
    expect(EntryParser.parse('\$综合Ⅲ，\$*ST某某 观察').instrumentRefs, ['综合Ⅲ', '*ST某某']);
  });

  test('空输入', () {
    expect(EntryParser.parse('   ').isEmpty, isTrue);
  });

  test('高亮 token 覆盖两种语法', () {
    final tokens = EntryParser.tokenPattern
        .allMatches('看 #多 \$000001 ok')
        .map((m) => m.group(0))
        .toList();
    expect(tokens, ['#多', '\$000001']);
  });
}
