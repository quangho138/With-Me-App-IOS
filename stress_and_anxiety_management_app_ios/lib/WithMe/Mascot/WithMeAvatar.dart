import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';
import 'MascotExpression.dart';

/// The With Me companion.
///
/// ## About the art
///
/// The V1 design document ships no character art — the mascot exists only
/// baked into 45 screenshots, about 120 px tall. `tool/extract_mascot.py`
/// lifts the largest clean instance (`image1.png`) off the page gradient and
/// mattes it to transparency; that is what `assets/mascot/mascot_wave.png` is.
///
/// Two consequences, both deliberate and both temporary:
///
///   * It is **one pose**. [MascotExpression] still selects the character's
///     *motion* — a celebrating hop reads differently from an idle breath —
///     but the face does not change. The enum is kept because it is the
///     interface every screen already talks to.
///   * At the 200 pt hero size the design uses, upscaled 103 px source art is
///     visibly soft.
///
/// Transparent PNGs at 3x, one per expression, would fix both and change
/// nothing outside this file — see the mascot note in
/// `docs/WITH_ME_SPEC_V1.md`. `MascotPainter` is kept alongside as the vector
/// fallback if the bitmap proves too soft to ship.
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

  /// Width. The widget lays out [size] wide by `size * 1.4175` tall.
  final double size;

  /// Retained for API compatibility with the previous vector avatar. A bitmap
  /// has no mouth to drive, so this now only adds a slight lean while talking.
  final bool speaking;

  /// Allows motion to be switched off for reduced-motion users and tests.
  final bool animate;

  final VoidCallback? onTap;

  @override
  State<WithMeAvatar> createState() => _WithMeAvatarState();
}

/// The shipped art is 309 x 438.
const double _aspect = 438 / 309;

/// Fraction of the asset's width the head spans.
const double _headWidth = 0.74;

/// Where the centre of the head sits, as a fraction of the asset's height.
const double _headCentreY = 0.30;

const String _asset = 'assets/mascot/mascot_wave.png';

class _WithMeAvatarState extends State<WithMeAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: WithMeMotion.breath,
    );
    if (widget.animate) _breath.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant WithMeAvatar old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_breath.isAnimating) {
      _breath.repeat(reverse: true);
    } else if (!widget.animate && _breath.isAnimating) {
      _breath.stop();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size * _aspect;

    Widget art = Image.asset(
      _asset,
      width: widget.size,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    if (widget.animate) {
      art = AnimatedBuilder(
        animation: _breath,
        builder: (context, child) {
          // 0 -> 1 -> 0 over the breath period.
          final t = Curves.easeInOutSine.transform(_breath.value);
          final gestures = widget.expression.gestures;
          // A hop for the expressions that call for one; everyone else just
          // breathes.
          final lift = gestures ? -6 * math.sin(t * math.pi) : 0.0;
          final sway = widget.speaking ? 0.012 * (t - 0.5) : 0.0;
          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform.rotate(
              angle: sway,
              child: Transform.scale(
                scaleX: 1 + 0.010 * t,
                scaleY: 1 + 0.016 * t,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
        child: art,
      );
    }

    final sized = SizedBox(width: widget.size, height: height, child: art);

    if (widget.onTap == null) return sized;
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: sized,
    );
  }
}

/// The circular head-and-shoulders crop used in the header lockup and as a
/// chat avatar.
class WithMeAvatarBadge extends StatelessWidget {
  const WithMeAvatarBadge({
    super.key,
    this.size = 40,
    this.expression = MascotExpression.idle,
    this.animate = true,
  });

  final double size;
  final MascotExpression expression;

  /// Unused — the badge is a still crop. Kept so callers need not change.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    // Scale so the head fills the circle, then slide it up so the head's
    // centre lands on the circle's centre.
    final zoom = 1 / _headWidth;
    final artW = size * zoom;
    final artH = artW * _aspect;

    // In an OverflowBox the child's top sits at (size - artH) * (ay + 1) / 2.
    // Solve that plus _headCentreY * artH == size / 2 for ay.
    final ay = (size / 2 - _headCentreY * artH) * 2 / (size - artH) - 1;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: WithMeColors.tealSoft,
          child: OverflowBox(
            maxWidth: artW,
            maxHeight: artH,
            alignment: Alignment(0, ay.clamp(-1.0, 1.0)),
            child: Image.asset(
              _asset,
              width: artW,
              height: artH,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}
