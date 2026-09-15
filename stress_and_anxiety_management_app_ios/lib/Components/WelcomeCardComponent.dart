import 'package:flutter/material.dart';

import '../Database/LocalDatabase.dart';
import '../WithMe/Theme/WithMeTheme.dart';

class WelcomeCard extends StatelessWidget {
  final double fontSize;
  final double padding;

  const WelcomeCard({
    super.key,
    this.fontSize = 18,
    this.padding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return ValueListenableBuilder<String?>(
      valueListenable: dbHelper.userNameNotifier,
      builder: (context, userName, _) {
        final displayName = userName?.trim().isNotEmpty == true ? userName! : 'there';
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding * 0.9,
          ),
          decoration: BoxDecoration(
            color: WithMeColors.creamLight.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
            boxShadow: WithMeSpace.cardShadow,
          ),
          child: Text(
            'Welcome $displayName. What would you like to focus on?',
            textAlign: TextAlign.center,
            style: WithMeText.question.copyWith(
              fontSize: fontSize.clamp(17, 21).toDouble(),
            ),
          ),
        );
      },
    );
  }
}
