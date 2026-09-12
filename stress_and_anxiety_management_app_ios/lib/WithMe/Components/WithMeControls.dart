import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The 1–5 rating row used for Stress Level and Motivation.
///
/// The scale is the heart of the Stressing Anxiety framework, so it gets
/// generous tap targets (48 px) and a clear selected state rather than a
/// slider the user has to aim at.
class ScaleSelector extends StatelessWidget {
  const ScaleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 5,
    this.lowLabel,
    this.highLabel,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? lowLabel;
  final String? highLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = min; i <= max; i++) ...[
              _ScalePill(
                number: i,
                selected: value == i,
                onTap: () => onChanged(i),
              ),
              if (i != max) const SizedBox(width: WithMeSpace.md),
            ],
          ],
        ),
        if (lowLabel != null || highLabel != null) ...[
          const SizedBox(height: WithMeSpace.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lowLabel ?? '', style: WithMeText.caption),
                Text(highLabel ?? '', style: WithMeText.caption),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ScalePill extends StatelessWidget {
  const _ScalePill({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: '$number out of 5',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: WithMeMotion.fast,
          curve: WithMeMotion.pop,
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? WithMeColors.teal : WithMeColors.creamLight,
            border: Border.all(
              color: selected
                  ? WithMeColors.teal
                  : WithMeColors.teal.withValues(alpha: 0.22),
              width: 1.6,
            ),
            boxShadow: selected ? WithMeSpace.cardShadow : null,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : WithMeColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}

/// One selectable answer: a tinted icon chip, a label, and a check when chosen.
///
/// Used by the Body / Feelings / Mind / Behavior / Intention / Options screens,
/// all of which are the same list pattern with different content.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? WithMeColors.teal;

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: WithMeMotion.fast,
          margin: const EdgeInsets.only(bottom: WithMeSpace.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: WithMeSpace.md,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.16)
                : WithMeColors.creamLight.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.6,
            ),
            boxShadow: selected ? null : WithMeSpace.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: WithMeSpace.md),
              Expanded(child: Text(label, style: WithMeText.option)),
              AnimatedScale(
                duration: WithMeMotion.fast,
                curve: WithMeMotion.pop,
                scale: selected ? 1 : 0,
                child: Icon(Icons.check_circle_rounded, size: 20, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 2×2 life-area grid (Home / Work / School / Social).
class OptionGridCard extends StatelessWidget {
  const OptionGridCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: WithMeMotion.fast,
          padding: const EdgeInsets.symmetric(vertical: WithMeSpace.lg),
          decoration: BoxDecoration(
            color: selected
                ? tint.withValues(alpha: 0.18)
                : WithMeColors.creamLight.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
            border: Border.all(
              color: selected ? tint : Colors.transparent,
              width: 1.8,
            ),
            boxShadow: selected ? null : WithMeSpace.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: tint),
              const SizedBox(height: WithMeSpace.sm),
              Text(
                label,
                style: WithMeText.option.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The primary teal pill button at the foot of every step.
class WithMeButton extends StatelessWidget {
  const WithMeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    if (!filled) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: WithMeColors.teal, width: 1.6),
            foregroundColor: WithMeColors.teal,
            backgroundColor: WithMeColors.creamLight.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
            ),
          ),
          child: Text(
            label,
            style: WithMeText.button.copyWith(color: WithMeColors.teal),
          ),
        ),
      );
    }

    return AnimatedOpacity(
      duration: WithMeMotion.fast,
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: WithMeColors.teal,
            disabledBackgroundColor: WithMeColors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: WithMeText.button),
              if (icon != null) ...[
                const SizedBox(width: WithMeSpace.sm),
                Icon(icon, size: 19, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The semicircular intention gauge from the concept board.
class IntentionGauge extends StatelessWidget {
  const IntentionGauge({super.key, required this.value, this.size = 170});

  /// 0 = struggling, 1 = in control.
  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: value.clamp(0.0, 1.0).toDouble(),
      ),
      duration: WithMeMotion.slow,
      curve: WithMeMotion.ease,
      builder: (context, v, _) => CustomPaint(
        size: Size(size, size * 0.62),
        painter: _GaugePainter(v),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Coloured sweep from alert red through to calm green.
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..shader = const SweepGradient(
          startAngle: math.pi,
          endAngle: math.pi * 2,
          colors: WithMeColors.gauge,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round,
    );

    // Needle.
    final angle = math.pi + math.pi * value;
    final tip = Offset(
      centre.dx + math.cos(angle) * (radius - 16),
      centre.dy + math.sin(angle) * (radius - 16),
    );
    canvas.drawLine(
      centre,
      tip,
      Paint()
        ..color = WithMeColors.ink
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(centre, 7, Paint()..color = WithMeColors.ink);
    canvas.drawCircle(centre, 3, Paint()..color = WithMeColors.creamLight);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.value != value;
}

/// The slim step counter shown under the app bar during a check-in.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: WithMeMotion.medium,
            curve: WithMeMotion.ease,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i <= index
                  ? WithMeColors.teal
                  : WithMeColors.teal.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
            ),
          ),
      ],
    );
  }
}
