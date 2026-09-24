import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../Theme/WithMeTheme.dart';
import 'MascotExpression.dart';
import 'MascotPainter.dart';

/// How the companion spends its time.
enum MascotBehavior {
  /// Stays put, but alive: breathes, blinks, fidgets with its hands, and
  /// reacts whenever [WithMeAvatar.expression] changes.
  idle,

  /// The home screen routine: a wave hello, then wandering the width of the
  /// stage - stopping now and then to wave again or to plop onto its behind
  /// and get back up.
  roam,
}

/// The With Me companion, drawn and animated.
///
/// ## About the art
///
/// The V1 document ships no character art - the mascot existed only baked
/// into its screenshots, one pose, one face. That could not wave, walk or
/// look sad, so the app draws the character itself ([MascotPainter]): the
/// same leaf crown, hibiscus, lei and belly swirl, with limbs and a face
/// that move. Every animation here is a function from time to a
/// [MascotPose].
///
/// Reduced motion (the platform setting, or [animate] false) holds a still
/// pose that still shows the current [expression].
class WithMeAvatar extends StatefulWidget {
  const WithMeAvatar({
    super.key,
    this.expression = MascotExpression.idle,
    this.size = 180,
    this.speaking = false,
    this.animate = true,
    this.behavior = MascotBehavior.idle,
    this.onTap,
  });

  final MascotExpression expression;

  /// The character's width; it stands [size] * 1.4 tall. When roaming, the
  /// widget takes the full width it is given and the character walks it.
  final double size;

  /// Moves the mouth while the companion is "talking".
  final bool speaking;

  /// Off for reduced motion and for tests that need a still frame.
  final bool animate;

  final MascotBehavior behavior;

  final VoidCallback? onTap;

  static const double aspect =
      MascotPainter.designHeight / MascotPainter.designWidth;

  @override
  State<WithMeAvatar> createState() => _WithMeAvatarState();
}

