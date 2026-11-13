import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/journal/vocab.dart';
import '../db/app_database.dart';

class QuickPhraseRepository {
  QuickPhraseRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  static const _seededKey = 'quick_phrases_seeded';

  /// 首次启动写入默认短语；用户删光后不会再自动补回。
  Future<void> seedDefaultsIfNeeded() async {
    final seeded = await (_db.select(_db.appMeta)..where((t) => t.key.equals(_seededKey)))
        .getSingleOrNull();
    if (seeded != null) return;
    await _db.transaction(() async {
      for (var i = 0; i < defaultQuickPhrases.length; i++) {
        await _insert(defaultQuickPhrases[i], i);
      }
      await _db
          .into(_db.appMeta)
          .insert(AppMetaCompanion.insert(key: _seededKey, value: '1'));
    });
  }

  Stream<List<QuickPhrase>> watchAll() => (_db.select(_db.quickPhrases)
        ..where((p) => p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.asc(p.sort), (p) => OrderingTerm.asc(p.createdAt)]))
      .watch();

  Future<void> add(String phrase) async {
    final text = phrase.trim();
    if (text.isEmpty) return;
    final maxSort = _db.quickPhrases.sort.max();
    final row = await (_db.selectOnly(_db.quickPhrases)..addColumns([maxSort])).getSingle();
    await _insert(text, (row.read(maxSort) ?? -1) + 1);
  }

  Future<void> delete(String id) async {
    final ms = _now().millisecondsSinceEpoch;
    await (_db.update(_db.quickPhrases)..where((p) => p.id.equals(id)))
        .write(QuickPhrasesCompanion(deletedAt: Value(ms), updatedAt: Value(ms)));
  }

  /// 按给定顺序重排。
  Future<void> reorder(List<String> orderedIds) async {
    final ms = _now().millisecondsSinceEpoch;
    await _db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          _db.quickPhrases,
          QuickPhrasesCompanion(sort: Value(i), updatedAt: Value(ms)),
          where: (p) => p.id.equals(orderedIds[i]),
        );
      }
    });
  }

  Future<void> _insert(String phrase, int sort) async {
    final ms = _now().millisecondsSinceEpoch;
    await _db.into(_db.quickPhrases).insert(QuickPhrasesCompanion.insert(
          id: newId(),
          createdAt: ms,
          updatedAt: ms,
          deviceId: await _db.deviceId(),
          phrase: phrase,
          sort: Value(sort),
        ));
  }
}
