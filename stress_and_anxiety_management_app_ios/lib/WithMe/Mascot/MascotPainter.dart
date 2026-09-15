import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';
import 'MascotExpression.dart';

/// Draws the With Me companion.
///
/// Everything is laid out in a fixed 200 x 250 design space and scaled to the
/// widget's size, so the character stays proportional at any dimension — a
/// 36 px chat avatar and a 300 px hero use the same code path.
///
/// Draw order, back to front:
///   arms -> body -> feet -> belly tattoo -> lei -> head -> leaf crown ->
///   hibiscus -> face -> overlays (thought dots, sparkles)
class MascotPainter extends CustomPainter {
  MascotPainter({
    required this.expression,
    required this.breath,
    required this.blink,
    required this.gesture,
    required this.talk,
  });

  /// Current emotional state.
  final MascotExpression expression;

  /// 0 -> 1 -> 0 across one slow breath cycle.
  final double breath;

  /// 0 = eyes fully open, 1 = eyes fully closed.
  final double blink;

  /// 0 -> 1 -> 0 for arm waves and celebration hops.
  final double gesture;

  /// 0 -> 1 -> 0 mouth movement while the companion is "speaking".
  final double talk;

  static const double _dw = 200;
  /// Tall enough to hold the leaf crown above the head and the contact
  /// shadow below the feet without clipping either.
  static const double _dh = 280;