class _WithMeAvatarState extends State<WithMeAvatar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  late final ValueNotifier<MascotFrame> _frame =
      ValueNotifier(MascotFrame(_poseAt(0)));

  /// Seconds since the avatar appeared.
  double _t = 0;

  /// When [WithMeAvatar.expression] last changed, for the reaction.
  double? _reactedAt;

  /// Stage width while roaming, for pacing the walk.
  double _stage = 0;

  bool get _moving =>
      widget.animate && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant WithMeAvatar old) {
    super.didUpdateWidget(old);
    if (old.expression != widget.expression) _reactedAt = _t;
    _syncTicker();
    _frame.value = _frameAt(_t);
  }

  void _syncTicker() {
    if (_moving && !_ticker.isActive) {
      _ticker.start();
    } else if (!_moving && _ticker.isActive) {
      _ticker.stop();
      _frame.value = _frameAt(_t);
    }
  }

  void _tick(Duration elapsed) {
    _t = elapsed.inMicroseconds / 1e6;
    _frame.value = _frameAt(_t);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Choreography
  // ---------------------------------------------------------------------------

  MascotFrame _frameAt(double t) {
    if (widget.behavior == MascotBehavior.roam && _moving) {
      return _Routine(stageFraction: _walkPace).frameAt(t, _idle);
    }
    return MascotFrame(_poseAt(t));
  }

  /// Seconds to cross the whole stage, so the walk keeps a steady pace
  /// whatever the screen width.
  double get _walkPace {
    final travel = math.max(1.0, _stage - widget.size);
    return (travel / 55).clamp(2.2, 6.0);
  }

  MascotPose _idle(double t, {MascotFace? face}) =>
      _poseAt(t, faceOverride: face);

  /// The standing pose for [widget.expression] at time [t]: breath, blinks,
  /// fidgeting hands, then whatever the expression and a fresh reaction add.
  MascotPose _poseAt(double t, {MascotFace? faceOverride}) {
    if (!_movingSafe) {
      return _expressionPose(widget.expression, 0, 0.5);
    }

    final breath = 0.5 - 0.5 * math.cos(2 * math.pi * t / 3.4);
    final base = _expressionPose(widget.expression, t, breath);

    // Blinks at an irregular-looking but repeatable rhythm, sometimes twice.
    final cycle = (t / 3.7).floor();
    final phase = t - cycle * 3.7;
    double blink = _pulse(phase, 3.52, 0.16);
    if (cycle % 3 == 1) blink = math.max(blink, _pulse(phase, 3.18, 0.14));

    // Hands never quite still - the "alive, waiting" look.
    final fidgetL = 0.07 * math.sin(t * 1.9) + 0.04 * math.sin(t * 3.1 + 1);
    final fidgetR = 0.07 * math.sin(t * 1.6 + 1.3) + 0.04 * math.sin(t * 2.7);
    // An occasional glance around.
    final lookX = 3.2 * _smoothSquare(math.sin(t * 0.55));

    var pose = _copy(
      base,
      breath: breath,
      blink: math.max(base.blink, blink),
      leftArm: base.leftArm + fidgetL,
      rightArm: base.rightArm + fidgetR,
      tilt: base.tilt + 0.02 * math.sin(t * 0.9),
      look: base.look + Offset(lookX, 0),
      talk: widget.speaking ? 0.5 + 0.5 * math.sin(t * 14) : 0,
      face: faceOverride,
    );

    final since = _reactedAt == null ? null : t - _reactedAt!;
    if (since != null && since >= 0 && since < 1.2) {
      pose = _react(pose, widget.expression, since);
    }
    return pose;
  }

  /// A still frame in reduced motion, and the first frame before the ticker.
  bool get _movingSafe => mounted ? _moving : false;

  /// What each expression looks like, before the idle motion is layered on.
  MascotPose _expressionPose(MascotExpression e, double t, double breath) {
    return switch (e) {
      MascotExpression.idle => const MascotPose(),
      MascotExpression.happy =>
        MascotPose(face: MascotFace.happy, lift: -1.5 * breath),
      MascotExpression.listening =>
        const MascotPose(headTilt: -0.07, look: Offset(-1.5, 0)),
      MascotExpression.thinking => MascotPose(
          face: MascotFace.thinking,
          headTilt: 0.05,
          rightArm: 0.9,
          thought: (t * 0.6) % 1.0 + 0.001,
        ),
      MascotExpression.encouraging => MascotPose(
          face: MascotFace.wink,
          rightArm: 2.3 + 0.3 * math.sin(t * 9),
          headTilt: -0.05,
        ),
      MascotExpression.celebrating => MascotPose(
          face: MascotFace.joy,
          leftArm: 2.2 + 0.25 * math.sin(t * 9),
          rightArm: 2.2 - 0.25 * math.sin(t * 9),
          lift: -9 * math.sin(t * 5).abs(),
          sparkle: (t * 0.8) % 1.0 + 0.001,
        ),
      MascotExpression.concerned =>
        const MascotPose(face: MascotFace.sad, headTilt: 0.05),
      MascotExpression.sad => const MascotPose(
          face: MascotFace.sad,
          headTilt: 0.07,
          squash: 0.1,
          leftArm: -0.1,
          rightArm: -0.1,
        ),
      MascotExpression.smirk =>
        const MascotPose(face: MascotFace.smirk, headTilt: -0.08),
    };
  }

  /// The beat right after the expression changes: a hop for good news, a
  /// slump for hard news, a shrug for middling.
  MascotPose _react(MascotPose p, MascotExpression e, double s) {
    switch (e) {
      case MascotExpression.happy:
      case MascotExpression.celebrating:
        final hop = s < 0.5 ? -15 * math.sin(math.pi * s / 0.5) : 0.0;
        final land = s >= 0.5 && s < 0.7 ? 0.3 * math.sin(math.pi * (s - 0.5) / 0.2) : 0.0;
        final arms = s < 0.9 ? 1.7 * math.sin(math.pi * s / 0.9) : 0.0;
        return _copy(
          p,
          lift: p.lift + hop,
          squash: p.squash + land,
          leftArm: p.leftArm + arms,
          rightArm: p.rightArm + arms,
          face: MascotFace.joy,
        );
      case MascotExpression.sad:
      case MascotExpression.concerned:
        final sink = s < 0.4 ? _ease(s / 0.4) : 1 - 0.4 * _ease((s - 0.4) / 0.8);
        return _copy(
          p,
          squash: p.squash + 0.12 * sink,
          headTilt: p.headTilt + 0.05 * sink,
          lift: p.lift + 2 * sink,
        );
      case MascotExpression.smirk:
        final shrug = s < 0.7 ? math.sin(math.pi * s / 0.7) : 0.0;
        return _copy(
          p,
          leftArm: p.leftArm + 0.45 * shrug,
          rightArm: p.rightArm + 0.45 * shrug,
          headTilt: p.headTilt - 0.06 * shrug,
          lift: p.lift - 3 * shrug,
        );
      default:
        final bob = s < 0.4 ? -4 * math.sin(math.pi * s / 0.4) : 0.0;
        return _copy(p, lift: p.lift + bob);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size * WithMeAvatar.aspect;
    Widget art;

    if (widget.behavior == MascotBehavior.roam) {
      art = LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : widget.size;
          _stage = width;
          return CustomPaint(
            size: Size(width, height),
            painter: MascotPainter(
              frame: _frame,
              roam: true,
              characterWidth: widget.size,
            ),
          );
        },
      );
    } else {
      art = CustomPaint(
        size: Size(widget.size, height),
        painter: MascotPainter(frame: _frame),
      );
    }

    art = ExcludeSemantics(child: art);
    if (widget.onTap == null) return art;
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: art,
    );
  }
}

