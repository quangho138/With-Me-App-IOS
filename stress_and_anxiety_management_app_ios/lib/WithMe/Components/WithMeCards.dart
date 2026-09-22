import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// Plain cream card. 24 pt radius for the large panels, 16 for everything
/// else — see `docs/WITH_ME_SPEC_V1.md`.
class WithMeCard extends StatelessWidget {
  const WithMeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(WithMeSpace.lg),
    this.radius = WithMeSpace.radiusLg,
    this.color,
    this.height,
    this.minHeight,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;

  /// Exact height. Use [minHeight] instead wherever the content can grow.
  final double? height;

  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight!),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? WithMeColors.cream,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: child,
    );
  }
}

/// The card that carries the question at the top of a check-in step.
///
/// Measured at 342 x 100 with a 24 pt radius on `image7`, `image10`-`image19`;
/// it grows to 128 when the question runs to three lines (`image8`).
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.subtitle,
    this.minHeight = 100,
  });

  final String question;
  final String? subtitle;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.lg,
        vertical: WithMeSpace.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight - 2 * WithMeSpace.lg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                question,
                textAlign: TextAlign.center,
                style: WithMeText.question,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: WithMeSpace.sm),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: WithMeText.body,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A short reassurance under the answers — "No number, no score. Just how it
/// feels.", "Low is okay. We'll keep it small."
class ReassuranceCard extends StatelessWidget {
  const ReassuranceCard({super.key, required this.text, this.tinted = false});

  final String text;

  /// The "You're making progress!" panel on `image32` is mint rather than cream.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      radius: WithMeSpace.radiusMd,
      color: tinted
          ? WithMeColors.mint.withValues(alpha: 0.45)
          : WithMeColors.cream,
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.lg,
        vertical: WithMeSpace.md,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: WithMeText.body.copyWith(color: WithMeColors.inkSoft),
      ),
    );
  }
}

/// Big number over a caption — "34 check-ins", "3 check-ins this week".
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.caption,
    this.tinted = false,
    this.minHeight = 86,
  });

  final String value;
  final String caption;

  /// The "Positive trend / Keep going!" tile on `image37` is mint.
  final bool tinted;

  /// Measured at 86 on `image4` with a one-line caption, 109 on `image37`
  /// where the caption wraps. A minimum rather than a fixed height, so a
  /// longer caption grows the tile instead of overflowing it.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return WithMeCard(
      minHeight: minHeight,
      radius: 18,
      color: tinted
          ? WithMeColors.mint.withValues(alpha: 0.55)
          : WithMeColors.cream,
      padding: const EdgeInsets.all(WithMeSpace.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: tinted
                ? WithMeText.option.copyWith(
                    fontWeight: FontWeight.w700,
                    color: WithMeColors.teal,
                  )
                : WithMeText.stat,
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            textAlign: TextAlign.center,
            // inkFaint is a grey meant for cream. On the mint tile it lands
            // at about 2:1 against the fill, which is neither legible nor
            // what the design draws - image37 reads "Keep going!" as dark as
            // the value above it.
            style: tinted
                ? WithMeText.caption.copyWith(color: WithMeColors.teal)
                : WithMeText.caption,
          ),
        ],
      ),
    );
  }
}

/// All-caps section label — "QUICK ACTIONS", "DATE RANGE".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: WithMeText.sectionLabel);
}

/// Script line the design drops at the bottom of several screens —
/// "Every step counts", "Small steps, bright futures".
class AccentLine extends StatelessWidget {
  const AccentLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: WithMeText.accent,
      );
}
