import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// The poses the rendered companion has art for. Each is a frame in
/// `assets/v2/app/`, all registered to one another by
/// `tool/prepare_mascot_v2.py`, so swapping poses changes the expression
/// without the character jumping.
enum RealPose {
  /// Standing, one arm raised - the welcome screen.
  wave,

  /// Sitting, hugging a glowing heart, eyes closed and smiling.
  heart,

  /// Sitting, hand on chin.
  think,

  /// Sitting, both arms up, laughing.
  excited,

  /// Sitting, arms relaxed - waiting for an answer.
  idle,

  /// Worried brows, small frown.
  sad,

  /// Lopsided half-smile, one brow up.
  smirk,

  /// Big open smile.
  happy,
}

/// The V2 companion: the rendered 3D character from the reference, brought
/// to life.
///
/// Always: slow breathing, a faint sway, and blinks where the pose has a
/// blink frame. [RealPose.wave] swings the raised arm from the shoulder;
/// [RealPose.heart] makes the heart glow. Changing [pose] cross-fades to the
/// new frame and plays a reaction - a hop for happy and excited, a slump for
/// sad, a shrug for smirk.
///
/// Reduced motion (or [animate] false) shows a still of [pose].
class RealMascot extends StatefulWidget {
  const RealMascot({
    super.key,
    required this.pose,
    required this.height,
    this.animate = true,
  });

  final RealPose pose;

  /// The frame's height; its width follows at 640 : 900.
  final double height;

  final bool animate;

  static const double aspect = 640 / 900;

  static String _asset(String name) => 'assets/v2/app/mascot_$name.webp';

  /// Every frame, so a screen can warm the cache before it needs them.
  static const List<String> frames = [
    'idle',
    'idle_blink',
    'think',
    'think_blink',
    'heart',
    'excited',
    'sad',
    'smirk',
    'happy',
    'wave_body',
    'wave_body_blink',
    'wave_arm',
  ];

  static Future<void> precache(BuildContext context) => Future.wait([
    for (final f in frames) precacheImage(AssetImage(_asset(f)), context),
  ]);

  @override
  State<RealMascot> createState() => _RealMascotState();
}

