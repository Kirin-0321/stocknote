import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:fast_gbk/fast_gbk.dart';

import '../../core/time/market_clock.dart';
import '../../domain/trade/trade_rules.dart';
import '../repo/trade_repository.dart';

/// 交割单 / 成交明细中可识别的字段（spec 3.4.2）。
enum ImportField {
  date('date', '成交日期', ['成交日期', '发生日期', '交收日期', '日期', '交易日期', '清算日期']),
  time('time', '成交时间', ['成交时间', '时间', '委托时间']),
  secCode('code', '证券代码', ['证券代码', '股票代码', '代码', '基金代码', '证券编码']),
  secName('name', '证券名称', ['证券名称', '股票名称', '名称', '基金名称', '证券简称']),
  side('side', '买卖方向', ['买卖标志', '操作', '业务名称', '摘要', '买卖方向', '交易类别', '委托类别', '业务类型', '方向', '交易类型']),
  price('price', '成交价格', ['成交价格', '成交均价', '成交价', '价格', '均价']),
  qty('qty', '成交数量', ['成交数量', '成交股数', '发生数量', '数量', '股数']),
  amount('amount', '成交金额', ['成交金额', '金额', '成交额']),
  netAmount('netAmount', '发生金额', ['发生金额', '清算金额', '收付金额', '资金发生数']),
  commission('commission', '佣金', ['佣金', '手续费', '净佣金']),
  stampTax('stampTax', '印花税', ['印花税']),
  transferFee('transferFee', '过户费', ['过户费']),
  otherFee('otherFee', '其他费用', ['其他费', '其他费用', '交易规费', '规费', '经手费', '证管费']);

  const ImportField(this.key, this.label, this.synonyms);
  final String key;
  final String label;
  final List<String> synonyms;

  static ImportField? fromCode(String c) => values.where((f) => f.key == c).firstOrNull;

  static const required = [date, price, qty];
}

class UnsupportedFileException implements Exception {
  const UnsupportedFileException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 读取表格文件为二维字符串数组。支持 xlsx、csv / txt，以及券商常见的"伪 xls"（GBK 制表符文本）。
List<List<String>> readTable(List<int> bytes, String fileName) {
  final lower = fileName.toLowerCase();
  final isZip = bytes.length > 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;
  final isOle = bytes.length > 4 && bytes[0] == 0xD0 && bytes[1] == 0xCF && bytes[2] == 0x11 && bytes[3] == 0xE0;
  if (isOle) {
    throw const UnsupportedFileException('暂不支持旧版 .xls 二进制格式，请在 Excel / WPS 中另存为 .xlsx 或 .csv');
  }
  if (isZip || lower.endsWith('.xlsx')) {
    final book = Excel.decodeBytes(bytes);
    for (final sheet in book.tables.values) {
      final rows = [
        for (final r in sheet.rows) [for (final c in r) _cellText(c?.value)],
      ];
      if (rows.any((r) => r.any((c) => c.isNotEmpty))) return _trim(rows);
    }
    return const [];
  }
  final text = _decodeText(bytes);
  final lines = const LineSplitter().convert(text).where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return const [];
  final sample = lines.take(10).join('\n');
  final delim = '\t'.allMatches(sample).length >= ','.allMatches(sample).length ? '\t' : ',';
  return _trim([for (final l in lines) _splitLine(l, delim)]);
}

String _cellText(CellValue? v) => switch (v) {
      null => '',
      TextCellValue() => v.value.toString().trim(),
      IntCellValue() => '${v.value}',
      DoubleCellValue() => v.value == v.value.roundToDouble() && v.value.abs() < 1e15
          ? v.value.toInt().toString()
          : '${v.value}',
      DateCellValue() => '${v.year}${_two(v.month)}${_two(v.day)}',
      DateTimeCellValue() =>
        '${v.year}-${_two(v.month)}-${_two(v.day)} ${_two(v.hour)}:${_two(v.minute)}:${_two(v.second)}',
      TimeCellValue() => '${_two(v.hour)}:${_two(v.minute)}:${_two(v.second)}',
      _ => v.toString().trim(),
    };

String _two(int n) => n.toString().padLeft(2, '0');

String _decodeText(List<int> bytes) {
  var b = bytes;
  if (b.length >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF) b = b.sublist(3);
  try {
    return utf8.decode(b);
  } on FormatException {
    return gbk.decode(b);
  }
}

List<String> _splitLine(String line, String delim) {
  if (delim == '\t') return [for (final c in line.split('\t')) _clean(c)];
  // 简单 CSV：支持双引号包裹
  final out = <String>[];
  final sb = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        sb.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (ch == ',' && !quoted) {
      out.add(_clean(sb.toString()));
      sb.clear();
    } else {
      sb.write(ch);
    }
  }
  out.add(_clean(sb.toString()));
  return out;
}

