import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/journal/vocab.dart';
import 'package:stocknote/features/journal/widgets/composer.dart';

void main() {
  test('每个一级分类展开对应的二级选项组', () {
    expect(groupsFor(EntryCategory.judge).map((g) => g.field),
        [TagField.subcategory, TagField.stance, TagField.horizon]);
    expect(groupsFor(EntryCategory.plan).map((g) => g.field), [TagField.action, TagField.horizon]);
    expect(groupsFor(EntryCategory.observe).single.options, ObserveTopic.values);
    expect(groupsFor(EntryCategory.other), isEmpty);
  });

  test('切换一级分类清空二级字段，保留情绪', () {
    final c = const EntryClass(category: 'judge', subcategory: 'stock', stance: 'bull', emotion: 'fomo')
        .withCategory(EntryCategory.plan);
    expect(c, const EntryClass(category: 'plan', emotion: 'fomo'));
  });

  test('规范化：未选分类视为其他，去掉不属于该分类的字段', () {
    expect(const EntryClass(stance: 'bull').normalized(), const EntryClass(category: 'other'));
    expect(const EntryClass(category: 'plan', action: 'buy', stance: 'bull', horizon: 'soon').normalized(),
        const EntryClass(category: 'plan', action: 'buy', horizon: 'soon'));
  });

  test('展示标签', () {
    expect(
        const EntryClass(category: 'judge', subcategory: 'stock', stance: 'bull', horizon: 't1')
            .labels(),
        ['判断·个股', '看多', 'T+1']);
    expect(const EntryClass(category: 'plan', action: 'buy', horizon: 'soon').labels(),
        ['计划', '买入', '近期']);
    expect(const EntryClass(category: 'other').labels(), isEmpty);
    // 旧版数据（无分类）按旧要素显示
    expect(const EntryClass(stance: 'wait', action: 'hold').labels(), ['观望', '持有']);
  });

  test('判断未选对象时按关联标的推断', () {
    const judge = EntryClass(category: 'judge', stance: 'bull');
    expect(inferJudgeTarget(judge, ['600519.SH']).subcategory, 'stock');
    expect(inferJudgeTarget(judge, ['510300.SH']).subcategory, 'etf');
    expect(inferJudgeTarget(judge, ['000001.SH']).subcategory, 'market');
    expect(inferJudgeTarget(judge, ['399006.SZ']).subcategory, 'index');
    expect(inferJudgeTarget(judge, ['BK1036.EM']).subcategory, 'sector');
    expect(inferJudgeTarget(judge, ['茅台']).subcategory, isNull);
    expect(inferJudgeTarget(const EntryClass(category: 'plan'), ['600519.SH']).subcategory, isNull);
  });
}
