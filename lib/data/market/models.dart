/// 行情领域模型（与数据源无关）。
///
/// 代码统一使用"规范代码"：`600519.SH`、`510300.SH`、`399001.SZ`、`899050.BJ`、
/// 东方财富板块 `BK1036.EM`、同花顺板块 `885338.TI`。
library;

enum InstrumentType {
  stock('stock', '个股'),
  etf('etf', 'ETF'),
  marketIndex('index', '指数'),
  sector('sector', '板块');

  const InstrumentType(this.code, this.label);
  final String code;
  final String label;

  static InstrumentType fromCode(String code) =>
      values.firstWhere((t) => t.code == code, orElse: () => stock);
}

class Quote {
  const Quote({
    required this.code,
    required this.name,
    required this.price,
    required this.preClose,
    this.open,
    this.high,
    this.low,
    this.volume,
    this.amount,
    this.time,
    this.approx = false,
  });

  final String code;
  final String name;
  final double price;

  /// 估算值（如由成分股等权推算的板块涨跌）
  final bool approx;
  final double preClose;
  final double? open;
  final double? high;
  final double? low;

  /// 成交量（股）
  final double? volume;

  /// 成交额（元）
  final double? amount;
  final DateTime? time;

  double get change => price - preClose;
  double get changePct => preClose == 0 ? 0 : (price - preClose) / preClose * 100;

  Map<String, dynamic> toSnapshotJson() => {
        'name': name,
        'price': price,
        'pct': double.parse(changePct.toStringAsFixed(3)),
        if (amount != null) 'amount': amount,
        if (approx) 'approx': true,
      };
}

class KBar {
  const KBar({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
    this.amount,
  });

  /// yyyyMMdd
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;
  final double? amount;
}

class IntradayPoint {
  const IntradayPoint({required this.minute, required this.price, this.avg, this.amount});

  /// HHmm，如 0931
  final String minute;
  final double price;
  final double? avg;

  /// 该分钟成交额（元）
  final double? amount;
}

class Intraday {
  const Intraday({required this.code, required this.preClose, required this.points, this.date});
  final String code;
  final double preClose;
  final List<IntradayPoint> points;

  /// yyyyMMdd
  final String? date;
}

class Breadth {
  const Breadth({required this.up, required this.down, required this.flat});
  final int up;
  final int down;
  final int flat;

  int get total => up + down + flat;

  Map<String, dynamic> toJson() => {'up': up, 'down': down, 'flat': flat};
}

class LimitStats {
  const LimitStats({required this.limitUp, required this.limitDown, required this.broken});
  final int limitUp;
  final int limitDown;

  /// 炸板（曾涨停后打开）
  final int broken;

  double? get brokenRate =>
      limitUp + broken == 0 ? null : broken / (limitUp + broken) * 100;

  Map<String, dynamic> toJson() => {'up': limitUp, 'down': limitDown, 'broken': broken};
}

class Turnover {
  const Turnover({required this.today, this.yesterdaySameTime, this.yesterdayTotal});

  /// 两市成交额（元）
  final double today;
  final double? yesterdaySameTime;
  final double? yesterdayTotal;

  /// 相对昨日同时段的变化（%）
  double? get changePct => yesterdaySameTime == null || yesterdaySameTime == 0
      ? null
      : (today - yesterdaySameTime!) / yesterdaySameTime! * 100;
}

enum SectorKind { industry, concept }

class RankItem {
  const RankItem({
    required this.code,
    required this.name,
    required this.changePct,
    this.price,
    this.amount,
    this.leaderName,
    this.leaderPct,
  });

  final String code;
  final String name;
  final double changePct;
  final double? price;
  final double? amount;
  final String? leaderName;
  final double? leaderPct;
}

class InstrumentInfo {
  const InstrumentInfo({
    required this.code,
    required this.name,
    required this.type,
    this.exchange,
    this.pinyin,
    this.listDate,
  });

  final String code;
  final String name;
  final InstrumentType type;
  final String? exchange;
  final String? pinyin;
  final String? listDate;
}

/// 看板默认展示的指数（spec 3.1.1）。
const defaultBoardIndices = [
  '000001.SH', // 上证指数
  '399001.SZ', // 深证成指
  '399006.SZ', // 创业板指
  '000300.SH', // 沪深300
  '000688.SH', // 科创50
  '899050.BJ', // 北证50
];

const indexShortNames = {
  '000001.SH': '上证指数',
  '399001.SZ': '深证成指',
  '399006.SZ': '创业板指',
  '000300.SH': '沪深300',
  '000688.SH': '科创50',
  '899050.BJ': '北证50',
  '000016.SH': '上证50',
  '000905.SH': '中证500',
  '000852.SH': '中证1000',
};