  /// The character sits this far down the design box, leaving headroom
  /// for the crown.
  static const double _dropY = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _dw, size.height / _dh);
    canvas.save();
    // Centre the design box inside whatever box we were given.
    canvas.translate(
      (size.width - _dw * scale) / 2,
      (size.height - _dh * scale) / 2,
    );
    canvas.scale(scale);
    canvas.translate(0, _dropY);

    // A celebrating mascot hops; everything else stays planted.
    final hop = expression == MascotExpression.celebrating
        ? -10 * math.sin(gesture * math.pi)
        : 0.0;

    // Breathing: the body swells very slightly and settles. Subtle on purpose.
    final swell = 1 + 0.018 * breath;

    canvas.save();
    canvas.translate(0, hop);

    _drawArms(canvas);

    // Breathing is applied about the character's feet so it looks like it is
    // rising from the ground rather than growing from the middle.
    canvas.save();
    canvas.translate(100, 230);
    canvas.scale(1 + 0.012 * breath, swell);
    canvas.translate(-100, -230);

    _drawFeet(canvas);
    _drawBody(canvas);
    _drawTattoo(canvas);
    _drawHead(canvas);
    _drawLei(canvas);
    canvas.restore();

    _drawLeafCrown(canvas);
    _drawHibiscus(canvas);
    _drawFace(canvas);

    canvas.restore();

    if (expression == MascotExpression.thinking) _drawThoughtDots(canvas);
    if (expression == MascotExpression.celebrating) _drawSparkles(canvas);

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Paint get _skinPaint => Paint()
    ..shader = const RadialGradient(
      center: Alignment(-0.35, -0.45),
      radius: 1.05,
      colors: [
        WithMeColors.bodyLight,
        WithMeColors.bodyMid,
        WithMeColors.bodyDeep,
      ],
      stops: [0.0, 0.55, 1.0],
    ).createShader(const Rect.fromLTWH(20, 20, 160, 210));

  void _drawBody(Canvas canvas) {
    // Soft contact shadow on the sand.
    canvas.drawOval(
      const Rect.fromLTWH(48, 222, 104, 20),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 175),
        width: 112,
        height: 104,
      ),
      _skinPaint,
    );
  }

  void _drawFeet(Canvas canvas) {
    final paint = Paint()..color = WithMeColors.bodyDeep;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(76, 224), width: 38, height: 24),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(124, 224), width: 38, height: 24),
      paint,
    );
  }

  void _drawArms(Canvas canvas) {
    // Deliberately a shade darker than the body's edge, otherwise the
    // arms disappear into the gradient and the character reads as a blob.
    final paint = Paint()..color = WithMeColors.bodyShade;

    // Left arm rests against the body.
    canvas.save();
    canvas.translate(38, 172);
    canvas.rotate(0.18);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 30, height: 62),
      paint,
    );
    canvas.restore();

    // Right arm lifts and waves for the gesturing expressions.
    final double lift = switch (expression) {
      MascotExpression.encouraging => 1.0,
      MascotExpression.celebrating => 1.0,
      _ => 0.0,
    };
    // -0.2 rad resting, swinging up to roughly -1.5 rad when raised.
    final wave = expression.gestures ? math.sin(gesture * math.pi * 2) * 0.28 : 0.0;
    final angle = -0.2 - lift * 1.25 + wave;

    canvas.save();
    canvas.translate(162, 172);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -18), width: 30, height: 62),
      paint,
    );
    // A little mitten hand at the end of the raised arm.
    if (lift > 0) {
      canvas.drawCircle(const Offset(0, -50), 15, paint);
    }
    canvas.restore();

    // Celebrating throws the left arm up too.
    if (expression == MascotExpression.celebrating) {
      canvas.save();
      canvas.translate(38, 172);
      canvas.rotate(0.2 + 1.25 - wave);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -18), width: 30, height: 62),
        paint,
      );
      canvas.drawCircle(const Offset(0, -50), 15, paint);
      canvas.restore();
    }
  }

  void _drawHead(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 98),
        width: 128,
        height: 120,
      ),
      _skinPaint,
    );
  }

  /// The koru spiral on the belly, echoing the Polynesian wave motif.
  void _drawTattoo(Canvas canvas) {
    final paint = Paint()
      ..color = WithMeColors.tattoo.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const cx = 100.0;
    const cy = 192.0;
    // An outward spiral: radius grows as the angle sweeps.
    for (var i = 0; i <= 46; i++) {
      final t = i / 46;
      final a = t * math.pi * 2.6 + 2.2;
      final r = 4 + t * 26;
      final p = Offset(cx + math.cos(a) * r, cy + math.sin(a) * r * 0.82);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);

    // A second, smaller wave curl to the side.
    final curl = Path()
      ..moveTo(58, 186)
      ..quadraticBezierTo(66, 172, 78, 180)
      ..quadraticBezierTo(86, 186, 80, 194);
    canvas.drawPath(curl, paint..strokeWidth = 5);
  }

  // ---------------------------------------------------------------------------
  // Botanicals
  // ---------------------------------------------------------------------------

  void _drawLeafCrown(Canvas canvas) {
    // Three leaves fanning from the crown, the middle one tallest.
    _leaf(canvas, const Offset(100, 42), -0.12, 1.0);
    _leaf(canvas, const Offset(100, 46), -0.95, 0.82);
    _leaf(canvas, const Offset(100, 46), 0.75, 0.86);
  }

  void _leaf(Canvas canvas, Offset base, double angle, double scale) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    // The crown sways very slightly with the breath.
    canvas.rotate(angle + breath * 0.05);
    canvas.scale(scale);

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-26, -30, 0, -58)
      ..quadraticBezierTo(26, -30, 0, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [WithMeColors.leafDeep, WithMeColors.leaf],
        ).createShader(const Rect.fromLTWH(-26, -58, 52, 58)),
    );

    // Midrib.
    canvas.drawLine(
      const Offset(0, -3),
      const Offset(0, -52),
      Paint()
        ..color = WithMeColors.leafDeep.withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _drawHibiscus(Canvas canvas) {
    const center = Offset(44, 74);
    const petalCount = 5;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (var i = 0; i < petalCount; i++) {
      final a = (i / petalCount) * math.pi * 2 - math.pi / 2;
      canvas.save();
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -13), width: 19, height: 24),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [WithMeColors.hibiscus, WithMeColors.hibiscusDeep],
          ).createShader(const Rect.fromLTWH(-10, -26, 20, 26)),
      );
      canvas.restore();
    }

    // Stamen: a short stalk with a pollen tip.
    canvas.drawLine(
      Offset.zero,
      const Offset(9, -11),
      Paint()
        ..color = WithMeColors.lei
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      const Offset(10, -12),
      3.4,
      Paint()..color = const Color(0xFFF2B33F),
    );
    canvas.drawCircle(
      Offset.zero,
      4,
      Paint()..color = WithMeColors.hibiscusDeep.withValues(alpha: 0.6),
    );
    canvas.restore();
  }

  /// Plumeria lei sitting across the shoulders.
  void _drawLei(Canvas canvas) {
    const count = 7;
    for (var i = 0; i < count; i++) {
      final t = i / (count - 1);
      // Flowers follow a shallow arc dipping in the middle.
      final x = 46 + t * 108;
      final y = 143 + math.sin(t * math.pi) * 16;
      _plumeria(canvas, Offset(x, y), 9.5 - (t - 0.5).abs() * 3);
    }
  }

  void _plumeria(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i / 5) * math.pi * 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -radius * 0.55),
          width: radius * 0.95,
          height: radius * 1.25,
        ),
        Paint()..color = const Color(0xFFFFF6E2),
      );
      canvas.restore();
    }
    canvas.drawCircle(
      Offset.zero,
      radius * 0.42,
      Paint()..color = WithMeColors.lei,
    );
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // Face
  // ---------------------------------------------------------------------------

  void _drawFace(Canvas canvas) {
    // Listening leans the head toward the user.
    final tilt = expression == MascotExpression.listening ? -0.06 : 0.0;

    canvas.save();
    canvas.translate(100, 98);
    canvas.rotate(tilt);
    canvas.translate(-100, -98);

    _drawBlush(canvas);
    _drawEyes(canvas);
    _drawBrows(canvas);
    _drawMouth(canvas);

    canvas.restore();
  }

  void _drawBlush(Canvas canvas) {
    final strong = expression == MascotExpression.happy ||
        expression == MascotExpression.celebrating ||
        expression == MascotExpression.encouraging;

    final paint = Paint()
      ..color = WithMeColors.blush.withValues(alpha: strong ? 0.55 : 0.34)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 116), width: 26, height: 15),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(148, 116), width: 26, height: 15),
      paint,
    );
  }

  void _drawEyes(Canvas canvas) {
    // Thinking glances up and to the side.
    final look = expression == MascotExpression.thinking
        ? const Offset(3.5, -3)
        : Offset.zero;

    // Celebrating uses happy arcs instead of round eyes.
    if (expression == MascotExpression.celebrating) {
      _happyArcEye(canvas, const Offset(74, 100));
      _happyArcEye(canvas, const Offset(126, 100));
      return;
    }

    // Encouraging winks with the eye on the same side as the raised arm.
    if (expression == MascotExpression.encouraging) {
      _roundEye(canvas, const Offset(74, 100), look, blink);
      _happyArcEye(canvas, const Offset(126, 100));
      return;
    }

    _roundEye(canvas, const Offset(74, 100), look, blink);
    _roundEye(canvas, const Offset(126, 100), look, blink);
  }

  void _roundEye(Canvas canvas, Offset center, Offset look, double lid) {
    const rx = 14.5;
    const ry = 17.5;
    // Blinking squashes the eye vertically rather than hiding it.
    final double open = (1 - lid).clamp(0.06, 1.0).toDouble();

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: rx * 2,
        height: ry * 2 * open,
      ),
      Paint()..color = WithMeColors.eye,
    );

    // Once the lid is most of the way down there is nothing left to detail.
    if (open < 0.35) return;

    // Iris crescent gives the eye some depth.
    canvas.drawOval(
      Rect.fromCenter(
        center: center + look * 0.5 + const Offset(0, 3),
        width: rx * 1.5,
        height: ry * 1.5 * open,
      ),
      Paint()..color = WithMeColors.eyeIris.withValues(alpha: 0.55),
    );

    // Two highlights: a large one up-left, a small one down-right.
    canvas.drawCircle(
      center + look + const Offset(-4.5, -6),
      4.6 * open,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center + look + const Offset(5, 6),
      2.2 * open,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  void _happyArcEye(Canvas canvas, Offset center) {
    final path = Path()
      ..moveTo(center.dx - 14, center.dy + 4)
      ..quadraticBezierTo(center.dx, center.dy - 14, center.dx + 14, center.dy + 4);
    canvas.drawPath(
      path,
      Paint()
        ..color = WithMeColors.eye
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawBrows(Canvas canvas) {
    // Only the states that need them get brows; the resting face is bare,
    // which is what keeps it looking soft.
    if (expression != MascotExpression.concerned &&
        expression != MascotExpression.sad &&
        expression != MascotExpression.thinking) {
      return;
    }

    final paint = Paint()
      ..color = WithMeColors.bodyShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (expression == MascotExpression.concerned) {
      // Inner ends lift — the universal "worried" shape.
      canvas.drawLine(const Offset(60, 74), const Offset(86, 68), paint);
      canvas.drawLine(const Offset(140, 74), const Offset(114, 68), paint);
    } else if (expression == MascotExpression.sad) {
      // Sadness reads better with brows that slope upward toward the centre.
      canvas.drawLine(const Offset(60, 70), const Offset(86, 76), paint);
      canvas.drawLine(const Offset(140, 70), const Offset(114, 76), paint);
    } else {
      // Thinking: one brow raised.
      canvas.drawLine(const Offset(60, 72), const Offset(86, 74), paint);
      canvas.drawLine(const Offset(140, 66), const Offset(114, 70), paint);
    }
  }

  void _drawMouth(Canvas canvas) {
    final paint = Paint()
      ..color = WithMeColors.eye
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    const cx = 100.0;
    const cy = 128.0;

    switch (expression) {
      case MascotExpression.celebrating:
      case MascotExpression.happy:
        // Open, filled smile.
        final open = 11.0 + talk * 5;
        final path = Path()
          ..moveTo(cx - 16, cy - 2)
          ..quadraticBezierTo(cx, cy + open + 6, cx + 16, cy - 2)
          ..quadraticBezierTo(cx, cy + 2, cx - 16, cy - 2)
          ..close();
        canvas.drawPath(path, Paint()..color = WithMeColors.eye);
        break;

      case MascotExpression.concerned:
        // A small, level, slightly downturned line — never a cartoon frown.
        canvas.drawPath(
          Path()
            ..moveTo(cx - 11, cy + 4)
            ..quadraticBezierTo(cx, cy - 2, cx + 11, cy + 4),
          paint,
        );
        break;

      case MascotExpression.sad:
        // A clearer frown used after a negative option is chosen.
        canvas.drawPath(
          Path()
            ..moveTo(cx - 13, cy + 7)
            ..quadraticBezierTo(cx, cy - 3, cx + 13, cy + 7),
          paint,
        );
        break;

      case MascotExpression.thinking:
        // Off-centre pucker.
        canvas.drawPath(
          Path()
            ..moveTo(cx - 6, cy + 2)
            ..quadraticBezierTo(cx + 3, cy + 7, cx + 12, cy),
          paint,
        );
        break;

      case MascotExpression.idle:
      case MascotExpression.listening:
      case MascotExpression.encouraging:
        // Gentle closed smile; widens a little while speaking.
        final w = 13.0 + talk * 3;
        final d = 9.0 + talk * 4;
        canvas.drawPath(
          Path()
            ..moveTo(cx - w, cy - 2)
            ..quadraticBezierTo(cx, cy + d, cx + w, cy - 2),
          paint,
        );
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Overlays
  // ---------------------------------------------------------------------------

  void _drawThoughtDots(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      // Each dot fades in turn, so the cluster reads as "still working".
      final phase = (gesture + i * 0.22) % 1.0;
      final double opacity =
          math.sin(phase * math.pi).clamp(0.0, 1.0).toDouble();
      canvas.drawCircle(
        Offset(150 + i * 13.0, 44 - i * 11.0),
        3.2 + i * 1.3,
        Paint()..color = WithMeColors.teal.withValues(alpha: opacity * 0.75),
      );
    }
  }

  void _drawSparkles(Canvas canvas) {
    const points = [Offset(38, 56), Offset(168, 74), Offset(150, 30)];
    for (var i = 0; i < points.length; i++) {
      final phase = (gesture + i * 0.3) % 1.0;
      final double scale =
          math.sin(phase * math.pi).clamp(0.0, 1.0).toDouble();
      if (scale <= 0.02) continue;

      final p = points[i];
      final r = 7.0 * scale;
      final paint = Paint()
        ..color = WithMeColors.lei.withValues(alpha: scale)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(p.dx - r, p.dy), Offset(p.dx + r, p.dy), paint);
      canvas.drawLine(Offset(p.dx, p.dy - r), Offset(p.dx, p.dy + r), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MascotPainter old) =>
      old.expression != expression ||
      old.breath != breath ||
      old.blink != blink ||
      old.gesture != gesture ||
      old.talk != talk;
}
