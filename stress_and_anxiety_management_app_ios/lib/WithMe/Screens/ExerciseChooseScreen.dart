import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Data/CheckInSteps.dart';
import '../Theme/WithMeTheme.dart';
import 'BeforeWeStartScreen.dart';
import 'BreathingScreen.dart';
import 'SighScreen.dart';

/// `image25.png` — "Choose an exercise".
///
/// Measured: a 70 pt header card at y 106, then four rows at y 188 / 277 /
/// 366 / 454. The three with a duration are 76 tall; "Other exercises" is 59.
class ExerciseChooseScreen extends StatefulWidget {
  const ExerciseChooseScreen({super.key});

  static const String route = '/exercises';

  @override
  State<ExerciseChooseScreen> createState() => _ExerciseChooseScreenState();
}

class _ExerciseChooseScreenState extends State<ExerciseChooseScreen> {
  int _selected = 0;

  void _continue() {
    final target = switch (_selected) {
      0 => const BeforeWeStartScreen(pattern: BreathPattern.fourSevenEight),
      1 => const BeforeWeStartScreen(pattern: BreathPattern.fourSevenEight),
      2 => const BeforeWeStartScreen(pattern: BreathPattern.fourFourFour),
      _ => const SighScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(label: 'Continue', onPressed: _continue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WithMeCard(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
            child: Center(
              child: Text('Choose an exercise', style: WithMeText.question),
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          for (var i = 0; i < kExercises.length; i++) ...[
            if (i > 0) const SizedBox(height: WithMeSpace.md),
            Semantics(
              button: true,
              selected: _selected == i,
              child: InkWell(
                onTap: () => setState(() => _selected = i),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: WithMeMotion.fast,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _selected == i
                        ? WithMeColors.teal
                        : WithMeColors.cream,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: WithMeSpace.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: kExercises[i].$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kExercises[i].$1,
                              style: WithMeText.option.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selected == i
                                    ? Colors.white
                                    : WithMeColors.ink,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              kExercises[i].$2,
                              style: WithMeText.caption.copyWith(
                                color: _selected == i
                                    ? Colors.white
                                    : WithMeColors.inkSoft,
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
          ],
        ],
      ),
    );
  }
}
