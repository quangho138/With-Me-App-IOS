import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// Which face the companion is pulling.
enum MascotFace {
  /// Round eyes, soft closed smile. The resting face.
  neutral,

  /// Open smile, stronger blush.
  happy,

  /// Happy-arc eyes and an open smile - a win.
  joy,

  /// Worried brows, heavy lids, a small frown.
  sad,

  /// One brow up, a lopsided half-smile.
  smirk,

  /// One eye shut, the other round - goes with a wave.
  wink,

  /// Wide eyes, brows up, a small "o" - the moment of a fall.
  surprised,

  /// Swirly eyes and a wobbly mouth - just after landing.
  dazed,

  /// Eyes up and aside, one brow raised, an off-centre pucker.
  thinking,
}

/// Everything that moves, as numbers. The painter draws exactly this, so an
/// animation is only ever a function from time to a [MascotPose].
///
/// Units are the painter's 200 x 280 design space; angles are radians.
@immutable
class MascotPose {
  const MascotPose({
    this.face = MascotFace.neutral,
    this.breath = 0,
    this.blink = 0,
    this.leftArm = 0,
    this.rightArm = 0,
    this.lift = 0,
    this.tilt = 0,
    this.headTilt = 0,
    this.squash = 0,
    this.sit = 0,
    this.step = 0,
    this.stepping = false,
    this.look = Offset.zero,
    this.talk = 0,
    this.stars = 0,
    this.sparkle = 0,
    this.thought = 0,
  });

  final MascotFace face;

  /// 0 -> 1 -> 0 across one breath.
  final double breath;

  /// 0 eyes open, 1 shut.
  final double blink;

  /// How far each arm is raised from resting at the side. 0 hangs, about 1.2
  /// is level with the shoulder, 2.4 is overhead. Mirrored, so positive
  /// always means up and outward.
  final double leftArm;
  final double rightArm;

  /// Vertical offset of the whole body; negative is up (a hop).
  final double lift;

  /// Whole-body lean, pivoting on the feet.
  final double tilt;

  /// Head lean, pivoting on the neck.
  final double headTilt;

  /// Squash on landing or slumping: wider and shorter. 0 is none.
  final double squash;

  /// 0 standing, 1 sat on the ground with the feet out in front.
  final double sit;

  /// Walk cycle phase in radians; only read while [stepping].
  final double step;
  final bool stepping;

  /// Where the pupils look, a few units either way.
  final Offset look;

  /// 0 -> 1 mouth movement while speaking.
  final double talk;

  /// 0 -> 1 fade of the dizzy stars circling the head after a fall.
  final double stars;

  /// Phase of the celebration sparkles, or 0 for none.
  final double sparkle;

  /// Phase of the thought dots, or 0 for none.
  final double thought;
}

/// Draws the With Me companion.
///
/// Laid out in a fixed 200 x 280 design space and scaled to the box it is
/// given, so a 30 pt header badge and a 200 pt hero share one code path.
///
/// Reads its pose from [frame] on every paint, so an animation can drive it
/// through a [ValueListenable] without rebuilding any widgets. With [roam],
/// the box is a stage wider than the character, and [MascotFrame.x] slides
/// it from the left edge (0) to the right (1).
class MascotPainter extends CustomPainter {
  MascotPainter({
    required this.frame,
    this.roam = false,
    this.characterWidth,
  }) : super(repaint: frame);

  /// A single fixed pose - a still, or a test.
  MascotPainter.still(MascotPose pose)
      : this(frame: ValueNotifier(MascotFrame(pose)));

  final ValueListenable<MascotFrame> frame;
  final bool roam;

  /// The character's width when [roam]ing; its height is the box's.
  final double? characterWidth;

  static const double designWidth = 200;
  static const double designHeight = 280;

