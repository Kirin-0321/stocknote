/// 交易方向、代码规则与费用计算（spec 3.4）。
library;

enum TradeSide {
  buy('buy', '买入'),
  sell('sell', '卖出'),
  dividend('dividend', '分红'),
  bonus('bonus', '送转'),

  /// 期初持仓 / 持仓快照初始化：按成本价视为一笔买入，无费用
  init('init', '期初持仓');

  const TradeSide(this.code, this.label);
  final String code;
  final String label;

  static TradeSide? fromCode(String? c) => values.where((s) => s.code == c).firstOrNull;

  /// 是否增加持仓数量
  bool get adds => this == buy || this == init || this == bonus;
}

/// 6 位代码补交易所后缀；已带后缀的规范化大小写。无法识别时返回 null。
String? canonicalCode(String raw) {
  var s = raw.trim().toUpperCase().replaceAll(RegExp(r'[\s="]'), '');
  if (s.isEmpty) return null;
  final dotted = RegExp(r'^(\d{6})\.(SH|SZ|BJ)$').firstMatch(s);
  if (dotted != null) return s;
  final prefixed = RegExp(r'^(SH|SZ|BJ)(\d{6})$').firstMatch(s);
  if (prefixed != null) return '${prefixed.group(2)}.${prefixed.group(1)}';
  // 去掉 Excel 丢失的前导 0
  if (RegExp(r'^\d{1,6}$').hasMatch(s)) s = s.padLeft(6, '0');
  if (!RegExp(r'^\d{6}$').hasMatch(s)) return null;
  final p1 = s[0];
  if (s.startsWith('92') || p1 == '4' || p1 == '8') return '$s.BJ';
  if (p1 == '6' || p1 == '5' || p1 == '9') return '$s.SH';
  if (p1 == '0' || p1 == '1' || p1 == '2' || p1 == '3') return '$s.SZ';
  return null;
}

/// 场内基金（ETF / LOF）：免印花税、免过户费。
bool isFundCode(String code) {
  final c = code.split('.').first;
  return c.startsWith('51') ||
      c.startsWith('52') ||
      c.startsWith('56') ||
      c.startsWith('58') ||
      c.startsWith('15') ||
      c.startsWith('16');
}

class FeeRates {
  const FeeRates({
    this.commission = 0.00025,
    this.minCommission = 5,
    this.stampTax = 0.0005,
    this.transferFee = 0.00001,
  });
  final double commission;
  final double minCommission;
  final double stampTax;
  final double transferFee;
}

class Fees {
  const Fees({this.commission = 0, this.stampTax = 0, this.transferFee = 0});
  final double commission;
  final double stampTax;
  final double transferFee;

  double get total => commission + stampTax + transferFee;

  static const zero = Fees();
}

double round2(double v) => (v * 100).roundToDouble() / 100;

/// 按账户费率计算一笔交易的费用：佣金（有最低）、印花税（仅股票卖出）、过户费（股票双向）。
Fees calcFees(FeeRates r, TradeSide side, String code, double amount) {
  if (side != TradeSide.buy && side != TradeSide.sell) return Fees.zero;
  final fund = isFundCode(code);
  final commission = amount * r.commission;
  return Fees(
    commission: round2(commission < r.minCommission ? r.minCommission : commission),
    stampTax: side == TradeSide.sell && !fund ? round2(amount * r.stampTax) : 0,
    transferFee: fund ? 0 : round2(amount * r.transferFee),
  );
}
