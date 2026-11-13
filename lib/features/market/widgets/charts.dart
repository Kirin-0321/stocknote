import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/format.dart';
import '../../../data/market/models.dart';
import 'market_widgets.dart';

/// HHmm → 交易分钟序号（09:30=0 … 11:30=120，13:01=121 … 15:00=240）。集合竞价返回 null。
int? minuteIndex(String hhmm) {
  final h = int.parse(hhmm.substring(0, 2));
  final m = int.parse(hhmm.substring(2, 4));
  final t = h * 60 + m;
  const open = 9 * 60 + 30, noon = 11 * 60 + 30, pm = 13 * 60, close = 15 * 60;
  if (t < open) return null;
  if (t <= noon) return t - open;
  if (t <= pm) return 120;
  if (t <= close) return 120 + (t - pm);
  return null;
}

/// 分时图：价格线 + 均价线 + 昨收基准线，纵轴以昨收为中心对称。
class IntradayChart extends StatelessWidget {
  const IntradayChart({super.key, required this.data, this.height = 220});

  final Intraday data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mc = marketColors(context);
    final pts = <FlSpot>[];
    final avg = <FlSpot>[];
    for (final p in data.points) {
      final x = minuteIndex(p.minute);
      if (x == null) continue;
      pts.add(FlSpot(x.toDouble(), p.price));
      if (p.avg != null && p.avg! > 0) avg.add(FlSpot(x.toDouble(), p.avg!));
    }
    if (pts.isEmpty) {
      return SizedBox(height: height, child: const Center(child: Text('暂无分时数据')));
    }
    final pre = data.preClose == 0 ? pts.first.y : data.preClose;
    final maxDev = pts.map((s) => (s.y - pre).abs()).reduce(math.max);
    final span = math.max(maxDev * 1.1, pre * 0.002);
    final color = mc.of(pts.last.y - pre);

    String axisLabel(double v) =>
        '${formatPrice(v)}\n${formatPct((v - pre) / pre * 100)}';

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 240,
          minY: pre - span,
          maxY: pre + span,
          clipData: const FlClipData.all(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final s in spots)
                  s.barIndex == 0
                      ? LineTooltipItem(
                          '${formatPrice(s.y)}  ${formatPct((s.y - pre) / pre * 100)}',
                          TextStyle(color: mc.of(s.y - pre), fontSize: 12))
                      : null,
              ],
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: true,
            verticalInterval: 60,
            horizontalInterval: span / 2,
            getDrawingHorizontalLine: (v) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.4),
              strokeWidth: (v - pre).abs() < span * 0.01 ? 1 : 0.5,
              dashArray: (v - pre).abs() < span * 0.01 ? [4, 4] : null,
            ),
            getDrawingVerticalLine: (_) =>
                FlLine(color: theme.dividerColor.withValues(alpha: 0.3), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: span,
                getTitlesWidget: (v, meta) => Text(axisLabel(v),
                    style: TextStyle(fontSize: 9, color: mc.of(v - pre), height: 1.1)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 60,
                reservedSize: 18,
                getTitlesWidget: (v, meta) => Text(
                  const {0: '09:30', 60: '10:30', 120: '11:30/13:00', 180: '14:00', 240: '15:00'}[v.toInt()] ?? '',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: pts,
              color: color,
              barWidth: 1.4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.08),
                cutOffY: pre,
                applyCutOffY: true,
              ),
            ),
            if (avg.isNotEmpty)
              LineChartBarData(
                spots: avg,
                color: Colors.amber.shade700,
                barWidth: 1,
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}

/// 日 K 蜡烛图 + MA5 / MA20（自绘）。
class CandleChart extends StatelessWidget {
  const CandleChart({super.key, required this.bars, this.height = 240, this.markers = const {}});

  final List<KBar> bars;
  final double height;

  /// 日期(yyyyMMdd) → 标记数量（日记条目），在 K 线下方画点。
  final Map<String, int> markers;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return SizedBox(height: height, child: const Center(child: Text('暂无 K 线数据')));
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _CandlePainter(
          bars: bars,
          colors: marketColors(context),
          grid: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          text: Theme.of(context).colorScheme.outline,
          marker: Theme.of(context).colorScheme.primary,
          markers: markers,
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  _CandlePainter({
    required this.bars,
    required this.colors,
    required this.grid,
    required this.text,
    required this.marker,
    required this.markers,
  });

  final List<KBar> bars;
  final MarketColors colors;
  final Color grid;
  final Color text;
  final Color marker;
  final Map<String, int> markers;

  List<double?> _ma(int n) {
    final out = <double?>[];
    var sum = 0.0;
    for (var i = 0; i < bars.length; i++) {
      sum += bars[i].close;
      if (i >= n) sum -= bars[i - n].close;
      out.add(i >= n - 1 ? sum / n : null);
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 4.0, right = 52.0, top = 8.0, bottom = 22.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final hi = bars.map((b) => b.high).reduce(math.max);
    final lo = bars.map((b) => b.low).reduce(math.min);
    final range = (hi - lo) == 0 ? 1 : hi - lo;
    double y(double v) => top + (hi - v) / range * h;
    final step = w / bars.length;
    final bodyW = math.max(1.0, step * 0.7);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 0.5;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 4; i++) {
      final v = hi - range * i / 4;
      final yy = y(v);
      canvas.drawLine(Offset(left, yy), Offset(left + w, yy), gridPaint);
      tp.text = TextSpan(text: formatPrice(v), style: TextStyle(fontSize: 9, color: text));
      tp.layout();
      tp.paint(canvas, Offset(left + w + 4, yy - tp.height / 2));
    }

    for (var i = 0; i < bars.length; i++) {
      final b = bars[i];
      final cx = left + step * (i + 0.5);
      final up = b.close >= b.open;
      final paint = Paint()
        ..color = up ? colors.up : colors.down
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, y(b.high)), Offset(cx, y(b.low)), paint);
      final rect = Rect.fromLTRB(cx - bodyW / 2, y(math.max(b.open, b.close)), cx + bodyW / 2,
          math.max(y(math.min(b.open, b.close)), y(math.max(b.open, b.close)) + 1));
      canvas.drawRect(rect, paint..style = up ? PaintingStyle.stroke : PaintingStyle.fill);
      if (!up) canvas.drawRect(rect, paint..style = PaintingStyle.fill);
      if (markers.containsKey(b.date)) {
        canvas.drawCircle(Offset(cx, top + h + 6), 2.5, Paint()..color = marker);
      }
    }

    void line(List<double?> vs, Color c) {
      final p = Path();
      var started = false;
      for (var i = 0; i < vs.length; i++) {
        final v = vs[i];
        if (v == null) continue;
        final pt = Offset(left + step * (i + 0.5), y(v));
        started ? p.lineTo(pt.dx, pt.dy) : p.moveTo(pt.dx, pt.dy);
        started = true;
      }
      canvas.drawPath(
          p,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }

    line(_ma(5), Colors.amber.shade700);
    line(_ma(20), Colors.purple.shade300);

    String md(String d) => '${d.substring(4, 6)}/${d.substring(6, 8)}';
    for (final i in [0, bars.length ~/ 2, bars.length - 1]) {
      tp.text = TextSpan(text: md(bars[i].date), style: TextStyle(fontSize: 9, color: text));
      tp.layout();
      final x = (left + step * (i + 0.5) - tp.width / 2).clamp(0.0, size.width - tp.width - right);
      tp.paint(canvas, Offset(x, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter old) =>
      old.bars != bars || old.markers != markers;
}

