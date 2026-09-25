import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The V2 visual language, from `docs/design_v2/reference.webp`: painted
/// tropical scenery full-bleed behind the screen, cream speech bubbles, and
/// glossy teal pills.

/// Text drawn a little heavier than Quicksand's boldest cut, to match the
/// reference's chunky rounded type: the fill, over a thin outline in the
/// same colour. [weight] is the outline width.
class ChunkyText extends StatelessWidget {
  const ChunkyText(
    this.text, {
    super.key,
    required this.style,
    this.weight = 0.9,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle style;
  final double weight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final colour = style.color ?? ScenicColors.ink;
    return Stack(
      children: [
        ExcludeSemantics(
          child: Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            style: style.copyWith(
              color: null,
              shadows: const [],
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = weight
                ..strokeJoin = StrokeJoin.round
                ..color = colour,
            ),
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: style,
        ),
      ],
    );
  }
}

/// Colours read off the reference.
class ScenicColors {
  ScenicColors._();

  static const Color ink = Color(0xFF14504E);
  static const Color pillTop = Color(0xFF23918F);
  static const Color pillBottom = Color(0xFF0E6E70);
  static const Color bubble = Color(0xFFFFF9EE);
  static const Color tile = Color(0xFFE6EFEA);
  static const Color ring = Color(0xFFD9DEDA);
  static const Color coral = Color(0xFFEE6A55);
}

/// A painted background, covering the whole screen.
class ScenicBackdrop extends StatelessWidget {
  const ScenicBackdrop({super.key, required this.scene, required this.child});

  /// `welcome` or `sunset`.
  final String scene;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/v2/app/bg_$scene.webp',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        ),
        child,
      ],
    );
  }
}

/// The glossy teal pill - "Sign Up", "Continue".
class ScenicPill extends StatelessWidget {
  const ScenicPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.light = false,
    this.leading,
    this.height = 50,
  });

  final String label;

  /// Null disables it - dimmed, and announced as a dimmed button.
  final VoidCallback? onPressed;

  /// White pill with teal text - "Login", "Continue with Google".
  final bool light;
  final Widget? leading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              gradient: light
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [ScenicColors.pillTop, ScenicColors.pillBottom],
                    ),
              color: light ? Colors.white.withValues(alpha: 0.94) : null,
              border: Border.all(
                color: Colors.white.withValues(alpha: light ? 0.9 : 0.55),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B3E3C).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 10)],
                // Flexible, so a long label or large accessibility text
                // ellipsises instead of overflowing the pill.
                Flexible(
                  child: ChunkyText(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    weight: 0.7,
                    style: TextStyle(
                      fontFamily: WithMeText.ui,
                      fontSize: light ? 20 : 23,
                      fontWeight: FontWeight.w700,
                      color: light ? ScenicColors.ink : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A cream speech bubble with a tail pointing down at the companion.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.child,
    this.tailAt = 0.62,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 22),
  });

  final Widget child;

  /// Where along the bottom edge the tail sits, 0 left to 1 right.
  final double tailAt;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(tailAt),
      child: Padding(
        padding: padding.copyWith(bottom: padding.bottom + 14),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.tailAt);

  final double tailAt;

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 14.0;
    final body = Rect.fromLTWH(0, 0, size.width, size.height - tail);
    final tx = size.width * tailAt;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(24)))
      ..moveTo(tx - 16, body.bottom - 1)
      ..quadraticBezierTo(
        tx + 2,
        body.bottom + tail * 0.6,
        tx + 10,
        size.height,
      )
      ..quadraticBezierTo(
        tx + 8,
        body.bottom + tail * 0.3,
        tx + 14,
        body.bottom - 1,
      )
      ..close();
    canvas.drawShadow(path, const Color(0x55000000), 6, false);
    canvas.drawPath(
      path,
      Paint()..color = ScenicColors.bubble.withValues(alpha: 0.95),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.tailAt != tailAt;
}

/// The bubble's question text.
class BubbleText extends StatelessWidget {
  const BubbleText(this.text, {super.key, this.size = 26});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => ChunkyText(
    text,
    style: TextStyle(
      fontFamily: WithMeText.ui,
      fontSize: size,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: ScenicColors.ink,
    ),
  );
}

/// Back chevron in the scenic header: white, with a soft shadow so it holds
/// up over bright sky.
class ScenicBack extends StatelessWidget {
  const ScenicBack({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Back',
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 22,
          color: Colors.white,
          shadows: [Shadow(color: Color(0x66000000), blurRadius: 6)],
        ),
      ),
    ),
  );
}

/// The thin progress track at the top of the check-in pages.
class ScenicProgress extends StatelessWidget {
  const ScenicProgress({super.key, required this.value, this.width = 150});