/// 去掉券商导出常见的 ="000001" 包裹与空白。
String _clean(String s) {
  var t = s.trim();
  if (t.startsWith('="') && t.endsWith('"')) t = t.substring(2, t.length - 1);
  return t.trim();
}

List<List<String>> _trim(List<List<String>> rows) => [
      for (final r in rows)
        if (r.any((c) => c.isNotEmpty)) r,
    ];

/// 识别出的表结构：表头行与列映射。
class TableLayout {
  const TableLayout({required this.headerRow, required this.headers, required this.mapping});
  final int headerRow;
  final List<String> headers;
  final Map<ImportField, int> mapping;

  /// 表头签名，用于复用保存的映射
  String get signature => headers.map((h) => h.trim()).join('|');

  bool get complete =>
      ImportField.required.every(mapping.containsKey) &&
      (mapping.containsKey(ImportField.secCode) || mapping.containsKey(ImportField.secName));

  List<ImportField> get missing => [
        for (final f in ImportField.required)
          if (!mapping.containsKey(f)) f,
        if (!mapping.containsKey(ImportField.secCode) && !mapping.containsKey(ImportField.secName)) ImportField.secCode,
      ];

  TableLayout withMapping(Map<ImportField, int> m) => TableLayout(headerRow: headerRow, headers: headers, mapping: m);

  Map<String, dynamic> toJson() => {
        'signature': signature,
        'columns': {for (final e in mapping.entries) e.key.key: headers[e.value]},
      };

  /// 用保存的映射（按列名）套到当前表头。
  static Map<ImportField, int> mappingFromJson(Map<String, dynamic> j, List<String> headers) {
    final cols = (j['columns'] as Map?) ?? const {};
    return {
      for (final e in cols.entries)
        if (ImportField.fromCode('${e.key}') != null && headers.contains(e.value))
          ImportField.fromCode('${e.key}')!: headers.indexOf(e.value as String),
    };
  }
}

/// 按同义词自动识别表头行与列映射。
TableLayout detectLayout(List<List<String>> rows) {
  var best = 0, bestScore = -1;
  for (var i = 0; i < rows.length && i < 15; i++) {
    final score = autoMap(rows[i]).length;
    if (score > bestScore) {
      best = i;
      bestScore = score;
    }
  }
  final headers = rows.isEmpty ? <String>[] : rows[best];
  return TableLayout(headerRow: best, headers: headers, mapping: autoMap(headers));
}

Map<ImportField, int> autoMap(List<String> headers) {
  final m = <ImportField, int>{};
  final used = <int>{};
  // 先精确匹配，再包含匹配
  for (final exact in [true, false]) {
    for (final f in ImportField.values) {
      if (m.containsKey(f)) continue;
      for (final syn in f.synonyms) {
        final i = headers.indexWhere((h) {
          final t = h.replaceAll(RegExp(r'\s'), '');
          return exact ? t == syn : t.contains(syn);
        });
        if (i >= 0 && !used.contains(i)) {
          m[f] = i;
          used.add(i);
          break;
        }
      }
    }
  }
  return m;
}

