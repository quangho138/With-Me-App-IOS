import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// `image44.png` — About.
class WithMeAboutScreen extends StatelessWidget {
  const WithMeAboutScreen({super.key});

  static const String route = '/about';

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      onBack: () => Navigator.of(context).pop(),
      footnote: Text(
        'Version 1.0 · Made with care',
        style: WithMeText.caption.copyWith(color: WithMeColors.inkSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'With Me',
            textAlign: TextAlign.center,
            style: WithMeText.wordmark.copyWith(fontSize: 40),
          ),
          Text(
            'Your AI Companion',
            textAlign: TextAlign.center,
            style: WithMeText.option.copyWith(
              fontWeight: FontWeight.w600,
              color: WithMeColors.ink,
            ),
          ),
          const SizedBox(height: WithMeSpace.lg),
          const Center(
            child: WithMeAvatar(size: 82, expression: MascotExpression.happy),
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeCard(
            child: Text(
              'With Me was built for the moments between appointments — when '
              'stress arrives and you just need something steady to talk to. '
              'It listens, helps you name what is happening, and offers one '
              'small next step.',
              style: WithMeText.body.copyWith(color: WithMeColors.ink),
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          WithMeCard(
            radius: WithMeSpace.radiusMd,
            padding: const EdgeInsets.symmetric(
              horizontal: WithMeSpace.lg,
              vertical: WithMeSpace.md,
            ),
            child: Text(
              'With Me does not diagnose or treat, and is not a substitute '
              'for professional care.',
              // ink, matching the paragraph above it. image44 draws both
              // blocks the same darkness, and inkSoft made the one medical
              // disclaimer in the app the faintest text on the screen.
              style: WithMeText.body.copyWith(color: WithMeColors.ink),
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(
            label: 'Terms & Privacy Policy',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Terms are not wired up in this UI pass.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
