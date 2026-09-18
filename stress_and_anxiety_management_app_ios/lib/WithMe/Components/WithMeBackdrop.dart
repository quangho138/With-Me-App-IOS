import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The page background: a plain two-stop vertical gradient, mint to peach.
///
/// The earlier concept board had a painted beach — sun, headland, surf lines.
/// The V1 design has none of it. Sampling the gradient at 0.05 / 0.25 / 0.5 /
/// 0.75 / 0.95 on all 45 mockups gives colours on a straight line between the
/// two stops, so there is no midpoint either. See docs/WITH_ME_SPEC_V1.md.
class WithMeBackdrop extends StatelessWidget {
  const WithMeBackdrop({
    super.key,
    required this.child,
    this.dimmed = false,
  });

  final Widget child;

  /// Used behind a modal — the mockup for the custom-strategy dialog
  /// (`image22.png`) darkens the page rather than blurring it.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: WithMeColors.page,
        ),
      ),
      child: dimmed
          ? Stack(
              children: [
                Positioned.fill(child: child),
                const Positioned.fill(
                  child: ColoredBox(color: Color(0x73143A38)),
                ),
              ],
            )
          : child,
    );
  }
}
