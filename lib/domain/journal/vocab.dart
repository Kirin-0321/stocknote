/// 日记分类词表（spec 3.2.2，v0.3 二级分类）。code 存库，label 展示。
library;

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

// ───────────── 一级分类 ─────────────

enum EntryCategory implements Coded {
  observe('observe', '观察', '盘面现象、消息新闻、资金动向… 可以 \$代码 关联标的'),
  judge('judge', '判断', '对谁、看多还是看空、理由… 例：\$半导体 放量突破看多'),
  plan('plan', '计划', '准备买卖什么、价位、仓位… 例：\$510300 回踩 4.0 分批买'),
  review('review', '复盘', '做得好的 / 不好的、经验教训…'),
  other('other', '其他', '任意内容');

  const EntryCategory(this.code, this.label, this.hint);
  @override
  final String code;
  @override
  final String label;
  final String hint;
}

// ───────────── 二级：观察 ─────────────

enum ObserveTopic implements Coded {
  market('market', '盘面'),
  sector('sector', '板块题材'),
  stock('stock', '个股'),
  news('news', '消息新闻'),
  capital('capital', '资金'),
  other('other', '其他');

  const ObserveTopic(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

// ───────────── 二级：判断 ─────────────

enum JudgeTarget implements Coded {
  market('market', '大盘'),
  marketIndex('index', '指数'),
  sector('sector', '板块题材'),
  stock('stock', '个股'),
  etf('etf', 'ETF');

  const JudgeTarget(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

/// 多空方向（存 stance 列）。
enum Direction implements Coded {
  bull('bull', '看多'),
  bear('bear', '看空'),
  range('range', '震荡');

  const Direction(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

/// 判断周期（M3 自动验证使用）。
enum JudgeHorizon implements Coded {
  today('close', '今日'),
  t1('t1', 'T+1'),
  week('t5', '一周'),
  mid('mid', '中期');

  const JudgeHorizon(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

// ───────────── 二级：计划 ─────────────

/// 计划动作（存 action 列）。
enum PlanAction implements Coded {
  buy('buy', '买入'),
  add('add', '加仓'),
  reduce('reduce', '减仓'),
  sell('sell', '卖出');

  const PlanAction(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

enum PlanTiming implements Coded {
  today('today', '今日'),
  soon('soon', '近期'),
  future('future', '未来');

  const PlanTiming(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

// ───────────── 二级：复盘 ─────────────

enum ReviewKind implements Coded {
  daily('daily', '当日'),
  trade('trade', '交易'),
  judge('judge', '判断'),
  other('other', '其他');

  const ReviewKind(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

// ───────────── 通用：情绪 ─────────────

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

// ───────────── 旧版（v0.2）要素，仅用于显示历史数据 ─────────────

enum LegacyStance implements Coded {
  bull('bull', '看多'),
  bear('bear', '看空'),
  wait('wait', '观望');

  const LegacyStance(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

enum LegacyAction implements Coded {
  buy('buy', '买入'),
  sell('sell', '卖出'),
  add('add', '加仓'),
  reduce('reduce', '减仓'),
  hold('hold', '持有'),
  flat('flat', '空仓');

  const LegacyAction(this.code, this.label);
  @override
  final String code;
  @override
  final String label;
}

// ───────────── 分类结构 ─────────────

/// 条目分类要素存放的字段。
enum TagField { subcategory, stance, action, horizon, emotion }

/// 某一级分类下展开的一组二级选项。
class TagGroup {
  const TagGroup(this.field, this.label, this.options);
  final TagField field;
  final String label;
  final List<Coded> options;
}

/// 一级分类展开后的二级选项组。
List<TagGroup> groupsFor(EntryCategory? c) => switch (c) {
      EntryCategory.observe => const [TagGroup(TagField.subcategory, '主题', ObserveTopic.values)],
      EntryCategory.judge => const [
          TagGroup(TagField.subcategory, '对象', JudgeTarget.values),
          TagGroup(TagField.stance, '方向', Direction.values),
          TagGroup(TagField.horizon, '周期', JudgeHorizon.values),
        ],
      EntryCategory.plan => const [
          TagGroup(TagField.action, '动作', PlanAction.values),
          TagGroup(TagField.horizon, '时间', PlanTiming.values),
        ],
      EntryCategory.review => const [TagGroup(TagField.subcategory, '类型', ReviewKind.values)],
      // 情绪只在"其他"中保留（主观状态难以自我判断，默认只记录外在因素）
      EntryCategory.other => const [TagGroup(TagField.emotion, '情绪', Emotion.values)],
      null => const [],
    };


/// 把存库 code 翻译成显示文字（考虑一级分类上下文；无分类时按旧版要素解释）。
String? labelFor(EntryCategory? c, TagField field, String? code) {
  if (code == null) return null;
  if (field == TagField.emotion) return byCode(Emotion.values, code)?.label ?? code;
  for (final g in groupsFor(c)) {
    if (g.field == field) {
      for (final o in g.options) {
        if (o.code == code) return o.label;
      }
    }
  }
  if (c == null) {
    if (field == TagField.stance) return byCode(LegacyStance.values, code)?.label;
    if (field == TagField.action) return byCode(LegacyAction.values, code)?.label;
  }
  return code;
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
  'category': '分类',
  'subcategory': '二级分类',
  'stance': '方向',
  'action': '动作',
  'horizon': '周期',
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

