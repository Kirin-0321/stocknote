/// 日记快捷要素词表（spec 3.2.2）。code 存库，label 展示。
abstract interface class Coded {
  String get code;
  String get label;
}

T? byCode<T extends Coded>(List<T> values, String? code) {
  if (code == null) return null;
  for (final v in values) {
    if (v.code == code) return v;
  }
  return null;
}

enum Stance implements Coded {
  bull('bull', '看多'),
  bear('bear', '看空'),
  wait('wait', '观望');

  const Stance(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

enum TradeAction implements Coded {
  buy('buy', '买入'),
  sell('sell', '卖出'),
  add('add', '加仓'),
  reduce('reduce', '减仓'),
  hold('hold', '持有'),
  flat('flat', '空仓');

  const TradeAction(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

enum Emotion implements Coded {
  calm('calm', '冷静'),
  hesitant('hesitant', '犹豫'),
  fomo('fomo', 'FOMO'),
  panic('panic', '恐慌'),
  greedy('greedy', '贪婪');

  const Emotion(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

/// 新安装时预置的常用短语。
const defaultQuickPhrases = [
  '放量突破',
  '缩量回调',
  '冲高回落',
  '低开高走',
  '高开低走',
  '板块轮动',
  '主线清晰',
  '情绪退潮',
  '按计划执行',
];

/// 修改历史中字段名的中文显示。
const journalFieldLabels = {
  'content': '内容',
  'stance': '观点',
  'action': '动作',
  'emotion': '情绪',
  'tags': '标签',
  'instrumentCodes': '关联标的',
  'ts': '时间',
  'tradeDate': '交易日',
  'session': '时段',
  'deletedAt': '删除状态',
  'snapshotId': '行情快照',
  'templateId': '模板',
};
