import 'package:flutter/material.dart';

import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'CreateAccountScreen.dart';
import 'LoginScreen.dart';

/// `image1.png` — the first screen.
///
/// Measured: the three buttons sit at y 536 / 608 / 680 with a 12 pt gap; the
/// first two are 60 tall and the Google button 52.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      lockup: false,
      scrollable: false,
      child: Column(
        children: [
          const SizedBox(height: WithMeSpace.xxl),
          Text('With Me', style: WithMeText.wordmark.copyWith(fontSize: 44)),
          const SizedBox(height: WithMeSpace.sm),
          Text(
            'Your AI Companion',
            style: WithMeText.option.copyWith(
              fontWeight: FontWeight.w600,
              color: WithMeColors.teal,
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          const Text('Here. With you.', style: WithMeText.accent),
          const Spacer(),
          const WithMeAvatar(size: 139, expression: MascotExpression.happy),
          const Spacer(),
          WithMeButton(
            label: 'Sign Up',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          WithMeButton(
            label: 'Log In',
            filled: false,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WithMeLoginScreen()),
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          const _GoogleButton(),
          const SizedBox(height: WithMeSpace.lg),
          Text(
            'A calmer, happier you is possible.',
            style: WithMeText.caption.copyWith(color: WithMeColors.inkSoft),
          ),
          const SizedBox(height: WithMeSpace.sm),
        ],
      ),
    );
  }
}

/// Measured at 52 tall rather than the 60 of the two above it.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in is not wired up in this UI pass.'),
        ),
      ),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WithMeColors.cream,
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'G',
                style: TextStyle(
                  fontFamily: WithMeText.ui,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: WithMeSpace.md),
            Flexible(
              child: Text(
                'Continue with Google',
                style: WithMeText.option.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
