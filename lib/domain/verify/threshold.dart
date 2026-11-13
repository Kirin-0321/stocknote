import '../../data/market/models.dart';

/// 判定阈值（spec 3.3.2）：涨跌幅在 ±阈值内算"震荡"。单位：百分比（0.5 = ±0.5%）。
///
/// 优先级：单条判断覆盖 > 标的类型 + 周期 > 标的类型 > 全局。
class ThresholdConfig {
  const ThresholdConfig({
    this.global = 0.5,
    this.byType = defaultByType,
    this.byTypeHorizon = const {},
  });

  final double global;
  final Map<InstrumentType, double> byType;

  /// key: (类型, 周期 code)
  final Map<(InstrumentType, String), double> byTypeHorizon;

  static const defaultByType = {
    InstrumentType.marketIndex: 0.3,
    InstrumentType.sector: 0.5,
    InstrumentType.etf: 0.5,
    InstrumentType.stock: 1.0,
  };

  double resolve(InstrumentType type, String horizon, {double? override}) =>
      override ?? byTypeHorizon[(type, horizon)] ?? byType[type] ?? global;

  ThresholdConfig copyWith({
    double? global,
    Map<InstrumentType, double>? byType,
    Map<(InstrumentType, String), double>? byTypeHorizon,
  }) =>
      ThresholdConfig(
        global: global ?? this.global,
        byType: byType ?? this.byType,
        byTypeHorizon: byTypeHorizon ?? this.byTypeHorizon,
      );
}
