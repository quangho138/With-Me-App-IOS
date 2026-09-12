import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';
import 'MascotExpression.dart';
import 'MascotPainter.dart';

/// The animated With Me companion.
///
/// Four independent clocks run the character so the motions never lock into an
/// obviously repeating loop:
///   * breath  — always running, a slow rise and fall
///   * blink   — a short snap, re-scheduled at a randomised interval
///   * gesture — arm waves, hops, thought dots; only while [expression] needs it
///   * talk    — mouth movement, only while [speaking] is true
///
/// Changing [expression] cross-fades rather than cutting, so the companion
/// never appears to flicker between moods.
class WithMeAvatar extends StatefulWidget {
  const WithMeAvatar({
    super.key,
    this.expression = MascotExpression.idle,
    this.size = 180,
    this.speaking = false,
    this.animate = true,
    this.onTap,
  });

  final MascotExpression expression;
  final double size;

  /// Drives the mouth. Set while a message is being delivered.
  final bool speaking;

  /// Allows motion to be switched off for reduced-motion users and tests.
  final bool animate;

  final VoidCallback? onTap;

  @override
  State<WithMeAvatar> createState() => _WithMeAvatarState();
}

/// Height-to-width ratio of the painter's design box (200 x 280).
const double _aspect = 1.4;

/// How far the circular badge zooms into the character. The head spans
/// 0.64 of the design width, so 1.3x leaves it just inside the circle.
const double _badgeZoom = 1.3;

/// Vertical offset that lands the head in the middle of the badge.
/// Derived from the head's position in the design box: 0.2z / (1 - 1.4z).
const double _badgeAlign = -0.32;

class _WithMeAvatarState extends State<WithMeAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _blink;
  late final AnimationController _gesture;
  late final AnimationController _talk;

  Timer? _blinkTimer;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    _breath = AnimationController(
      vsync: this,
      duration: WithMeMotion.breath,
    );
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _gesture = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _talk = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    if (widget.animate) {
      _breath.repeat(reverse: true);
      _scheduleBlink();
      _syncGesture();
      _syncTalk();
    }
  }

  @override
  void didUpdateWidget(covariant WithMeAvatar old) {
    super.didUpdateWidget(old);

    if (widget.animate != old.animate) {
      if (widget.animate) {
        _breath.repeat(reverse: true);
        _scheduleBlink();
      } else {
        _breath.stop();
        _blinkTimer?.cancel();
        _blink.value = 0;
      }
    }
    if (widget.expression != old.expression) _syncGesture();
    if (widget.speaking != old.speaking) _syncTalk();
  }

  /// Blinks land at irregular intervals — a metronome blink reads as robotic.
  void _scheduleBlink() {
    _blinkTimer?.cancel();
    if (!widget.animate) return;

    _blinkTimer = Timer(
      Duration(milliseconds: 2200 + _random.nextInt(3600)),
      () async {
        if (!mounted) return;
        // The eye closes and opens in one short movement.
        await _blink.forward();
        if (!mounted) return;
        await _blink.reverse();
        _scheduleBlink();
      },
    );
  }

  void _syncGesture() {
    final wants = widget.animate &&
        (widget.expression.gestures ||
            widget.expression == MascotExpression.thinking);

    if (wants && !_gesture.isAnimating) {
      _gesture.repeat();
    } else if (!wants && _gesture.isAnimating) {
      _gesture
        ..stop()
        ..value = 0;
    }
  }

  void _syncTalk() {
    if (widget.speaking && widget.animate) {
      _talk.repeat(reverse: true);
    } else {
      _talk
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breath.dispose();
    _blink.dispose();
    _gesture.dispose();
    _talk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = AnimatedBuilder(
      animation: Listenable.merge([_breath, _blink, _gesture, _talk]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size * _aspect),
          painter: MascotPainter(
            expression: widget.expression,
            breath: Curves.easeInOutSine.transform(_breath.value),
            blink: _blink.value,
            gesture: _gesture.value,
            talk: _talk.value,
          ),
        );
      },
    );

    return Semantics(
      label: 'With Me companion, ${widget.expression.label}',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: widget.size,
          height: widget.size * _aspect,
          child: avatar,
        ),
      ),
    );
  }
}

/// A compact, cropped bust of the companion for chat rows, app bars and lists.
///
/// It reuses the same painter but scales up and shifts the design box so only
/// the head and lei are visible inside a circular frame.
class WithMeAvatarBadge extends StatelessWidget {
  const WithMeAvatarBadge({
    super.key,
    this.size = 40,
    this.expression = MascotExpression.idle,
    this.animate = true,
  });

  final double size;
  final MascotExpression expression;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WithMeColors.tealSoft, WithMeColors.leafSoft],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: OverflowBox(
        maxWidth: size * _badgeZoom,
        maxHeight: size * _badgeZoom * _aspect,
        // Centres the head — not the eyes — inside the circle.
        alignment: const Alignment(0, _badgeAlign),
        child: WithMeAvatar(
          size: size * _badgeZoom,
          expression: expression,
          animate: animate,
        ),
      ),
    );
  }
}
