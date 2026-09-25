import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Original vector landscapes; all motion is deterministic and loops gently.
class NatureScene extends CustomPainter {
  NatureScene({required this.sound, required this.time});
  final String sound;
  final double time;
  final Paint _paint = Paint();
  Color c(int hex) => Color(hex);
  void fill(Canvas canvas, Path path, Color color) {
    canvas.drawPath(
      path,
      _paint
        ..style = PaintingStyle.fill
        ..shader = null
        ..color = color,
    );
  }

  void line(Canvas canvas, Path path, Color color, double width) {
    canvas.drawPath(
      path,
      _paint
        ..shader = null
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
    _paint.style = PaintingStyle.fill;
  }

  void oval(Canvas canvas, Rect rect, Color color) {
    canvas.drawOval(
      rect,
      _paint
        ..shader = null
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 400, size.height / 440);
    final night = sound == 'Fire';
    final rain = sound == 'Rain';
    final sky = night
        ? [c(0xff122c3c), c(0xff42616a)]
        : rain
        ? [c(0xff8ebabb), c(0xffd1dfd4)]
        : [c(0xffc2e3dc), c(0xfff5dfbe)];
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 400, 440),
      _paint
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sky,
        ).createShader(const Rect.fromLTWH(0, 0, 400, 440)),
    );
    _paint.shader = null;
    if (night) {
      for (var i = 0; i < 35; i++) {
        oval(
          canvas,
          Rect.fromCircle(
            center: Offset((i * 73.0 + 19) % 400, (i * 37.0 + 11) % 210),
            radius: i % 4 == 0 ? 1.5 : .8,
          ),
          c(0xffffefcc).withValues(alpha: .45 + .2 * math.sin(time + i)),
        );
      }
      oval(canvas, const Rect.fromLTWH(307, 39, 38, 38), c(0xfff9e8c0));
      oval(canvas, const Rect.fromLTWH(296, 31, 38, 38), c(0xff203b49));
    } else {
      oval(
        canvas,
        const Rect.fromLTWH(280, 38, 58, 58),
        c(0xfffff1d0).withValues(alpha: .7),
      );
      for (var i = 0; i < 3; i++) {
        final x = (i * 159 + time * 1.8) % 520 - 70;
        oval(
          canvas,
          Rect.fromLTWH(x, 47.0 + i * 25, 106, 13),
          Colors.white.withValues(alpha: .22),
        );
      }
    }
    if (sound == 'Waves') {
      _waves(canvas);
    } else if (sound == 'None') {
      _quiet(canvas);
    } else {
      _woods(canvas, night: night, rain: rain);
    }
    if (sound == 'Birds') {
      _birds(canvas);
    }
    if (rain) {
      _rain(canvas);
    }
    if (night) {
      _fire(canvas);
    }
    canvas.restore();
  }

  void _quiet(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      fill(
        canvas,
        Path()
          ..moveTo(0, 315.0 + i * 35)
          ..quadraticBezierTo(100, 245.0 + i * 35, 235, 322.0 + i * 30)
          ..quadraticBezierTo(340, 365.0 + i * 20, 400, 315.0 + i * 30)
          ..lineTo(400, 440)
          ..lineTo(0, 440)
          ..close(),
        [c(0xffb4d1c3), c(0xff96bbad), c(0xff729f91)][i],
      );
    }
  }

  void _waves(Canvas canvas) {
    fill(
      canvas,
      Path()
        ..moveTo(0, 213)
        ..quadraticBezierTo(66, 181, 105, 214)
        ..quadraticBezierTo(142, 198, 192, 222)
        ..lineTo(400, 226)
        ..lineTo(400, 440)
        ..lineTo(0, 440)
        ..close(),
      c(0xff90bcb7),
    );
    for (var layer = 0; layer < 5; layer++) {
      final y = 244.0 + layer * 37;
      final path = Path()..moveTo(-10, y);
      for (var x = -10.0; x <= 410; x += 5) {
        path.lineTo(
          x,
          y +
              math.sin(
                    x / (51 + layer * 8) + time * (.35 + layer * .08) + layer,
                  ) *
                  (5 + layer * 2),
        );
      }
      final surf = Path.from(path);
      path
        ..lineTo(410, 440)
        ..lineTo(-10, 440)
        ..close();
      fill(
        canvas,
        path,
        [
          c(0xff6eadae),
          c(0xff559b9e),
          c(0xff82c0bd),
          c(0xffabd6cc),
          c(0xffe6d5b7),
        ][layer],
      );
      line(
        canvas,
        surf,
        c(0xfff7faf0).withValues(alpha: layer == 4 ? .9 : .43),
        layer == 4 ? 4 : 1.4,
      );
    }
    for (var i = 0; i < 13; i++) {
      final x = (i * 41.0) % 400;
      final y = 278.0 + (i * 17) % 90;
      line(
        canvas,
        Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 8, y + math.sin(time + i) * 2, x + 17, y),
        Colors.white.withValues(alpha: .26),
        1,
      );
    }
    for (var i = 0; i < 4; i++) {
      _bird(canvas, 48 + i * 19.0, 97 + math.sin(i + time * .3) * 8, .55);
    }
    oval(canvas, const Rect.fromLTWH(319, 416, 25, 9), c(0xffbfae95));
    oval(canvas, const Rect.fromLTWH(345, 410, 13, 6), c(0xffccbaa1));
  }

  void _tree(
    Canvas canvas,
    double x,
    double base,
    double height,
    Color color,
    double sway, {
    bool pine = false,
  }) {
    canvas.save();
    canvas.translate(x, base);
    canvas.rotate(sway);
    line(
      canvas,
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-3, -height * .5, 0, -height),
      color.withValues(alpha: .9),
      height * .037,
    );
    if (pine) {
      for (var j = 0; j < 4; j++) {
        final y = -height + j * height * .18;
        final width = height * (.15 + j * .055);
        fill(
          canvas,
          Path()
            ..moveTo(0, y)
            ..quadraticBezierTo(
              -width * .4,
              y + height * .22,
              -width,
              y + height * .35,
            )
            ..quadraticBezierTo(0, y + height * .30, width, y + height * .35)
            ..quadraticBezierTo(width * .4, y + height * .22, 0, y)
            ..close(),
          color,
        );
      }
    } else {
      for (var j = 0; j < 5; j++) {
        final dir = j.isEven ? -1 : 1;
        final y = -height * (.38 + j * .12);
        line(
          canvas,
          Path()
            ..moveTo(0, y + 24)
            ..lineTo(dir * height * .18, y),
          color,
          3,
        );
        oval(
          canvas,
          Rect.fromCenter(
            center: Offset(dir * height * .12, y - 12),
            width: height * .42,
            height: height * .29,
          ),
          color,
        );
      }
    }
    canvas.restore();
  }

  void _woods(Canvas canvas, {required bool night, required bool rain}) {
    for (var layer = 0; layer < 3; layer++) {
      final color = night
          ? [c(0xff35595b), c(0xff244849), c(0xff153a3b)][layer]
          : [c(0xffa3c7b7), c(0xff7da999), c(0xff527f70)][layer];
      final y = 282.0 + layer * 48;
      fill(
        canvas,
        Path()
          ..moveTo(0, y)
          ..quadraticBezierTo(115, y - 53, 215, y + 5)
          ..quadraticBezierTo(315, y - 29, 400, y - 8)
          ..lineTo(400, 440)
          ..lineTo(0, 440)
          ..close(),
        color,
      );
      for (var i = 0; i < 7; i++) {
        final x = i * 71.0 - 10 + layer * 19;
        if (rain && x > 145 && x < 285) continue;
        _tree(
          canvas,
          x,
          y + 12,
          105 + (i * 43 % 71).toDouble(),
          color,
          math.sin(time * .6 + i + layer) * .015,
          pine: night || rain || sound == 'Forest',
        );
      }
    }
    if (!night && !rain) {
      fill(
        canvas,
        Path()
          ..moveTo(210, 324)
          ..quadraticBezierTo(140, 370, 275, 440)
          ..lineTo(380, 440)
          ..quadraticBezierTo(205, 370, 210, 324),
        c(0xffd0cfaa).withValues(alpha: .5),
      );
      for (var i = 0; i < 12; i++) {
        final x = (i * 53 + time * 6) % 440 - 20;
        final y = 65 + (i * 71) % 320 + math.sin(time * .6 + i) * 9;
        oval(
          canvas,
          Rect.fromCenter(center: Offset(x, y), width: 5, height: 2),
          c(0xffedf0bf).withValues(alpha: .5),
        );
      }
    }
  }

  void _bird(Canvas canvas, double x, double y, double scale) {
    final flap = math.sin(time * 2 + x) * 3;
    line(
      canvas,
      Path()
        ..moveTo(x - 10 * scale, y - flap)
        ..quadraticBezierTo(x - 4 * scale, y - 5 * scale, x, y)
        ..quadraticBezierTo(
          x + 4 * scale,
          y - 5 * scale,
          x + 10 * scale,
          y - flap,
        ),
      c(0xff315c55),
      1.8 * scale,
    );
  }

  void _birds(Canvas canvas) {
    for (var i = 0; i < 5; i++) {
      _bird(
        canvas,
        (55 + i * 53.0 + time * 4) % 430 - 15,
        85 + i * 12.0 + math.sin(time * .6 + i) * 8,
        .75,
      );
    }
    line(
      canvas,
      Path()
        ..moveTo(0, 355)
        ..quadraticBezierTo(65, 360, 121, 325)
        ..moveTo(57, 352)
        ..lineTo(70, 328),
      c(0xff685d45),
      7,
    );
    oval(canvas, const Rect.fromLTWH(77, 327, 56, 23), c(0xff8f7750));
    for (var i = 0; i < 6; i++) {
      line(
        canvas,
        Path()
          ..moveTo(79, 331.0 + i * 2)
          ..quadraticBezierTo(104, 348.0 + i, 132, 330.0 + i * 2),
        c(0xffc9ad76),
        1.2,
      );
    }
    for (var i = 0; i < 2; i++) {
      final x = 91.0 + i * 21;
      oval(canvas, Rect.fromLTWH(x, 312, 17, 21), c(0xffe9c38c));
      oval(canvas, Rect.fromLTWH(x + 8, 314, 3, 3), c(0xff244b46));
      fill(
        canvas,
        Path()
          ..moveTo(x + 16, 318)
          ..lineTo(x + 23, 321)
          ..lineTo(x + 16, 324)
          ..close(),
        c(0xffcc8254),
      );
    }
  }

  void _rain(Canvas canvas) {
    canvas.save();
    canvas.translate(85, 0);
    fill(
      canvas,
      Path()
        ..moveTo(149, 276)
        ..lineTo(166, 214)
        ..lineTo(231, 228)
        ..lineTo(263, 282)
        ..lineTo(287, 371)
        ..lineTo(137, 377)
        ..close(),
      c(0xff73928d),
    );
    fill(
      canvas,
      Path()
        ..moveTo(191, 241)
        ..quadraticBezierTo(203, 307, 183, 360)
        ..lineTo(246, 364)
        ..quadraticBezierTo(218, 307, 223, 241)
        ..close(),
      c(0xffc5e1df),
    );
    for (var i = 0; i < 8; i++) {
      final y = 247 + (i * 19 + time * 34) % 106;
      line(
        canvas,
        Path()
          ..moveTo(198.0 + i % 3 * 6, y)
          ..lineTo(196.0 + i % 3 * 6, y + 17),
        Colors.white.withValues(alpha: .5),
        2,
      );
    }
    oval(canvas, const Rect.fromLTWH(125, 349, 185, 44), c(0xffa8d2cc));
    for (var i = 0; i < 4; i++) {
      final r = (i * 18 + time * 9) % 70;
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(216, 371),
          width: r * 2,
          height: r * .27,
        ),
        _paint
          ..color = Colors.white.withValues(alpha: (1 - r / 70) * .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    _paint.style = PaintingStyle.fill;
    canvas.restore();
    for (var i = 0; i < 65; i++) {
      final x = (i * 67.0) % 430;
      final y = (i * 43.0 + time * 110) % 470 - 20;
      line(
        canvas,
        Path()
          ..moveTo(x, y)
          ..lineTo(x - 4, y + 14),
        c(0xfff0f6ee).withValues(alpha: .26),
        .9,
      );
    }
  }

  void _fire(Canvas canvas) {
    final glow = const Rect.fromLTWH(86, 261, 228, 170);
    canvas.drawOval(
      glow,
      _paint
        ..shader = RadialGradient(
          colors: [c(0xffffbd68).withValues(alpha: .27), Colors.transparent],
        ).createShader(glow),
    );
    _paint.shader = null;
    for (var i = 0; i < 8; i++) {
      final a = i / 8 * math.pi * 2;
      oval(
        canvas,
        Rect.fromCenter(
          center: Offset(200 + math.cos(a) * 58, 386 + math.sin(a) * 13),
          width: 23,
          height: 13,
        ),
        c(0xff667776),
      );
    }
    line(
      canvas,
      Path()
        ..moveTo(168, 385)
        ..lineTo(231, 369)
        ..moveTo(172, 370)
        ..lineTo(229, 387),
      c(0xff775039),
      12,
    );
    for (var i = 0; i < 3; i++) {
      final wobble = math.sin(time * 3 + i * 2) * 7;
      final width = 36.0 - i * 9;
      final top = 293.0 + i * 24;
      fill(
        canvas,
        Path()
          ..moveTo(200, 386)
          ..cubicTo(200 - width * 1.7, 376, 200 - width, 343, 204 + wobble, top)
          ..cubicTo(185, top + 42, 200 + width * 1.8, 352, 200, 386)
          ..close(),
        [c(0xffdf8250), c(0xfff7b95f), c(0xffffe7a1)][i],
      );
    }
    for (var i = 0; i < 8; i++) {
      final rise = (time * 21 + i * 17) % 106;
      oval(
        canvas,
        Rect.fromCircle(
          center: Offset(
            200 + math.sin(i * 8 + time) * (rise * .22),
            348 - rise,
          ),
          radius: 1.5,
        ),
        c(0xffffd38c).withValues(alpha: (1 - rise / 106) * .8),
      );
    }
  }

  @override
  bool shouldRepaint(NatureScene oldDelegate) =>
      oldDelegate.time != time || oldDelegate.sound != sound;
}