  /// The character sits this far down the design box, leaving headroom for
  /// the crown and for arms raised overhead.
  static const double _dropY = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final current = frame.value;
    var box = size;
    canvas.save();
    if (roam && characterWidth != null) {
      // Arms flung out reach past the character's own box, so the walk
      // stops short of each edge by that much.
      final inset = characterWidth! * 0.14;
      final travel = math.max(0.0, size.width - characterWidth! - 2 * inset);
      canvas.translate(inset + travel * current.x.clamp(0.0, 1.0), 0);
      box = Size(characterWidth!, size.height);
    }
    paintPose(canvas, box, current.pose);
    canvas.restore();
  }

  /// Draws [pose] centred in a [box]-sized area at the canvas origin.
  static void paintPose(Canvas canvas, Size box, MascotPose pose) {
    final scale = math.min(box.width / designWidth, box.height / designHeight);
    canvas.save();
    canvas.translate(
      (box.width - designWidth * scale) / 2,
      (box.height - designHeight * scale) / 2,
    );
    canvas.scale(scale);
    canvas.translate(0, _dropY);
    _Figure(canvas, pose).draw();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MascotPainter old) =>
      old.frame != frame ||
      old.roam != roam ||
      old.characterWidth != characterWidth;
}

/// One moment of the companion: a pose, and where it stands on its stage.
@immutable
class MascotFrame {
  const MascotFrame(this.pose, {this.x = 0.5});

  final MascotPose pose;

  /// 0 left edge of the stage, 1 right edge. Only read when roaming.
  final double x;
}

/// The actual drawing, for one pose.
class _Figure {
  _Figure(this.canvas, this.pose);

  final Canvas canvas;
  final MascotPose pose;

  /// Where the feet meet the ground - the pivot for leaning and squashing.
  static const Offset _ground = Offset(100, 230);

  /// The pivot for the head's own lean.
  static const Offset _neck = Offset(100, 150);

  void draw() {
    _drawShadow();

    canvas.save();
    // Sitting lowers the body to the ground; lift raises it for a hop.
    canvas.translate(0, pose.lift + pose.sit * 26);
    _about(_ground, () {
      canvas.rotate(pose.tilt);
      final squash = pose.squash + pose.sit * 0.08;
      canvas.scale(1 + squash * 0.12, 1 - squash * 0.12);
    });

    _drawArms();

    canvas.save();
    // Breathing swells the body from the feet, so it rises rather than grows.
    _about(_ground, () {
      canvas.scale(1 + 0.012 * pose.breath, 1 + 0.018 * pose.breath);
    });
    if (pose.sit < 0.35) _drawFeet();
    _drawBody();
    _drawTattoo();
    canvas.restore();

    canvas.save();
    _about(_neck, () => canvas.rotate(pose.headTilt));
    _drawHead();
    _drawLeafCrown();
    _drawHibiscus();
    _drawFace();
    canvas.restore();

    // The lei sits across the neck, over the head's lower edge.
    _drawLei();

    canvas.restore();

    // Sat down, the feet stick out in front of the body, toward the viewer.
    if (pose.sit >= 0.35) {
      canvas.save();
      canvas.translate(0, pose.lift);
      _drawFeet();
      canvas.restore();
    }

    if (pose.stars > 0) _drawStars();
    if (pose.thought > 0) _drawThoughtDots();
    if (pose.sparkle > 0) _drawSparkles();
  }

