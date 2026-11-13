import 'models.dart';

/// 规范代码与各数据源代码格式的互转。
class Codes {
  Codes._();

  /// 由 6 位代码推断规范代码（个股 / ETF）。指数存在歧义（如 000001），需显式带后缀。
  static String fromSymbol(String symbol) {
    final s = symbol.trim().toUpperCase();
    if (s.contains('.')) return s;
    if (s.startsWith('BK')) return '$s.EM';
    if (RegExp(r'^(4|8|92)').hasMatch(s)) return '$s.BJ';
    if (RegExp(r'^(5|6|9)').hasMatch(s)) return '$s.SH';
    return '$s.SZ';
  }

  static String symbol(String code) => code.split('.').first;
  static String exchange(String code) => code.contains('.') ? code.split('.').last : '';

  static bool isEmSector(String code) => exchange(code) == 'EM';
  static bool isThsSector(String code) => exchange(code) == 'TI';
  static bool isTencentSector(String code) => exchange(code) == 'PT';

  /// 规范代码 → 东方财富 secid（`1.600519` / `0.000001` / `90.BK1036`）。
  static String? toEmSecid(String code) {
    final sym = symbol(code);
    return switch (exchange(code)) {
      'SH' => '1.$sym',
      'SZ' || 'BJ' => '0.$sym',
      'EM' => '90.$sym',
      _ => null,
    };
  }

  /// 东方财富 (market, code) → 规范代码。
  static String fromEm(int market, String code) => switch (market) {
        1 => '$code.SH',
        90 => '$code.EM',
        _ => code.startsWith(RegExp(r'(4|8|92)')) ? '$code.BJ' : '$code.SZ',
      };

  /// 规范代码 → 腾讯代码（`sh600519` / `sz000001` / `bj899050`）。
  static String? toTencent(String code) {
    final ex = exchange(code).toLowerCase();
    if (!['sh', 'sz', 'bj', 'pt'].contains(ex)) return null;
    return '$ex${symbol(code)}';
  }

  static String fromTencent(String tc) {
    final ex = tc.substring(0, 2).toUpperCase();
    return '${tc.substring(2)}.$ex';
  }

  /// 粗略判断类型（无代码表时使用）。
  static InstrumentType guessType(String code) {
    if (isEmSector(code) || isThsSector(code) || isTencentSector(code)) {
      return InstrumentType.sector;
    }
    final sym = symbol(code);
    final ex = exchange(code);
    if (ex == 'SH' && sym.startsWith('000')) return InstrumentType.marketIndex;
    if (ex == 'SZ' && sym.startsWith('399')) return InstrumentType.marketIndex;
    if (ex == 'BJ' && sym.startsWith('899')) return InstrumentType.marketIndex;
    if ((ex == 'SH' && sym.startsWith('5')) || (ex == 'SZ' && sym.startsWith('1'))) {
      return InstrumentType.etf;
    }
    return InstrumentType.stock;
  }
}