/// 一行的解析结果：成功为 [draft]；被跳过（非交易类业务）为 [skipped]；否则 [error]。
class ImportRow {
  ImportRow({required this.index, required this.raw, this.draft, this.error, this.skipped});
  final int index;
  final List<String> raw;
  final TradeDraft? draft;
  final String? error;

  /// 跳过原因（如"银证转账"）
  final String? skipped;

  bool duplicate = false;

  /// 预览页中是否勾选导入
  bool selected = false;
}

double? _num(String? s) {
  if (s == null) return null;
  final t = s.replaceAll(RegExp(r'[,\s¥￥元]'), '');
  if (t.isEmpty || t == '-' || t == '--') return null;
  return double.tryParse(t);
}

/// 方向文字 → 交易方向；非交易类返回 null。
TradeSide? parseSide(String s) {
  final t = s.replaceAll(RegExp(r'\s'), '');
  if (t.isEmpty) return null;
  if (RegExp(r'红股|送股|转增|送转').hasMatch(t)) return TradeSide.bonus;
  if (RegExp(r'红利|股息|分红|派息').hasMatch(t)) {
    return RegExp(r'税|扣').hasMatch(t) ? null : TradeSide.dividend;
  }
  if (RegExp(r'卖|^S$|^SELL$', caseSensitive: false).hasMatch(t)) return TradeSide.sell;
  if (RegExp(r'买|申购|配售|中签|^B$|^BUY$', caseSensitive: false).hasMatch(t)) return TradeSide.buy;
  return null;
}

/// 解析日期 + 时间为 UTC ms（上海时间）。支持 20261113 / 2026-11-13 / 2026/11/13 / Excel 序列号。
int? parseTimestamp(String? date, String? time) {
  if (date == null || date.trim().isEmpty) return null;
  var d = date.trim();
  String? t = time?.trim();
  // 日期列里带时间
  final sp = d.split(RegExp(r'[ T]+'));
  if (sp.length > 1) {
    d = sp[0];
    t = (t == null || t.isEmpty) ? sp[1] : t;
  }
  int y, mo, da;
  final m1 = RegExp(r'^(\d{4})[-/.年](\d{1,2})[-/.月](\d{1,2})').firstMatch(d);
  final m2 = RegExp(r'^(\d{4})(\d{2})(\d{2})$').firstMatch(d);
  if (m1 != null) {
    (y, mo, da) = (int.parse(m1[1]!), int.parse(m1[2]!), int.parse(m1[3]!));
  } else if (m2 != null) {
    (y, mo, da) = (int.parse(m2[1]!), int.parse(m2[2]!), int.parse(m2[3]!));
  } else if (RegExp(r'^\d{5}(\.\d+)?$').hasMatch(d)) {
    final dt = DateTime.utc(1899, 12, 30).add(Duration(days: double.parse(d).floor()));
    (y, mo, da) = (dt.year, dt.month, dt.day);
  } else {
    return null;
  }
  var h = 15, mi = 0, s = 0; // 无时间时按收盘
  if (t != null && t.isNotEmpty) {
    final tm = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?').firstMatch(t);
    final tc = RegExp(r'^(\d{2})(\d{2})(\d{2})?$').firstMatch(t.padLeft(t.length < 6 && t.length > 4 ? 6 : t.length, '0'));
    if (tm != null) {
      (h, mi, s) = (int.parse(tm[1]!), int.parse(tm[2]!), int.tryParse(tm[3] ?? '') ?? 0);
    } else if (tc != null) {
      (h, mi, s) = (int.parse(tc[1]!), int.parse(tc[2]!), int.tryParse(tc[3] ?? '') ?? 0);
    }
  }
  return MarketClock.fromMarket(y, mo, da, h, mi, s).millisecondsSinceEpoch;
}