  /// 0 to 1.
  final double value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 14,
      child: CustomPaint(painter: _ProgressPainter(value.clamp(0, 1))),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final track = RRect.fromLTRBR(
      0,
      y - 2.5,
      size.width,
      y + 2.5,
      const Radius.circular(3),
    );
    canvas.drawRRect(
      track,
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    final x = size.width * value;
    canvas.drawRRect(
      RRect.fromLTRBR(0, y - 2.5, x, y + 2.5, const Radius.circular(3)),
      Paint()..color = ScenicColors.pillBottom,
    );
    canvas.drawCircle(
      Offset(x, y),
      6,
      Paint()..color = ScenicColors.pillBottom,
    );
    canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.value != value;
}

/// The row of 1-5 circles inside a question bubble.
class NumberChoice extends StatelessWidget {
  const NumberChoice({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 1; i <= count; i++)
          Semantics(
            button: true,
            selected: value == i,
            label: '$i',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: WithMeMotion.fast,
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value == i ? ScenicColors.pillBottom : Colors.white,
                  border: Border.all(
                    color: value == i
                        ? ScenicColors.pillBottom
                        : ScenicColors.ring,
                    width: 1.6,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ChunkyText(
                  '$i',
                  weight: 0.7,
                  style: TextStyle(
                    fontFamily: WithMeText.ui,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: value == i ? Colors.white : ScenicColors.ink,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The four mood faces on the greeting: Not good, Okay, Good, Great.
enum MoodFace { notGood, okay, good, great }

extension MoodFaceInfo on MoodFace {
  String get label => switch (this) {
    MoodFace.notGood => 'Not good',
    MoodFace.okay => 'Okay',
    MoodFace.good => 'Good',
    MoodFace.great => 'Great',
  };

  Color get light => switch (this) {
    MoodFace.notGood => const Color(0xFFFF8C8A),
    MoodFace.okay => const Color(0xFFFFC27A),
    MoodFace.good => const Color(0xFFFFDE73),
    MoodFace.great => const Color(0xFF8BE08A),
  };

  Color get deep => switch (this) {
    MoodFace.notGood => const Color(0xFFE2524F),
    MoodFace.okay => const Color(0xFFEE9A3E),
    MoodFace.good => const Color(0xFFF1BB2C),
    MoodFace.great => const Color(0xFF45B35A),
  };
}

class MoodFacesCard extends StatelessWidget {
  const MoodFacesCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MoodFace? value;
  final ValueChanged<MoodFace> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        color: ScenicColors.bubble.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final face in MoodFace.values)
            Semantics(
              button: true,
              selected: value == face,
              label: face.label,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onChanged(face),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: value == face ? 1.12 : 1,
                      duration: WithMeMotion.fast,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: value == face
                                ? ScenicColors.pillBottom
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CustomPaint(
                          size: const Size(48, 48),
                          painter: _FacePainter(face),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ChunkyText(
                      face.label,
                      weight: 0.5,
                      style: const TextStyle(
                        fontFamily: WithMeText.ui,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: ScenicColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A glossy emoji face, lit from the top left like the reference's.
class _FacePainter extends CustomPainter {
  _FacePainter(this.face);

  final MoodFace face;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas.drawCircle(
      c + const Offset(0, 1.5),
      r,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [face.light, face.deep],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Gloss.
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-r * 0.25, -r * 0.5),
        width: r * 0.9,
        height: r * 0.4,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    final ink = Paint()
      ..color = const Color(0xFF6B2E1E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round;
    final eyeY = r * 0.8;
    final eyeDx = r * 0.36;
    final eye = Paint()..color = const Color(0xFF5A2618).withValues(alpha: 0.9);

    switch (face) {
      case MoodFace.notGood:
        canvas.drawCircle(Offset(r - eyeDx, eyeY), r * 0.1, eye);
        canvas.drawCircle(Offset(r + eyeDx, eyeY), r * 0.1, eye);
        canvas.drawLine(
          Offset(r - eyeDx - r * 0.14, eyeY - r * 0.3),
          Offset(r - eyeDx + r * 0.12, eyeY - r * 0.2),
          ink,
        );
        canvas.drawLine(
          Offset(r + eyeDx + r * 0.14, eyeY - r * 0.3),
          Offset(r + eyeDx - r * 0.12, eyeY - r * 0.2),
          ink,
        );
        canvas.drawPath(
          Path()
            ..moveTo(r - r * 0.35, r * 1.45)
            ..quadraticBezierTo(r, r * 1.05, r + r * 0.35, r * 1.45),
          ink,
        );
      case MoodFace.okay:
        canvas.drawCircle(Offset(r - eyeDx, eyeY), r * 0.1, eye);
        canvas.drawCircle(Offset(r + eyeDx, eyeY), r * 0.1, eye);
        canvas.drawPath(
          Path()
            ..moveTo(r - r * 0.32, r * 1.38)
            ..quadraticBezierTo(r, r * 1.22, r + r * 0.32, r * 1.38),
          ink,
        );
      case MoodFace.good:
        canvas.drawCircle(Offset(r - eyeDx, eyeY), r * 0.1, eye);
        canvas.drawCircle(Offset(r + eyeDx, eyeY), r * 0.1, eye);
        canvas.drawPath(
          Path()
            ..moveTo(r - r * 0.4, r * 1.2)
            ..quadraticBezierTo(r, r * 1.6, r + r * 0.4, r * 1.2),
          ink,
        );
      case MoodFace.great:
        final arc = Paint()
          ..color = ink.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.11
          ..strokeCap = StrokeCap.round;
        for (final dx in [-eyeDx, eyeDx]) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(r + dx, eyeY + r * 0.06),
              width: r * 0.34,
              height: r * 0.3,
            ),
            math.pi,
            math.pi,
            false,
            arc,
          );
        }
        canvas.drawPath(
          Path()
            ..moveTo(r - r * 0.46, r * 1.12)
            ..quadraticBezierTo(r, r * 1.78, r + r * 0.46, r * 1.12)
            ..close(),
          Paint()..color = const Color(0xFF6B2E1E).withValues(alpha: 0.85),
        );
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.face != face;
}

/// One of Home / Work / School / Social in the stress-area grid.
class AreaTile extends StatelessWidget {
  const AreaTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WithMeMotion.fast,
          height: 120,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD3ECE6) : ScenicColors.tile,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? ScenicColors.pillBottom
                  : Colors.white.withValues(alpha: 0.9),
              width: selected ? 2.4 : 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 54, color: color),
              const SizedBox(height: 6),
              ChunkyText(
                label,
                weight: 0.7,
                style: const TextStyle(
                  fontFamily: WithMeText.ui,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: ScenicColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