  void _about(Offset pivot, VoidCallback transform) {
    canvas.translate(pivot.dx, pivot.dy);
    transform();
    canvas.translate(-pivot.dx, -pivot.dy);
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Paint get _skin => Paint()
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

  void _drawShadow() {
    // Stays on the ground; shrinks as the body leaves it.
    final up = (-pose.lift).clamp(0.0, 30.0);
    final w = 104 * (1 - up / 60) + pose.sit * 18;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 232), width: w, height: 20),
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, 0.13 * (1 - up / 45))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  void _drawBody() {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 175), width: 112, height: 104),
      _skin,
    );
  }

  void _drawFeet() {
    final paint = Paint()..color = WithMeColors.bodyDeep;
    final sit = pose.sit;
    for (final side in const [-1.0, 1.0]) {
      // Walking lifts one foot while the other carries the weight.
      final phase = pose.stepping ? math.sin(pose.step) * side : 0.0;
      final raise = pose.stepping ? math.max(0.0, phase) * 7 : 0.0;
      canvas.save();
      canvas.translate(100 + side * (24 + sit * 12), 224 - raise - sit * 2);
      // Sat down, the soles turn out toward the viewer.
      canvas.rotate(side * sit * 0.55);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 38 + sit * 4,
          height: 24 + sit * 6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawArms() {
    // A shade darker than the body's edge, or the arms melt into it.
    final paint = Paint()..color = WithMeColors.bodyShade;
    _arm(paint, shoulder: const Offset(42, 148), raise: pose.leftArm, side: -1);
    _arm(paint, shoulder: const Offset(158, 148), raise: pose.rightArm, side: 1);
  }

  void _arm(
    Paint paint, {
    required Offset shoulder,
    required double raise,
    required double side,
  }) {
    canvas.save();
    canvas.translate(shoulder.dx, shoulder.dy);
    // Resting, each arm hangs a little away from the body; raising swings it
    // up and out on its own side.
    canvas.rotate(-side * (0.2 + raise));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 24), width: 30, height: 62),
      paint,
    );
    // A mitten hand shows once the arm is clear of the body.
    if (raise > 0.8) {
      canvas.drawCircle(const Offset(0, 50), 14, paint);
    }
    canvas.restore();
  }

  void _drawHead() {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 98), width: 128, height: 120),
      _skin,
    );
  }

  /// The koru spiral on the belly, echoing the Polynesian wave motif.
  void _drawTattoo() {
    final paint = Paint()
      ..color = WithMeColors.tattoo.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const cx = 100.0;
    const cy = 192.0;
    for (var i = 0; i <= 46; i++) {
      final t = i / 46;
      final a = t * math.pi * 2.6 + 2.2;
      final r = 4 + t * 26;
      final p = Offset(cx + math.cos(a) * r, cy + math.sin(a) * r * 0.82);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    final curl = Path()
      ..moveTo(58, 186)
      ..quadraticBezierTo(66, 172, 78, 180)
      ..quadraticBezierTo(86, 186, 80, 194);
    canvas.drawPath(curl, paint..strokeWidth = 5);
  }

  // ---------------------------------------------------------------------------
  // Botanicals
  // ---------------------------------------------------------------------------

  void _drawLeafCrown() {
    _leaf(const Offset(100, 42), -0.12, 1.0);
    _leaf(const Offset(100, 46), -0.95, 0.82);
    _leaf(const Offset(100, 46), 0.75, 0.86);
  }

  void _leaf(Offset base, double angle, double scale) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    // The crown sways with the breath and trails a hop a little.
    canvas.rotate(angle + pose.breath * 0.05 - pose.lift * 0.004);
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

  void _drawHibiscus() {
    const center = Offset(44, 74);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((i / 5) * math.pi * 2 - math.pi / 2);
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

  /// Plumeria lei across the shoulders.
  void _drawLei() {
    const count = 7;
    for (var i = 0; i < count; i++) {
      final t = i / (count - 1);
      final x = 46 + t * 108;
      final y = 143 + math.sin(t * math.pi) * 16;
      _plumeria(Offset(x, y), 9.5 - (t - 0.5).abs() * 3);
    }
  }

  void _plumeria(Offset center, double radius) {
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

  static const Offset _leftEye = Offset(74, 100);
  static const Offset _rightEye = Offset(126, 100);

  Paint get _ink => Paint()
    ..color = WithMeColors.eye
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.2
    ..strokeCap = StrokeCap.round;

  void _drawFace() {
    _drawBlush();
    _drawEyes();
    _drawBrows();
    _drawMouth();
  }

  void _drawBlush() {
    final strong = pose.face == MascotFace.happy ||
        pose.face == MascotFace.joy ||
        pose.face == MascotFace.wink ||
        pose.face == MascotFace.dazed;
    final paint = Paint()
      ..color = WithMeColors.blush.withValues(
        alpha: strong ? 0.55 : (pose.face == MascotFace.sad ? 0.22 : 0.34),
      )
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

  void _drawEyes() {
    switch (pose.face) {
      case MascotFace.joy:
        _arcEye(_leftEye);
        _arcEye(_rightEye);
      case MascotFace.wink:
        _roundEye(_leftEye, pose.look, pose.blink);
        _arcEye(_rightEye);
      case MascotFace.dazed:
        _swirlEye(_leftEye, 1);
        _swirlEye(_rightEye, -1);
      case MascotFace.surprised:
        _roundEye(_leftEye, pose.look, 0, grow: 1.12);
        _roundEye(_rightEye, pose.look, 0, grow: 1.12);
      case MascotFace.sad:
        // Heavy lids and a downward glance.
        final lid = math.max(pose.blink, 0.28);
        _roundEye(_leftEye, pose.look + const Offset(0, 2.5), lid);
        _roundEye(_rightEye, pose.look + const Offset(0, 2.5), lid);
      case MascotFace.smirk:
        // Knowing: both lids a touch lower, eyes cut to the side.
        final lid = math.max(pose.blink, 0.18);
        _roundEye(_leftEye, pose.look + const Offset(3, 0), lid);
        _roundEye(_rightEye, pose.look + const Offset(3, 0), lid);
      case MascotFace.thinking:
        _roundEye(_leftEye, pose.look + const Offset(3.5, -3), pose.blink);
        _roundEye(_rightEye, pose.look + const Offset(3.5, -3), pose.blink);
      case MascotFace.neutral:
      case MascotFace.happy:
        _roundEye(_leftEye, pose.look, pose.blink);
        _roundEye(_rightEye, pose.look, pose.blink);
    }
  }

  void _roundEye(Offset center, Offset look, double lid, {double grow = 1}) {
    final rx = 14.5 * grow;
    final ry = 17.5 * grow;
    // Lids squash the eye vertically rather than hiding it.
    final double open = (1 - lid).clamp(0.06, 1.0).toDouble();
    // Lowered lids close from the top: keep the eye's bottom edge where it is.
    final c = center + Offset(0, ry * (1 - open));

    canvas.drawOval(
      Rect.fromCenter(center: c, width: rx * 2, height: ry * 2 * open),
      Paint()..color = WithMeColors.eye,
    );
    if (open < 0.35) return;
    canvas.drawOval(
      Rect.fromCenter(
        center: c + look * 0.5 + const Offset(0, 3),
        width: rx * 1.5,
        height: ry * 1.5 * open,
      ),
      Paint()..color = WithMeColors.eyeIris.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      c + look + const Offset(-4.5, -6),
      4.6 * open,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      c + look + const Offset(5, 6),
      2.2 * open,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  void _arcEye(Offset center) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 14, center.dy + 4)
        ..quadraticBezierTo(
            center.dx, center.dy - 14, center.dx + 14, center.dy + 4),
      _ink..strokeWidth = 5.5,
    );
  }

  void _swirlEye(Offset center, double turn) {
    final path = Path();
    for (var i = 0; i <= 30; i++) {
      final t = i / 30;
      final a = turn * t * math.pi * 3.2;
      final r = 2 + t * 11;
      final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, _ink..strokeWidth = 3.4);
  }

  void _drawBrows() {
    final paint = Paint()
      ..color = WithMeColors.bodyShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    switch (pose.face) {
      case MascotFace.sad:
        // Inner ends up: the universal worried shape.
        canvas.drawLine(const Offset(64, 75), const Offset(86, 68), paint);
        canvas.drawLine(const Offset(142, 76), const Offset(114, 68), paint);
      case MascotFace.smirk:
        // One brow cocked, the other flat.
        canvas.drawLine(const Offset(66, 73), const Offset(86, 73), paint);
        canvas.drawLine(const Offset(114, 66), const Offset(140, 61), paint);
      case MascotFace.thinking:
        canvas.drawLine(const Offset(66, 72), const Offset(86, 74), paint);
        canvas.drawLine(const Offset(140, 66), const Offset(114, 70), paint);
      case MascotFace.surprised:
        canvas.drawLine(const Offset(66, 63), const Offset(86, 60), paint);
        canvas.drawLine(const Offset(140, 64), const Offset(114, 60), paint);
      default:
        // The resting face is bare; that is what keeps it soft.
        break;
    }
  }

  void _drawMouth() {
    const cx = 100.0;
    const cy = 128.0;
    final ink = _ink;

    switch (pose.face) {
      case MascotFace.happy:
      case MascotFace.joy:
        final open = 11.0 + pose.talk * 5;
        canvas.drawPath(
          Path()
            ..moveTo(cx - 16, cy - 2)
            ..quadraticBezierTo(cx, cy + open + 6, cx + 16, cy - 2)
            ..quadraticBezierTo(cx, cy + 2, cx - 16, cy - 2)
            ..close(),
          Paint()..color = WithMeColors.eye,
        );
      case MascotFace.sad:
        canvas.drawPath(
          Path()
            ..moveTo(cx - 13, cy + 7)
            ..quadraticBezierTo(cx, cy - 4, cx + 13, cy + 7),
          ink,
        );
      case MascotFace.smirk:
        // Flat on the left, curling up on the right.
        canvas.drawPath(
          Path()
            ..moveTo(cx - 12, cy + 2)
            ..quadraticBezierTo(cx + 2, cy + 6, cx + 15, cy - 5),
          ink,
        );
      case MascotFace.surprised:
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(cx, cy + 3), width: 11, height: 13),
          ink..strokeWidth = 3.6,
        );
      case MascotFace.dazed:
        final path = Path()..moveTo(cx - 12, cy + 2);
        for (var i = 1; i <= 4; i++) {
          path.quadraticBezierTo(
            cx - 12 + (i - 0.5) * 6,
            cy + 2 + (i.isOdd ? 4 : -4),
            cx - 12 + i * 6,
            cy + 2,
          );
        }
        canvas.drawPath(path, ink..strokeWidth = 3.4);
      case MascotFace.thinking:
        canvas.drawPath(
          Path()
            ..moveTo(cx - 6, cy + 2)
            ..quadraticBezierTo(cx + 3, cy + 7, cx + 12, cy),
          ink,
        );
      case MascotFace.neutral:
      case MascotFace.wink:
        final w = 13.0 + pose.talk * 3;
        final d = 9.0 + pose.talk * 4;
        canvas.drawPath(
          Path()
            ..moveTo(cx - w, cy - 2)
            ..quadraticBezierTo(cx, cy + d, cx + w, cy - 2),
          ink,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Overlays
  // ---------------------------------------------------------------------------

  /// Three little stars orbiting the head after a fall.
  void _drawStars() {
    final paint = Paint()
      ..color = WithMeColors.lei.withValues(alpha: pose.stars.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 3; i++) {
      final a = pose.step * 1.0 + i * math.pi * 2 / 3;
      final c = Offset(100 + math.cos(a) * 58, 36 + pose.sit * 26 + math.sin(a) * 12);
      final path = Path();
      for (var k = 0; k < 10; k++) {
        final r = k.isEven ? 7.0 : 3.0;
        final t = k * math.pi / 5 - math.pi / 2;
        final p = c + Offset(math.cos(t) * r, math.sin(t) * r);
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), paint);
    }
  }

  void _drawThoughtDots() {
    for (var i = 0; i < 3; i++) {
      final phase = (pose.thought + i * 0.22) % 1.0;
      final double opacity = math.sin(phase * math.pi).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(150 + i * 13.0, 44 - i * 11.0),
        3.2 + i * 1.3,
        Paint()..color = WithMeColors.teal.withValues(alpha: opacity * 0.75),
      );
    }
  }

  void _drawSparkles() {
    const points = [Offset(38, 56), Offset(168, 74), Offset(150, 30)];
    for (var i = 0; i < points.length; i++) {
      final phase = (pose.sparkle + i * 0.3) % 1.0;
      final double s = math.sin(phase * math.pi).clamp(0.0, 1.0);
      if (s <= 0.02) continue;
      final p = points[i];
      final r = 7.0 * s;
      final paint = Paint()
        ..color = WithMeColors.lei.withValues(alpha: s)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(p.dx - r, p.dy), Offset(p.dx + r, p.dy), paint);
      canvas.drawLine(Offset(p.dx, p.dy - r), Offset(p.dx, p.dy + r), paint);
    }
  }
}
