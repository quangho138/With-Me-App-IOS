import 'package:flutter/material.dart';

import '../Components/SpeechBubble.dart';
import '../Components/WithMeBackdrop.dart';
import '../Components/WithMeControls.dart';
import '../Data/CheckInSteps.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// The payoff screen: one priority, one goal, one practical action.
///
/// The spec is explicit that the plan stays small — a single next step, not a
/// programme. The copy here is assembled from the user's own answers so it
/// reads back in their words.
class ActionPlanScreen extends StatelessWidget {
  const ActionPlanScreen({super.key, required this.answers});

  final CheckInAnswers answers;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(WithMeSpace.sm),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: WithMeColors.teal,
                        tooltip: 'Back',
                      ),
                      const Expanded(
                        child: Text(
                          "Here's your plan for today",
                          style: WithMeText.title,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WithMeSpace.xl,
                    ),
                    child: Column(
                      children: [
                        SpeechBubble(
                          text:
                              "You showed up today, and that counts.\nLet's keep it to one small step.",
                          tail: BubbleTail.bottom,
                          typewriter: true,
                        ),
                        const SizedBox(height: WithMeSpace.lg),
                        _PlanCard(answers: answers),
                        const SizedBox(height: WithMeSpace.xl),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'WHAT WOULD YOU LIKE TO DO NOW?',
                            style: WithMeText.sectionLabel,
                          ),
                        ),
                        const SizedBox(height: WithMeSpace.md),
                        for (final o in kNextOptions)
                          OptionTile(
                            icon: o.icon,
                            label: o.label,
                            tint: o.tint,
                            selected: false,
                            onTap: () => _notImplemented(context, o.label),
                          ),
                        const SizedBox(height: WithMeSpace.lg),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    WithMeSpace.xl,
                    0,
                    WithMeSpace.xl,
                    WithMeSpace.lg,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const WithMeAvatar(
                        size: 88,
                        expression: MascotExpression.celebrating,
                      ),
                      const SizedBox(width: WithMeSpace.md),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: WithMeSpace.lg),
                          child: WithMeButton(
                            label: "Let's do this!",
                            icon: Icons.favorite_rounded,
                            onPressed: () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _notImplemented(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label is not wired up in this UI pass.'),
        backgroundColor: WithMeColors.tealDeep,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.answers});

  final CheckInAnswers answers;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String, Color)>[
      (
        Icons.assignment_rounded,
        'Focus Area',
        answers.focusArea,
        WithMeColors.teal,
      ),
      (
        Icons.priority_high_rounded,
        'What matters most',
        answers.mainFeeling,
        WithMeColors.hibiscus,
      ),
      (
        Icons.flag_rounded,
        'Goal',
        answers.goal,
        WithMeColors.leaf,
      ),
      (
        Icons.directions_walk_rounded,
        'First step',
        'Break it down into one small task',
        WithMeColors.lei,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(WithMeSpace.lg),
      decoration: BoxDecoration(
        color: WithMeColors.creamLight.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
        boxShadow: WithMeSpace.cardShadow,
        border: Border.all(color: WithMeColors.lei.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: WithMeSpace.lg,
                color: WithMeColors.inkFaint.withValues(alpha: 0.2),
              ),
            _planRow(rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _planRow((IconData, String, String, Color) row) {
    final (icon, label, value, tint) = row;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
          ),
          child: Icon(icon, size: 19, color: tint),
        ),
        const SizedBox(width: WithMeSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: WithMeText.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: WithMeText.option.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