/// 按映射把数据行转成交易草稿。[resolveName] 用名称查代码（文件只有名称时）。
Future<List<ImportRow>> parseRows(
  List<List<String>> rows,
  TableLayout layout, {
  required String accountId,
  required FeeRates rates,
  Future<String?> Function(String name)? resolveName,
}) async {
  final m = layout.mapping;
  String? cell(List<String> r, ImportField f) {
    final i = m[f];
    return i == null || i >= r.length ? null : r[i];
  }

  final out = <ImportRow>[];
  for (var i = layout.headerRow + 1; i < rows.length; i++) {
    final r = rows[i];
    ImportRow err(String e) => ImportRow(index: i, raw: r, error: e);

    final sideText = cell(r, ImportField.side);
    final qtyRaw = _num(cell(r, ImportField.qty));
    final netRaw = _num(cell(r, ImportField.netAmount));
    TradeSide? side;
    if (sideText != null && sideText.isNotEmpty) {
      side = parseSide(sideText);
      if (side == null) {
        out.add(ImportRow(index: i, raw: r, skipped: sideText));
        continue;
      }
    } else if (qtyRaw != null && qtyRaw != 0) {
      // 无方向列：数量或发生金额为负视为卖出
      side = (qtyRaw < 0 || (netRaw ?? -1) > 0) ? TradeSide.sell : TradeSide.buy;
    }
    if (side == null) {
      out.add(err('无法识别买卖方向'));
      continue;
    }

    final ts = parseTimestamp(cell(r, ImportField.date), cell(r, ImportField.time));
    if (ts == null) {
      out.add(err('日期无法识别'));
      continue;
    }

    final name = cell(r, ImportField.secName);
    var code = canonicalCode(cell(r, ImportField.secCode) ?? '');
    if (code == null && name != null && name.isNotEmpty && resolveName != null) {
      code = await resolveName(name);
    }
    if (code == null) {
      out.add(err('证券代码无法识别'));
      continue;
    }

    final qty = (qtyRaw ?? 0).abs().round();
    final price = (_num(cell(r, ImportField.price)) ?? 0).abs();
    var amount = _num(cell(r, ImportField.amount))?.abs();
    if (side == TradeSide.dividend) {
      amount ??= netRaw?.abs();
      if (amount == null || amount == 0) {
        out.add(err('分红金额缺失'));
        continue;
      }
    } else if (side == TradeSide.bonus) {
      if (qty == 0) {
        out.add(err('送转数量缺失'));
        continue;
      }
      amount = 0;
    } else {
      if (qty == 0 || price == 0) {
        out.add(ImportRow(index: i, raw: r, skipped: '数量或价格为 0'));
        continue;
      }
      amount ??= round2(price * qty);
    }

    // 文件里有费用列用文件的，否则按账户费率计算
    final hasFees = m.containsKey(ImportField.commission) ||
        m.containsKey(ImportField.stampTax) ||
        m.containsKey(ImportField.transferFee);
    final fees = hasFees
        ? Fees(
            commission: (_num(cell(r, ImportField.commission)) ?? 0).abs() +
                (_num(cell(r, ImportField.otherFee)) ?? 0).abs(),
            stampTax: (_num(cell(r, ImportField.stampTax)) ?? 0).abs(),
            transferFee: (_num(cell(r, ImportField.transferFee)) ?? 0).abs(),
          )
        : calcFees(rates, side, code, amount);

    out.add(ImportRow(
      index: i,
      raw: r,
      draft: TradeDraft(
        accountId: accountId,
        code: code,
        side: side,
        ts: ts,
        price: side == TradeSide.dividend ? 0 : price,
        qty: side == TradeSide.dividend ? qty : qty,
        amount: amount,
        fees: fees,
        name: name,
      ),
    ));
  }
  return out;
}

/// 标记重复（与已有交易或文件内重复），并默认勾选可导入的行。
void markDuplicates(List<ImportRow> rows, Set<String> existing) {
  final seen = {...existing};
  for (final r in rows) {
    final d = r.draft;
    if (d == null) continue;
    r.duplicate = !seen.add(d.dedupeKey);
    r.selected = !r.duplicate;
  }
}
