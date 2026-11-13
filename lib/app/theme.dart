import 'package:material_ui/material_ui.dart';

/// 涨跌配色。A 股默认红涨绿跌，可在设置中切换（spec 4）。
@immutable
class MarketColors extends ThemeExtension<MarketColors> {
  const MarketColors({required this.up, required this.down, required this.flat});

  final Color up;
  final Color down;
  final Color flat;

  static const redUp = MarketColors(
    up: Color(0xFFE53935),
    down: Color(0xFF2E7D32),
    flat: Color(0xFF9E9E9E),
  );

  static const greenUp = MarketColors(
    up: Color(0xFF2E7D32),
    down: Color(0xFFE53935),
    flat: Color(0xFF9E9E9E),
  );

  Color of(num change) => change > 0 ? up : (change < 0 ? down : flat);

  @override
  MarketColors copyWith({Color? up, Color? down, Color? flat}) =>
      MarketColors(up: up ?? this.up, down: down ?? this.down, flat: flat ?? this.flat);

  @override
  MarketColors lerp(MarketColors? other, double t) {
    if (other == null) return this;
    return MarketColors(
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
      flat: Color.lerp(flat, other.flat, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness, {MarketColors market = MarketColors.redUp}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3F51B5),
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    extensions: [market],
  );
}
