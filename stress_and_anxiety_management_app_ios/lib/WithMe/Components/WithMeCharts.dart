import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// Charts for the dashboard section (`image32`-`image37`).
///
/// Drawn with `CustomPaint`. The shapes the design asks for are one donut,
/// three pies, a sparkline and a four-bar column — none of which is worth a
/// charting dependency, and the companion work so far has added none.

/// One slice of a pie or donut.
class Slice {
  const Slice(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

/// Donut with a label in the hole — the 30-day trigger breakdown on `image32`.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.centreLabel,
    this.size = 104,
    this.thickness = 22,
  });

  final List<Slice> slices;
  final String? centreLabel;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _PiePainter(slices, hole: thickness),
          ),
          if (centreLabel != null)
            Text(
              centreLabel!,
              style: WithMeText.option.copyWith(
                fontWeight: FontWeight.w700,
                color: WithMeColors.teal,
              ),
            ),
        ],
      ),
    );
  }
}

/// Solid pie — the triggers / signs / strategies breakdowns on `image33` and
/// `image34`.
class PieChart extends StatelessWidget {
  const PieChart({super.key, required this.slices, this.size = 104});

  final List<Slice> slices;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _PiePainter(slices),
      );
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.slices, {this.hole = 0});

  final List<Slice> slices;

  /// Ring thickness. Zero draws a solid pie.
  final double hole;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final radius = size.width / 2;
    final centre = Offset(radius, radius);

    if (hole > 0) {
      final r = radius - hole / 2;
      final rect = Rect.fromCircle(center: centre, radius: r);
      var start = -math.pi / 2;
      for (final slice in slices) {
        final sweep = 2 * math.pi * slice.value / total;
        canvas.drawArc(
          rect,
          start,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = hole
            ..color = slice.color,
        );
        start += sweep;
      }
      return;
    }

    final rect = Rect.fromCircle(center: centre, radius: radius);
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = 2 * math.pi * slice.value / total;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = slice.color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.hole != hole || old.slices != slices;
}

/// Two-column swatch legend under a chart.
class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.slices,
    this.columns = 2,
    this.showPercent = true,
  });

  final List<Slice> slices;
  final int columns;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    String text(Slice s) {
      if (!showPercent || total <= 0) return s.label;
      final pct = 100 * s.value / total;
      final rounded = (pct * 10).round() / 10;
      final shown = rounded == rounded.roundToDouble()
          ? rounded.toStringAsFixed(0)
          : rounded.toStringAsFixed(1);
      return '${s.label} $shown%';
    }

    return Wrap(
      spacing: WithMeSpace.md,
      runSpacing: WithMeSpace.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final slice in slices)
          SizedBox(
            width: columns == 1
                ? double.infinity
                : (WithMeSpace.contentWidth - 2 * WithMeSpace.lg) / columns -
                    WithMeSpace.md,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: slice.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    text(slice),
                    style: WithMeText.caption.copyWith(
                      color: WithMeColors.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Key-and-value list to the right of the donut on `image32`.
class ValueLegend extends StatelessWidget {
  const ValueLegend({super.key, required this.slices});

  final List<Slice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final slice in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: slice.color,
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: WithMeSpace.sm),
                Expanded(
                  child: Text(slice.label, style: WithMeText.option.copyWith(fontSize: 14)),
                ),
                Text(
                  total <= 0
                      ? '-'
                      : '${(100 * slice.value / total).round()}%',
                  style: WithMeText.option.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The stress-level sparkline on `image37`.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color = WithMeColors.coral,
    this.height = 56,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _SparklinePainter(values, color)),
      );
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - (values[i] - lo) / span);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}

/// The four-bar mood column on `image37`.
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.values,
    this.color = WithMeColors.mint,
    this.highlightLast = true,
    this.height = 56,
  });

  final List<double> values;
  final Color color;

  /// The design draws the most recent bar in full teal.
  final bool highlightLast;

  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);
    final hi = values.reduce(math.max);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: hi <= 0 ? 4 : (height * values[i] / hi).clamp(6, height),
                decoration: BoxDecoration(
                  color: highlightLast && i == values.length - 1
                      ? WithMeColors.teal
                      : color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