/// The home screen's loop, as a list of beats. Each beat owns a stretch of
/// time and says where the character stands and how it moves.
class _Routine {
  _Routine({required this.stageFraction});

  /// Seconds to walk the full stage.
  final double stageFraction;

  static const double _centre = 0.5;

  List<_Beat> get _beats => [
        const _Beat.wave(2.8, at: _centre),
        _Beat.walk(stageFraction * 0.5, from: _centre, to: 1),
        const _Beat.rest(1.1, at: 1),
        const _Beat.fall(3.4, at: 1),
        const _Beat.rest(0.8, at: 1),
        _Beat.walk(stageFraction, from: 1, to: 0),
        const _Beat.rest(0.9, at: 0),
        const _Beat.wave(2.2, at: 0),
        _Beat.walk(stageFraction * 0.5, from: 0, to: _centre),
        const _Beat.rest(1.6, at: _centre),
      ];

  MascotFrame frameAt(
    double t,
    MascotPose Function(double t, {MascotFace? face}) idle,
  ) {
    final beats = _beats;
    final total = beats.fold<double>(0, (sum, b) => sum + b.duration);
    var local = t % total;
    for (final beat in beats) {
      if (local < beat.duration) return beat.frame(local, t, idle);
      local -= beat.duration;
    }
    return beats.last.frame(0, t, idle);
  }
}

enum _BeatKind { rest, wave, walk, fall }

class _Beat {
  const _Beat.rest(this.duration, {required double at})
      : kind = _BeatKind.rest,
        from = at,
        to = at;
  const _Beat.wave(this.duration, {required double at})
      : kind = _BeatKind.wave,
        from = at,
        to = at;
  const _Beat.walk(this.duration, {required this.from, required this.to})
      : kind = _BeatKind.walk;
  const _Beat.fall(this.duration, {required double at})
      : kind = _BeatKind.fall,
        from = at,
        to = at;

  final _BeatKind kind;
  final double duration;
  final double from;
  final double to;

