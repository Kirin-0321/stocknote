import 'package:drift/drift.dart';

import 'converters.dart';

// 表结构对应 docs/SPEC.md §5.5。
// 时间统一存 UTC 毫秒（int），交易日期存 yyyyMMdd 文本。

/// 所有可同步实体的公共字段（spec 5.5 / 5.6）。
mixin SyncColumns on Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ───────────── 参考数据（不同步） ─────────────

@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('Instrument')
class Instruments extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();

  /// stock | etf | index | sector
  TextColumn get type => text()();
  TextColumn get exchange => text().nullable()();
  TextColumn get pinyin => text().nullable()();
  TextColumn get listDate => text().nullable()();
  TextColumn get extra => text().map(const JsonMapConverter()).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}

@DataClassName('TradingDay')
class TradingDays extends Table {
  TextColumn get date => text()();
  BoolColumn get isOpen => boolean()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

@DataClassName('KlineBar')
class KlineCache extends Table {
  TextColumn get code => text()();

  /// 1d | 1w | 1m(minute) ...
  TextColumn get period => text()();

  /// 日线为 yyyyMMdd；分钟线为 yyyyMMddHHmm
  TextColumn get date => text()();
  RealColumn get open => real()();
  RealColumn get high => real()();
  RealColumn get low => real()();
  RealColumn get close => real()();
  RealColumn get volume => real().nullable()();
  RealColumn get amount => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {code, period, date};
}

// ───────────── 日记 ─────────────

@DataClassName('JournalEntry')
class JournalEntries extends Table with SyncColumns {
  TextColumn get tradeDate => text()();

  /// TradingSession.code
  TextColumn get session => text()();
  IntColumn get ts => integer()();
  TextColumn get content => text()();

  /// 一级分类：observe | judge | plan | review | other（v2 新增；旧数据为 null）
  TextColumn get category => text().nullable()();

  /// 二级分类：观察主题 / 判断对象 / 复盘类型
  TextColumn get subcategory => text().nullable()();

  /// 判断方向：bull | bear | range（旧版另有 wait）
  TextColumn get stance => text().nullable()();

  /// 计划动作：buy | add | reduce | sell（旧版另有 hold | flat）
  TextColumn get action => text().nullable()();

  /// 判断周期（close | t1 | t5 | mid）或计划时间（today | soon | future）
  TextColumn get horizon => text().nullable()();
  TextColumn get emotion => text().nullable()();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get instrumentCodes =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get snapshotId => text().nullable()();
  TextColumn get templateId => text().nullable()();
  IntColumn get revisionCount => integer().withDefault(const Constant(0))();
}

@DataClassName('MarketSnapshot')
class MarketSnapshots extends Table with SyncColumns {
  IntColumn get ts => integer()();
  TextColumn get indices => text().map(const JsonMapConverter())();
  TextColumn get breadth => text().map(const JsonMapConverter()).nullable()();
  RealColumn get turnover => real().nullable()();
  TextColumn get extra => text().map(const JsonMapConverter()).nullable()();
  BoolColumn get isBackfilled => boolean().withDefault(const Constant(false))();
}

@DataClassName('Attachment')
class Attachments extends Table with SyncColumns {
  TextColumn get entryId => text()();
  TextColumn get localPath => text()();
  TextColumn get mime => text()();
  IntColumn get size => integer()();
}

@DataClassName('QuickPhrase')
class QuickPhrases extends Table with SyncColumns {
  TextColumn get phrase => text()();
  TextColumn get category => text().nullable()();
  IntColumn get sort => integer().withDefault(const Constant(0))();
}

@DataClassName('EntryTemplate')
class EntryTemplates extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get fields => text().map(const JsonMapConverter())();
}

// ───────────── 判断与验证 ─────────────

@DataClassName('Prediction')
class Predictions extends Table with SyncColumns {
  TextColumn get entryId => text().nullable()();

  /// user | ai
  TextColumn get source => text()();
  TextColumn get analysisId => text().nullable()();
  TextColumn get targetCode => text()();

  /// up | down | range
  TextColumn get direction => text()();

  /// close | t1 | t3 | t5 | custom
  TextColumn get horizonType => text()();
  TextColumn get dueDate => text()();
  RealColumn get basePrice => real().nullable()();
  RealColumn get targetPrice => real().nullable()();
  RealColumn get stopPrice => real().nullable()();
  RealColumn get rangeLow => real().nullable()();
  RealColumn get rangeHigh => real().nullable()();

  /// 单条判断的阈值覆盖（百分比，如 0.5 表示 ±0.5%）
  RealColumn get thresholdPct => real().nullable()();
  IntColumn get confidence => integer().withDefault(const Constant(3))();
  IntColumn get revisionCount => integer().withDefault(const Constant(0))();
  BoolColumn get modifiedBeforeDue =>
      boolean().withDefault(const Constant(false))();
}

@DataClassName('PredictionResult')
class PredictionResults extends Table with SyncColumns {
  TextColumn get predictionId => text()();

  /// 验证时点：c0 当日收盘 | o1 次日开盘 | c1 次日收盘 | c3 | c5 | c20（v3 新增）
  TextColumn get checkpoint => text().withDefault(const Constant('c1'))();

