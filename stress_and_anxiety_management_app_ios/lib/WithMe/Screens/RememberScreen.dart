import 'package:flutter/material.dart';

import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// `image39.png` — "Remember...".
///
/// The five promises, in the accent script at the top and as dotted rows
/// below. This is the companion's statement of what it is and is not, so the
/// disclaimer at the foot is part of the screen, not decoration.
class RememberScreen extends StatelessWidget {
  const RememberScreen({super.key});

  static const String route = '/remember';

  static const List<(String, Color)> promises = [
    ("You're not alone.", WithMeColors.mint),
    ('I listen.', WithMeColors.peach),
    ('I understand.', WithMeColors.pink),
    ('I help you take the next step.', WithMeColors.coral),
    ("You've got this!", WithMeColors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      lockup: false,
      footnote: Text(
        'With Me is a companion, not a substitute for professional care.',
        textAlign: TextAlign.center,
        style: WithMeText.caption.copyWith(color: WithMeColors.inkSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: WithMeSpace.lg),
          Text(
            'Remember...',
            textAlign: TextAlign.center,
            style: WithMeText.wordmark.copyWith(fontSize: 32),
          ),
          const SizedBox(height: WithMeSpace.lg),
          for (var i = 0; i < promises.length; i++) ...[
            if (i > 0) const SizedBox(height: WithMeSpace.md),
            OptionRow(
              label: promises[i].$1,
              dot: promises[i].$2,
              selected: false,
              onTap: () {},
            ),
          ],
          const SizedBox(height: WithMeSpace.xl),
          const Center(
            child: WithMeAvatar(
              size: 140,
              expression: MascotExpression.encouraging,
            ),
          ),
        ],
      ),
    );
  }
}
