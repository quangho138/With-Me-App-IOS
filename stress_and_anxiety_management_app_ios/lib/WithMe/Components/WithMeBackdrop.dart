import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Mascot/MascotExpression.dart';
import '../Theme/WithMeTheme.dart';

/// Scenic animated backdrop for the With Me companion flow.
///
/// The scene uses a detailed illustrated background plus a larger animated
/// mascot overlay that matches the user's reference style more closely.
class WithMeBackdrop extends StatelessWidget {
  const WithMeBackdrop({
    super.key,
    required this.child,
    this.dimmed = false,
    this.expression = MascotExpression.idle,
    this.speaking = false,
  });

  static const String _backgroundAsset =
      'assets/with_me/companion_detailed_backdrop.png';

  final Widget child;
  final bool dimmed;
  final MascotExpression expression;
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            _backgroundAsset,
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.12),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: dimmed ? 0.10 : 0.03),
                  Colors.white.withValues(alpha: dimmed ? 0.04 : 0.00),
                  const Color(0xFFFEF4E9).withValues(alpha: dimmed ? 0.10 : 0.04),
                  WithMeColors.sand.withValues(alpha: dimmed ? 0.28 : 0.10),
                ],
                stops: const [0.0, 0.32, 0.68, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: const Alignment(0, 0.56),
              child: _BackdropMascot(
                expression: expression,
                dimmed: dimmed,
                speaking: speaking,
              ),
            ),
          ),
        ),
        if (dimmed)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class _BackdropMascot extends StatefulWidget {
  const _BackdropMascot({
    required this.expression,
    required this.dimmed,
    required this.speaking,
  });

  static const String _neutral = 'assets/with_me/companion_mascot_neutral.png';
  static const String _blink = 'assets/with_me/companion_mascot_blink.png';
  static const String _thinking = 'assets/with_me/companion_mascot_thinking.png';
  static const String _sad = 'assets/with_me/companion_mascot_sad.png';

  final MascotExpression expression;
  final bool dimmed;
  final bool speaking;

  @override
  State<_BackdropMascot> createState() => _BackdropMascotState();
}

class _BackdropMascotState extends State<_BackdropMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Timer? _blinkTimer;
  bool _showBlink = false;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant _BackdropMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_usesSpecialExpression(widget.expression) !=
        _usesSpecialExpression(oldWidget.expression)) {
      if (_usesSpecialExpression(widget.expression)) {
        _cancelBlink(reset: true);
      } else {
        _scheduleBlink();
      }
    }
  }

  bool _usesSpecialExpression(MascotExpression expression) {
    return expression == MascotExpression.thinking ||
        expression == MascotExpression.sad ||
        expression == MascotExpression.concerned;
  }

  void _cancelBlink({bool reset = false}) {
    _blinkTimer?.cancel();
    if (reset && mounted && _showBlink) {
      setState(() => _showBlink = false);
    }
  }

  void _scheduleBlink() {
    _cancelBlink();
    if (_usesSpecialExpression(widget.expression)) return;

    _blinkTimer = Timer(
      Duration(milliseconds: 2600 + _random.nextInt(2800)),
      () async {
        if (!mounted || _usesSpecialExpression(widget.expression)) return;
        setState(() => _showBlink = true);
        await Future<void>.delayed(const Duration(milliseconds: 170));
        if (!mounted) return;
        setState(() => _showBlink = false);
        _scheduleBlink();
      },
    );
  }

  String get _assetPath {
    if (widget.expression == MascotExpression.thinking) {
      return _BackdropMascot._thinking;
    }
    if (widget.expression == MascotExpression.sad ||
        widget.expression == MascotExpression.concerned) {
      return _BackdropMascot._sad;
    }
    if (_showBlink) {
      return _BackdropMascot._blink;
    }
    return _BackdropMascot._neutral;
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final mascotWidth = math.min(width * 0.62, 320.0);
    final opacity = widget.dimmed ? 0.78 : 0.98;

    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final t = Curves.easeInOutSine.transform(_breath.value);
        final speakBump = widget.speaking ? 0.018 : 0.0;
        final scale = 0.985 + t * 0.025 + speakBump;
        final dy = 8 - t * 12;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: mascotWidth,
                foregroundDecoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.dimmed ? 0.08 : 0.05),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  _assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