  /// correct | wrong | partial | pending_manual
  TextColumn get status => text()();
  RealColumn get actualClose => real().nullable()();
  RealColumn get changePct => real().nullable()();
  RealColumn get mfe => real().nullable()();
  RealColumn get mae => real().nullable()();
  IntColumn get decidedAt => integer()();
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
  IntColumn get ruleVersion => integer().withDefault(const Constant(1))();
}

@DataClassName('ReviewNote')
class ReviewNotes extends Table with SyncColumns {
  TextColumn get predictionId => text().nullable()();
  TextColumn get entryId => text().nullable()();
  TextColumn get content => text()();
  TextColumn get reasons =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
}

@DataClassName('ThresholdRule')
class ThresholdRules extends Table with SyncColumns {
  /// global | type | horizon
  TextColumn get scope => text()();
  TextColumn get instrumentType => text().nullable()();
  TextColumn get horizonType => text().nullable()();
  RealColumn get pct => real()();
}

/// 通用修改历史（spec 3.2.2 / 3.4.3）。
@DataClassName('Revision')
class Revisions extends Table with SyncColumns {
  /// journal_entry | prediction | trade | position_snapshot
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get revisionNo => integer()();

  /// 修改前的完整记录
  TextColumn get before => text().map(const JsonMapConverter())();
  TextColumn get changedFields => text().map(const StringListConverter())();
  IntColumn get ts => integer()();
}

// ───────────── AI ─────────────

@DataClassName('AiAnalysis')
class AiAnalyses extends Table with SyncColumns {
  IntColumn get ts => integer()();

  /// manual | scheduled
  TextColumn get trigger => text()();
  TextColumn get provider => text()();
  TextColumn get model => text()();
  TextColumn get promptVersion => text()();
  TextColumn get inputDigest => text().nullable()();
  TextColumn get output => text().map(const JsonMapConverter()).nullable()();
  TextColumn get rawText => text().nullable()();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
}

// ───────────── 持仓与交易 ─────────────

@DataClassName('Account')
class Accounts extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get broker => text().nullable()();
  RealColumn get commissionRate => real().withDefault(const Constant(0.00025))();
  RealColumn get minCommission => real().withDefault(const Constant(5))();
  RealColumn get stampTaxRate => real().withDefault(const Constant(0.0005))();
  RealColumn get transferFeeRate => real().withDefault(const Constant(0.00001))();
}

@DataClassName('Trade')
class Trades extends Table with SyncColumns {
  TextColumn get accountId => text()();
  TextColumn get instrumentCode => text()();

  /// buy | sell | dividend | bonus | subscribe ...
  TextColumn get side => text()();
  IntColumn get ts => integer()();
  RealColumn get price => real()();
  IntColumn get qty => integer()();
  RealColumn get amount => real()();
  RealColumn get commission => real().withDefault(const Constant(0))();
  RealColumn get stampTax => real().withDefault(const Constant(0))();
  RealColumn get transferFee => real().withDefault(const Constant(0))();
  TextColumn get entryId => text().nullable()();

  /// manual | image | table
  TextColumn get source => text()();
  TextColumn get importBatchId => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get revisionCount => integer().withDefault(const Constant(0))();
}

@DataClassName('PositionSnapshot')
class PositionSnapshots extends Table with SyncColumns {
  TextColumn get accountId => text()();
  TextColumn get instrumentCode => text()();
  TextColumn get date => text()();
  IntColumn get qty => integer()();
  RealColumn get costPrice => real()();
  TextColumn get source => text()();
  IntColumn get revisionCount => integer().withDefault(const Constant(0))();
}

@DataClassName('ImportBatch')
class ImportBatches extends Table with SyncColumns {
  /// image | table
  TextColumn get kind => text()();
  TextColumn get fileName => text().nullable()();
  TextColumn get mappingId => text().nullable()();
  IntColumn get ts => integer()();
  IntColumn get rowCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
}

// ───────────── 全局 Agent（spec 3.5） ─────────────

@DataClassName('AgentThread')
class AgentThreads extends Table with SyncColumns {
  TextColumn get title => text()();

  /// 早期消息压缩后的滚动摘要
  TextColumn get summary => text().nullable()();
  TextColumn get summaryUptoMessageId => text().nullable()();
  IntColumn get lastMessageAt => integer()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
}

@DataClassName('AgentMessage')
class AgentMessages extends Table with SyncColumns {
  TextColumn get threadId => text()();

  /// user | assistant | tool
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get toolCalls => text().nullable()();
  TextColumn get toolCallId => text().nullable()();
  IntColumn get ts => integer()();
  IntColumn get tokens => integer().nullable()();
}

@DataClassName('AgentMemory')
class AgentMemories extends Table with SyncColumns {
  /// style | rule | preference | lesson | watch | fact
  TextColumn get kind => text()();
  TextColumn get content => text()();

  /// active | candidate（待用户确认）
  TextColumn get status => text()();
  TextColumn get sourceThreadId => text().nullable()();
  IntColumn get importance => integer().withDefault(const Constant(3))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get lastUsedAt => integer().nullable()();
}

@DataClassName('ColumnMapping')
class ColumnMappings extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get broker => text().nullable()();
  TextColumn get mapping => text().map(const JsonMapConverter())();
}