  MascotFrame frame(
    double s,
    double t,
    MascotPose Function(double t, {MascotFace? face}) idle,
  ) {
    switch (kind) {
      case _BeatKind.rest:
        return MascotFrame(idle(t), x: from);

      case _BeatKind.wave:
        // Arm up, a few waves, arm down - with a wink.
        final up = _envelope(s, duration, 0.35);
        final base = idle(t, face: up > 0.5 ? MascotFace.wink : null);
        return MascotFrame(
          _copy(
            base,
            rightArm: base.rightArm + up * (2.2 + 0.35 * math.sin(s * 10)),
            headTilt: base.headTilt - 0.06 * up,
            lift: base.lift - 2 * up * math.sin(s * 10).abs(),
          ),
          x: from,
        );

      case _BeatKind.walk:
        final progress = _ease(s / duration);
        final phase = s * 2 * math.pi * 1.9;
        final base = idle(t);
        return MascotFrame(
          _copy(
            base,
            stepping: true,
            step: phase,
            lift: base.lift - 3.5 * math.sin(phase).abs(),
            tilt: base.tilt + 0.075 * math.sin(phase),
            leftArm: 0.25 + 0.3 * math.sin(phase),
            rightArm: 0.25 - 0.3 * math.sin(phase),
            face: MascotFace.happy,
          ),
          x: from + (to - from) * progress,
        );

      case _BeatKind.fall:
        return MascotFrame(_fall(s, t, idle), x: from);
    }
  }

  /// Trip, plop, sit there seeing stars, spring back up, shake it off.
  static MascotPose _fall(
    double s,
    double t,
    MascotPose Function(double t, {MascotFace? face}) idle,
  ) {
    final base = idle(t);
    // Stumble: arms flail, surprised.
    if (s < 0.4) {
      final k = s / 0.4;
      return _copy(
        base,
        face: MascotFace.surprised,
        leftArm: 1.8 * k + 0.4 * math.sin(s * 30),
        rightArm: 1.8 * k - 0.4 * math.sin(s * 30),
        tilt: -0.12 * k,
        lift: -4 * math.sin(math.pi * k),
      );
    }
    // Drop onto the behind.
    if (s < 0.65) {
      final k = _easeIn((s - 0.4) / 0.25);
      return _copy(
        base,
        face: MascotFace.surprised,
        sit: k,
        leftArm: 1.8 - 0.6 * k,
        rightArm: 1.8 - 0.6 * k,
        tilt: -0.12 * (1 - k),
      );
    }
    // Bounce on landing.
    if (s < 0.9) {
      final k = (s - 0.65) / 0.25;
      return _copy(
        base,
        face: MascotFace.dazed,
        sit: 1,
        squash: 0.35 * math.sin(math.pi * k),
        lift: -3 * math.sin(math.pi * k),
        leftArm: 1.2 - 0.8 * k,
        rightArm: 1.2 - 0.8 * k,
        stars: k,
        step: t * 3,
      );
    }
    // Sit a moment, dazed.
    if (s < 2.1) {
      return _copy(
        base,
        face: MascotFace.dazed,
        sit: 1,
        leftArm: 0.4,
        rightArm: 0.4,
        tilt: 0.05 * math.sin(s * 5),
        headTilt: 0.08 * math.sin(s * 5),
        stars: 1,
        step: t * 3,
      );
    }
    // Spring back up.
    if (s < 2.6) {
      final k = _ease((s - 2.1) / 0.5);
      return _copy(
        base,
        face: MascotFace.happy,
        sit: 1 - k,
        lift: -10 * math.sin(math.pi * k),
        leftArm: 0.4 + 1.2 * math.sin(math.pi * k),
        rightArm: 0.4 + 1.2 * math.sin(math.pi * k),
        stars: 1 - k,
        step: t * 3,
      );
    }
    // Shake it off, sheepish grin.
    final k = (s - 2.6) / (3.4 - 2.6);
    final damp = 1 - k;
    return _copy(
      base,
      face: MascotFace.joy,
      tilt: 0.1 * damp * math.sin(s * 22),
      headTilt: -0.06 * damp,
    );
  }
}

