import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/market_clock.dart';
import '../../domain/journal/vocab.dart';
import '../db/app_database.dart';
import '../sync/cloud_sync.dart';

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 导入结果。
class ImportSummary {
  ImportSummary(this.applied, this.skipped, this.byTable);
  final int applied;
  final int skipped;
  final Map<String, int> byTable;
}

/// 本地备份（spec 4：一键导出 / 导入 JSON，导出 Markdown）。
///
/// 备份包含所有用户数据表的原始行与少量偏好设置；API Key、token、登录信息不导出。
/// 导入按 updated_at 合并（较新的覆盖），不会删除本机已有数据，可重复导入。
class BackupService {
  BackupService(this.db, {DateTime Function()? now}) : _now = now ?? DateTime.now;
  final AppDatabase db;
  final DateTime Function() _now;

  static const format = 'stocknote-backup';
  static const version = 1;

  /// 随备份导出的偏好（不含任何密钥、设备与登录信息）。
  static const _settingKeys = {
    'ai.settings',
    'agent.settings',
    'portfolio.cost_method',
    'verify.default_index',
    'market.watchlist',
    'market.refresh_seconds',
    'market.source_priority',
  };

  Future<Map<String, dynamic>> exportJson() async {
    final tables = <String, dynamic>{};
    for (final t in syncTablesOf(db)) {
      final rows = await db.customSelect('SELECT * FROM ${t.actualTableName}').get();
      tables[t.actualTableName] = [for (final r in rows) r.data];
    }
    final meta = await (db.select(db.appMeta)..where((m) => m.key.isIn(_settingKeys))).get();
    return {
      'format': format,
      'version': version,
      'schema': db.schemaVersion,
      'exported_at': _now().toUtc().toIso8601String(),
      'tables': tables,
      'settings': {for (final m in meta) m.key: m.value},
    };
  }

  Future<List<int>> exportBytes() async => utf8.encode(const JsonEncoder.withIndent(' ').convert(await exportJson()));

  /// 导入备份：按 updated_at 合并。
  Future<ImportSummary> importBytes(List<int> bytes) async {
    final Object? root;
    try {
      root = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw const BackupFormatException('不是有效的备份文件');
    }
    if (root is! Map || root['format'] != format) throw const BackupFormatException('不是交易日记的备份文件');
    if ((root['version'] as num? ?? 0) > version) throw const BackupFormatException('备份来自更新版本的应用，请先升级');
    final tables = (root['tables'] as Map? ?? const {});
    final settings = (root['settings'] as Map? ?? const {});
    final byName = {for (final t in syncTablesOf(db)) t.actualTableName: t};
    var applied = 0, skipped = 0;
    final byTable = <String, int>{};
    final touched = <TableInfo<Table, dynamic>>{};
    await db.transaction(() async {
      for (final e in tables.entries) {
        final table = byName[e.key];
        if (table == null) continue;
        final cols = {for (final c in table.$columns) c.name};
        for (final row in (e.value as List? ?? const [])) {
          if (row is! Map || row['id'] == null) continue;
          final data = row.cast<String, dynamic>();
          final local = await db.customSelect('SELECT updated_at FROM ${e.key} WHERE id = ?',
              variables: [Variable.withString('${data['id']}')]).getSingleOrNull();
          final incoming = (data['updated_at'] as num?)?.toInt() ?? 0;
          if (local != null && (local.data['updated_at'] as int) >= incoming) {
            skipped++;
            continue;
          }
          final keys = data.keys.where(cols.contains).toList();
          await db.customStatement(
            'INSERT OR REPLACE INTO ${e.key} (${keys.join(', ')}) VALUES (${List.filled(keys.length, '?').join(', ')})',
            [for (final k in keys) data[k]],
          );
          applied++;
          byTable[e.key] = (byTable[e.key] ?? 0) + 1;
          touched.add(table);
        }
      }
      for (final s in settings.entries) {
        if (!_settingKeys.contains(s.key)) continue;
        await db.into(db.appMeta).insertOnConflictUpdate(AppMetaCompanion.insert(key: '${s.key}', value: '${s.value}'));
      }
    });
    if (touched.isNotEmpty) db.notifyUpdates({for (final t in touched) TableUpdate.onTable(t)});
    return ImportSummary(applied, skipped, byTable);
  }

  /// 导出日记为 Markdown（按交易日分组，附判断结果）。
  Future<String> exportMarkdown() async {
    final entries = await (db.select(db.journalEntries)
          ..where((e) => e.deletedAt.isNull())
          ..orderBy([(e) => OrderingTerm.asc(e.ts)]))
        .get();
    final preds = await (db.select(db.predictions)..where((p) => p.deletedAt.isNull())).get();
    final results = await (db.select(db.predictionResults)..where((r) => r.deletedAt.isNull())).get();
    final byEntry = {for (final p in preds) if (p.entryId != null) p.entryId!: p};
    const status = {'correct': '✅ 正确', 'partial': '◐ 部分正确', 'wrong': '❌ 错误', 'pending_manual': '待手动判定'};
    String two(int n) => n.toString().padLeft(2, '0');
    final b = StringBuffer('# 交易日记\n\n导出时间：${MarketClock.toMarket(_now()).toString().substring(0, 16)}\n');
    String? day;
    for (final e in entries) {
      if (e.tradeDate != day) {
        day = e.tradeDate;
        b.writeln('\n## ${day.substring(0, 4)}-${day.substring(4, 6)}-${day.substring(6, 8)}\n');
      }
      final t = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(e.ts, isUtc: true));
      final cat = byCode(EntryCategory.values, e.category)?.label;
      b.write('- **${two(t.hour)}:${two(t.minute)}**${cat == null ? '' : ' [$cat]'} ${e.content.replaceAll('\n', ' ')}');
      if (e.tags.isNotEmpty) b.write('  #${e.tags.join(' #')}');
      final p = byEntry[e.id];
      if (p != null) {
        final rs = results.where((r) => r.predictionId == p.id).toList()..sort((a, b) => a.checkpoint.compareTo(b.checkpoint));
        if (rs.isNotEmpty) {
          b.write('  → ${rs.map((r) => '${r.checkpoint} ${status[r.status] ?? r.status}').join('，')}');
        }
      }
      b.writeln();
    }
    return b.toString();
  }
}
