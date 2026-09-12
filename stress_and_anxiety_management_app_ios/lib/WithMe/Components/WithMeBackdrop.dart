import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The sunset-beach backdrop every With Me screen sits on.
///
/// Painted rather than shipped as a photo: it is a few kilobytes of code
/// instead of a few megabytes of JPEG, it scales to every device without
/// banding, and the horizon can be tuned to keep contrast under the text.
///
/// Everything here is deliberately low-contrast and blurred. The backdrop is
/// scenery, not subject matter — if any element reads as a distinct shape on
/// top of the content, it is wrong.
class WithMeBackdrop extends StatelessWidget {
  const WithMeBackdrop({
    super.key,
    required this.child,
    this.dimmed = false,
  });

  final Widget child;

  /// Softens the backdrop further when dense content sits on top of it.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: WithMeColors.sunset,
              // Sky to 0.44, horizon glow to 0.58, sea to 0.80, then sand.
              stops: [0.0, 0.30, 0.52, 0.72, 1.0],
            ),
          ),
        ),
        const Positioned.fill(child: CustomPaint(painter: _SceneryPainter())),
        if (dimmed)
          DecoratedBox(
            decoration: BoxDecoration(
              color: WithMeColors.sand.withValues(alpha: 0.55),
            ),
          ),
        child,
      ],
    );
  }
}

/// A high, soft sun; a barely-there headland on the horizon; a few lines of
/// surf low in the frame.
class _SceneryPainter extends CustomPainter {
  const _SceneryPainter();

  /// Where sky meets sea, as a fraction of height.
  static const double _horizon = 0.56;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _sun(canvas, w, h);
    _headland(canvas, w, h);
    _surf(canvas, w, h);
  }

  /// Sits high in the sky so it never collides with content in the middle of
  /// the screen, and has no hard edge.
  void _sun(Canvas canvas, double w, double h) {
    final centre = Offset(w * 0.76, h * 0.16);

    canvas.drawCircle(
      centre,
      w * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF0D2).withValues(alpha: 0.75),
            const Color(0xFFFFE9C4).withValues(alpha: 0.18),
            const Color(0xFFFFE9C4).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: centre, radius: w * 0.42)),
    );

    // A soft core, blurred so it reads as glare rather than a drawn disc.
    canvas.drawCircle(
      centre,
      w * 0.06,
      Paint()
        ..color = const Color(0xFFFFF8E8).withValues(alpha: 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05),
    );
  }

  /// Distant land, drawn as one smooth silhouette sitting on the horizon.
  void _headland(Canvas canvas, double w, double h) {
    final y = h * _horizon;

    final path = Path()
      ..moveTo(0, y)
      ..lineTo(0, y - h * 0.045)
      ..cubicTo(
        w * 0.06, y - h * 0.075,
        w * 0.13, y - h * 0.085,
        w * 0.20, y - h * 0.048,
      )
      ..cubicTo(
        w * 0.26, y - h * 0.020,
        w * 0.31, y - h * 0.004,
        w * 0.38, y,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF9FB9B3).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  /// Three lines of surf easing toward the shore, fading as they come forward.
  void _surf(Canvas canvas, double w, double h) {
    for (var i = 0; i < 3; i++) {
      final y = h * (_horizon + 0.06 + i * 0.055);
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x < w; x += w / 8) {
        path.quadraticBezierTo(
          x + w / 16,
          y + math.sin(i * 1.7 + x / w * math.pi * 2) * 3.5,
          x + w / 8,
          y,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22 - i * 0.055)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 - i * 0.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter oldDelegate) => false;
}