// -----------------------------------------------------------------------------
// Easing helpers
// -----------------------------------------------------------------------------

double _ease(double x) => Curves.easeInOut.transform(x.clamp(0.0, 1.0));
double _easeIn(double x) => Curves.easeIn.transform(x.clamp(0.0, 1.0));

/// 0 -> 1 -> 0 over [width] seconds, starting at [start].
double _pulse(double t, double start, double width) {
  final x = (t - start) / width;
  if (x <= 0 || x >= 1) return 0;
  return math.sin(math.pi * x);
}

/// Ramps up over [ramp] seconds, holds, ramps down over the last [ramp].
double _envelope(double s, double duration, double ramp) {
  if (s < ramp) return _ease(s / ramp);
  if (s > duration - ramp) return _ease((duration - s) / ramp);
  return 1;
}

/// A sine flattened toward -1 / 1, so a glance holds before moving back.
double _smoothSquare(double x) => (x * 2.2).clamp(-1.0, 1.0).toDouble();

MascotPose _copy(
  MascotPose p, {
  MascotFace? face,
  double? breath,
  double? blink,
  double? leftArm,
  double? rightArm,
  double? lift,
  double? tilt,
  double? headTilt,
  double? squash,
  double? sit,
  double? step,
  bool? stepping,
  Offset? look,
  double? talk,
  double? stars,
  double? sparkle,
  double? thought,
}) =>
    MascotPose(
      face: face ?? p.face,
      breath: breath ?? p.breath,
      blink: blink ?? p.blink,
      leftArm: leftArm ?? p.leftArm,
      rightArm: rightArm ?? p.rightArm,
      lift: lift ?? p.lift,
      tilt: tilt ?? p.tilt,
      headTilt: headTilt ?? p.headTilt,
      squash: squash ?? p.squash,
      sit: sit ?? p.sit,
      step: step ?? p.step,
      stepping: stepping ?? p.stepping,
      look: look ?? p.look,
      talk: talk ?? p.talk,
      stars: stars ?? p.stars,
      sparkle: sparkle ?? p.sparkle,
      thought: thought ?? p.thought,
    );

/// The circular head-and-shoulders crop used in the header lockup and on the
/// menu and profile screens. A still - one blink per screen would be a
/// ticker per screen for very little.
class WithMeAvatarBadge extends StatelessWidget {
  const WithMeAvatarBadge({
    super.key,
    this.size = 40,
    this.expression = MascotExpression.idle,
    this.animate = true,
  });

  final double size;
  final MascotExpression expression;

  /// Unused - the badge is a still. Kept so callers need not change.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final face = switch (expression) {
      MascotExpression.happy || MascotExpression.celebrating => MascotFace.happy,
      MascotExpression.sad || MascotExpression.concerned => MascotFace.sad,
      MascotExpression.smirk => MascotFace.smirk,
      MascotExpression.encouraging => MascotFace.wink,
      _ => MascotFace.neutral,
    };
    return ExcludeSemantics(
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: ColoredBox(
            color: WithMeColors.tealSoft,
            child: CustomPaint(painter: _BadgePainter(face)),
          ),
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  _BadgePainter(this.face);

  final MascotFace face;

  @override
  void paint(Canvas canvas, Size size) {
    // Frame the head: 128 design units wide, centred at (100, 120) once the
    // painter's headroom is added. Aim a little above centre so the leaf
    // crown peeks in at the top.
    final zoom = size.width / 170;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(zoom);
    canvas.translate(-100, -105);
    MascotPainter.paintPose(
      canvas,
      const Size(MascotPainter.designWidth, MascotPainter.designHeight),
      MascotPose(face: face),
    );
  }

  @override
  bool shouldRepaint(_BadgePainter old) => old.face != face;
}
