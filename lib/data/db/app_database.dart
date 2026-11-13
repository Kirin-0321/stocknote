import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/ids.dart';
import 'converters.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  AppMeta,
  Instruments,
  TradingDays,
  KlineCache,
  JournalEntries,
  MarketSnapshots,
  Attachments,
  QuickPhrases,
  EntryTemplates,
  Predictions,
  PredictionResults,
  ReviewNotes,
  ThresholdRules,
  Revisions,
  AiAnalyses,
  Accounts,
  Trades,
  PositionSnapshots,
  ImportBatches,
  ColumnMappings,
  AgentThreads,
  AgentMessages,
  AgentMemories,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 应用默认数据库文件。
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'stocknote'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2：日记二级分类
            await m.addColumn(journalEntries, journalEntries.category);
            await m.addColumn(journalEntries, journalEntries.subcategory);
            await m.addColumn(journalEntries, journalEntries.horizon);
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_entry_category ON journal_entries(category, subcategory)');
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    const stmts = [
      'CREATE INDEX idx_entry_date ON journal_entries(trade_date, ts)',
      'CREATE INDEX idx_entry_category ON journal_entries(category, subcategory)',
      'CREATE INDEX idx_prediction_due ON predictions(due_date)',
      'CREATE INDEX idx_prediction_entry ON predictions(entry_id)',
      'CREATE INDEX idx_result_prediction ON prediction_results(prediction_id)',
      'CREATE INDEX idx_revision_entity ON revisions(entity_type, entity_id, revision_no)',
      'CREATE INDEX idx_trade_account ON trades(account_id, ts)',
      'CREATE INDEX idx_trade_instrument ON trades(instrument_code, ts)',
      'CREATE INDEX idx_agent_message_thread ON agent_messages(thread_id, ts)',
      'CREATE INDEX idx_agent_memory_status ON agent_memories(status, kind)',
    ];
    for (final s in stmts) {
      await customStatement(s);
    }
  }

  // ───── 设备 ID（同步用） ─────

  static const _deviceIdKey = 'device_id';

  Future<String> deviceId() async {
    final row = await (select(appMeta)..where((t) => t.key.equals(_deviceIdKey)))
        .getSingleOrNull();
    if (row != null) return row.value;
    final id = newId();
    await into(appMeta).insert(AppMetaCompanion.insert(key: _deviceIdKey, value: id));
    return id;
  }
}
