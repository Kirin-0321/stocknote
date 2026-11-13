import 'package:drift/drift.dart';
import 'package:lpinyin/lpinyin.dart';

import '../db/app_database.dart';
import '../market/code_util.dart';
import '../market/models.dart';

/// 名称拼音首字母（中文取首字母，字母数字保留），如 沪深300ETF → HS300ETF。
String initials(String name) {
  final buf = StringBuffer();
  for (final ch in name.trim().split('')) {
    if (RegExp(r'[一-龥]').hasMatch(ch)) {
      final p = PinyinHelper.getShortPinyin(ch);
      if (p.isNotEmpty) buf.write(p[0]);
    } else if (RegExp(r'[A-Za-z0-9]').hasMatch(ch)) {
      buf.write(ch);
    }
  }
  return buf.toString().toUpperCase();
}

/// 代码表：标的搜索与 `$名称` 解析。
class InstrumentRepository {
  InstrumentRepository(this._db);

  final AppDatabase _db;

  Future<int> count() async {
    final c = _db.instruments.code.count();
    final row = await (_db.selectOnly(_db.instruments)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> upsertAll(List<InstrumentInfo> items) => _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.instruments, [
          for (final i in items)
            InstrumentsCompanion.insert(
              code: i.code,
              name: i.name,
              type: i.type.code,
              exchange: Value(i.exchange),
              pinyin: Value((i.pinyin ?? initials(i.name)).toUpperCase()),
              listDate: Value(i.listDate),
            ),
        ]);
      });

  Future<Instrument?> get(String code) =>
      (_db.select(_db.instruments)..where((i) => i.code.equals(code))).getSingleOrNull();

  Future<Map<String, Instrument>> getMany(Iterable<String> codes) async {
    final list = codes.toSet().toList();
    if (list.isEmpty) return {};
    final rows = await (_db.select(_db.instruments)..where((i) => i.code.isIn(list))).get();
    return {for (final r in rows) r.code: r};
  }

  /// 按代码 / 名称 / 拼音首字母搜索。精确匹配优先，其次前缀，再次包含。
  Future<List<Instrument>> search(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final upper = q.toUpperCase();
    final rows = await (_db.select(_db.instruments)
          ..where((i) =>
              i.code.like('$upper%') |
              i.name.like('%$q%') |
              i.pinyin.like('%$upper%'))
          ..limit(200))
        .get();
    int score(Instrument i) {
      final sym = Codes.symbol(i.code);
      if (sym == upper || i.name == q) return 0;
      if (sym.startsWith(upper) || i.name.startsWith(q) || (i.pinyin?.startsWith(upper) ?? false)) {
        return 1;
      }
      return 2;
    }

    int typeRank(Instrument i) => switch (InstrumentType.fromCode(i.type)) {
          InstrumentType.stock => 0,
          InstrumentType.etf => 1,
          InstrumentType.marketIndex => 2,
          InstrumentType.sector => 3,
        };

    rows.sort((a, b) {
      final s = score(a).compareTo(score(b));
      if (s != 0) return s;
      final t = typeRank(a).compareTo(typeRank(b));
      return t != 0 ? t : a.name.length.compareTo(b.name.length);
    });
    return rows.take(limit).toList();
  }

  /// 把日记中的 `$` 引用解析为规范代码；无法唯一确定时保留原文。
  ///
  /// - 6 位数字：优先个股 / ETF（000001 → 平安银行而非上证指数）
  /// - 名称：精确匹配 → 唯一的前缀 / 包含匹配
  Future<List<String>> resolveRefs(List<String> refs) async {
    final out = <String>[];
    for (final ref in refs) {
      out.add(await _resolve(ref) ?? ref);
    }
    return out.toSet().toList();
  }

  Future<String?> _resolve(String ref) async {
    if (ref.contains('.')) return ref;
    if (RegExp(r'^\d{6}$').hasMatch(ref)) {
      final rows = await (_db.select(_db.instruments)..where((i) => i.code.like('$ref.%'))).get();
      if (rows.isEmpty) return Codes.fromSymbol(ref);
      rows.sort((a, b) => (a.type == 'index' ? 1 : 0).compareTo(b.type == 'index' ? 1 : 0));
      return rows.first.code;
    }
    final exact = await (_db.select(_db.instruments)..where((i) => i.name.equals(ref))).get();
    if (exact.isNotEmpty) return exact.first.code;
    final fuzzy = await search(ref, limit: 2);
    if (fuzzy.length == 1) return fuzzy.first.code;
    if (fuzzy.length > 1 && fuzzy.first.name.startsWith(ref) && !fuzzy[1].name.startsWith(ref)) {
      return fuzzy.first.code;
    }
    return null;
  }
}