class _RealMascotState extends State<RealMascot>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<double> _clock = ValueNotifier(0);

  /// When [RealMascot.pose] last changed, for the reaction.
  double? _changedAt;

  bool get _moving =>
      widget.animate &&
      !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RealMascot.precache(context);
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant RealMascot old) {
    super.didUpdateWidget(old);
    if (old.pose != widget.pose) _changedAt = _clock.value;
    _syncTicker();
  }

  void _syncTicker() {
    if (_moving && !_ticker.isActive) {
      _ticker.start();
    } else if (!_moving && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) => _clock.value = elapsed.inMicroseconds / 1e6;

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final w = h * RealMascot.aspect;

    return ExcludeSemantics(
      child: SizedBox(
        width: w,
        height: h,
        child: ValueListenableBuilder<double>(
          valueListenable: _clock,
          builder: (context, t, _) {
            final still = !_moving;
            final breath = still
                ? 0.0
                : 0.5 - 0.5 * math.cos(2 * math.pi * t / 3.6);
            final sway = still ? 0.0 : 0.012 * math.sin(t * 0.8);
            final reaction = still ? _Reaction.none : _reactionAt(t);

            return Transform.translate(
              offset: Offset(0, reaction.lift * h),
              child: Transform.rotate(
                angle: sway + reaction.tilt,
                alignment: Alignment.bottomCenter,
                child: Transform.scale(
                  scaleX: 1 + 0.006 * breath + reaction.squash * 0.5,
                  scaleY: 1 + 0.012 * breath - reaction.squash,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.bottomCenter,
                      children: [...previous, ?current],
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(widget.pose),
                      child: _poseLayers(t, still, w, h),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _frame(String name) => Image.asset(
    RealMascot._asset(name),
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
  );

  /// The layers for the current pose at time [t].
  Widget _poseLayers(double t, bool still, double w, double h) {
    final blink = still ? 0.0 : _blinkAt(t);

    Widget withBlink(String base, String? blinkFrame) => Stack(
      fit: StackFit.expand,
      children: [
        _frame(base),
        if (blinkFrame != null && blink > 0)
          Opacity(opacity: blink, child: _frame(blinkFrame)),
      ],
    );

    switch (widget.pose) {
      case RealPose.wave:
        // Bursts of waving with rests between; the arm never drops, it only
        // swings about the shoulder, toward the head, where the cut is clean.
        final cycle = t % 4.2;
        final waving = !still && cycle < 2.6;
        final swing = waving
            ? math.sin(2 * math.pi * 2.1 * cycle) *
                  math.min(1.0, cycle / 0.25) *
                  math.min(1.0, (2.6 - cycle) / 0.25)
            : 0.0;
        final degrees = 6.5 + 5.5 * swing;
        return Stack(
          fit: StackFit.expand,
          children: [
            withBlink('wave_body', 'wave_body_blink'),
            Transform.rotate(
              angle: -degrees * math.pi / 180,
              // The shoulder, in the 640 x 900 frame.
              alignment: const Alignment(508 / 320 - 1, 600 / 450 - 1),
              child: _frame('wave_arm'),
            ),
          ],
        );

      case RealPose.heart:
        final glow = still ? 0.6 : 0.55 + 0.35 * math.sin(t * 2.4);
        return Stack(
          fit: StackFit.expand,
          children: [
            _frame('heart'),
            // A soft light over the heart the character is holding.
            Positioned(
              left: w * 333 / 640 - w * 0.22,
              top: h * 605 / 900 - w * 0.22,
              width: w * 0.44,
              height: w * 0.44,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB9FFF6).withValues(alpha: 0.75 * glow),
                        const Color(0xFF7FF2E6).withValues(alpha: 0.30 * glow),
                        const Color(0x007FF2E6),
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                    backgroundBlendMode: BlendMode.screen,
                  ),
                ),
              ),
            ),
          ],
        );

      case RealPose.think:
        return withBlink('think', 'think_blink');
      case RealPose.idle:
        return withBlink('idle', 'idle_blink');
      case RealPose.excited:
        return _frame('excited');
      case RealPose.sad:
        return _frame('sad');
      case RealPose.smirk:
        return _frame('smirk');
      case RealPose.happy:
        return _frame('happy');
    }
  }

  /// Blinks on an irregular-looking but repeatable rhythm, sometimes twice.
  static double _blinkAt(double t) {
    final cycle = (t / 3.9).floor();
    final phase = t - cycle * 3.9;
    var b = _pulse(phase, 3.6, 0.2);
    if (cycle % 3 == 1) b = math.max(b, _pulse(phase, 3.25, 0.18));
    return b;
  }

  _Reaction _reactionAt(double t) {
    final at = _changedAt;
    if (at == null) return _Reaction.none;
    final s = t - at;
    if (s < 0 || s > 1.0) return _Reaction.none;
    switch (widget.pose) {
      case RealPose.happy:
      case RealPose.excited:
      case RealPose.heart:
        // A hop, then a little squash on landing.
        final hop = s < 0.45 ? -0.06 * math.sin(math.pi * s / 0.45) : 0.0;
        final land = s >= 0.45 && s < 0.65
            ? 0.035 * math.sin(math.pi * (s - 0.45) / 0.2)
            : 0.0;
        return _Reaction(lift: hop, squash: land);
      case RealPose.sad:
        // Sink and settle.
        final k = s < 0.35 ? s / 0.35 : 1 - 0.5 * ((s - 0.35) / 0.65);
        return _Reaction(squash: 0.03 * k, lift: 0.008 * k);
      case RealPose.smirk:
        // A small shrug-tilt and back.
        final k = s < 0.7 ? math.sin(math.pi * s / 0.7) : 0.0;
        return _Reaction(tilt: -0.045 * k, lift: -0.012 * k);
      case RealPose.think:
      case RealPose.idle:
      case RealPose.wave:
        final k = s < 0.4 ? math.sin(math.pi * s / 0.4) : 0.0;
        return _Reaction(lift: -0.015 * k);
    }
  }

  static double _pulse(double t, double start, double width) {
    final x = (t - start) / width;
    if (x <= 0 || x >= 1) return 0;
    return math.sin(math.pi * x);
  }
}

class _Reaction {
  const _Reaction({this.lift = 0, this.squash = 0, this.tilt = 0});

  static const none = _Reaction();

  /// Vertical offset as a fraction of the frame height; negative is up.
  final double lift;

  /// Squash (wider, shorter) as a fraction; negative stretches.
  final double squash;

  /// Lean in radians about the feet.
  final double tilt;
}
