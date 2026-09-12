import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The "With Me / Your AI Companion / Here. With you." lockup.
class WithMeWordmark extends StatelessWidget {
  const WithMeWordmark({
    super.key,
    this.scale = 1,
    this.showTagline = true,
  });

  final double scale;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'With',
              style: WithMeText.wordmark.copyWith(
                fontSize: 34 * scale,
                fontStyle: FontStyle.italic,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 14 * scale, left: 2, right: 2),
              child: Icon(
                Icons.eco_rounded,
                size: 13 * scale,
                color: WithMeColors.leaf,
              ),
            ),
            Text(
              'Me',
              style: WithMeText.wordmark.copyWith(
                fontSize: 34 * scale,
                fontStyle: FontStyle.italic,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2 * scale, left: 3),
              child: Icon(
                Icons.local_florist_rounded,
                size: 16 * scale,
                color: WithMeColors.hibiscus,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: 4 * scale),
          Text(
            'Your AI Companion',
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: WithMeColors.ink,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            'Here. With you.',
            style: WithMeText.tagline.copyWith(fontSize: 14 * scale),
          ),
        ],
      ],
    );
  }
}

/// The four-promise card: "I listen. I understand. I guide. I'm with you."
class PromiseCard extends StatelessWidget {
  const PromiseCard({super.key, this.compact = false});

  final bool compact;

  static const _promises = [
    (Icons.hearing_rounded, 'I listen.', WithMeColors.teal),
    (Icons.favorite_rounded, 'I understand.', WithMeColors.hibiscus),
    (Icons.eco_rounded, 'I guide.', WithMeColors.leaf),
    (Icons.waves_rounded, "I'm with you.", WithMeColors.tealLight),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: WithMeSpace.lg,
        vertical: compact ? WithMeSpace.md : WithMeSpace.lg,
      ),
      decoration: BoxDecoration(
        color: WithMeColors.creamLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (icon, text, color) in _promises)
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 3 : 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: WithMeSpace.md),
                  Text(
                    text,
                    style: WithMeText.option.copyWith(
                      fontSize: compact ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
