import 'package:flutter/material.dart';

import '../WithMe/Theme/WithMeTheme.dart';

/// Reusable home action styled like the selectable cream tiles in the
/// reference check-in UI.
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double fontSize;
  final Color textColor;
  final double height;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.fontSize = 16,
    this.textColor = WithMeColors.ink,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: WithMeColors.creamLight.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
            border: Border.all(
              color: WithMeColors.teal.withValues(alpha: 0.08),
            ),
            boxShadow: WithMeSpace.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: WithMeColors.tealSoft.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: WithMeColors.teal, size: 20),
                ),
                const SizedBox(width: WithMeSpace.md),
                Expanded(
                  child: Text(
                    label,
                    style: WithMeText.option.copyWith(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: WithMeColors.inkFaint,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
