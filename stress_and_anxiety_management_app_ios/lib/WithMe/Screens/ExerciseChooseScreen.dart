import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Data/CheckInSteps.dart';
import '../Theme/WithMeTheme.dart';
import 'BeforeWeStartScreen.dart';
import 'BreathingScreen.dart';
import 'RestYourMindScreen.dart';

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
      1 => const BeforeWeStartScreen(pattern: BreathPattern.box),
      2 => const BeforeWeStartScreen(pattern: BreathPattern.fourSevenEight),
      _ => const RestYourMindScreen(),
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
            OptionRow(
              label: kExercises[i].$1,
              subtitle: kExercises[i].$2.isEmpty ? null : kExercises[i].$2,
              dot: kExercises[i].$3,
              selected: _selected == i,
              onTap: () => setState(() => _selected = i),
            ),
          ],
        ],
      ),
    );
  }
}
