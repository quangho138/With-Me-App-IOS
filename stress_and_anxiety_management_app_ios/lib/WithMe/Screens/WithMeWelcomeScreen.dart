import 'package:flutter/material.dart';

import '../Components/WithMeBackdrop.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeWordmark.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'WithMeGreetingScreen.dart';

/// Storyboard 1 — Welcome / Login.
///
/// UI only: the buttons route into the companion experience rather than
/// performing authentication. Wiring them to the existing auth screens is a
/// later step.
class WithMeWelcomeScreen extends StatelessWidget {
  const WithMeWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WithMeSpace.xl,
                      vertical: WithMeSpace.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: WithMeSpace.lg),
                        const WithMeWordmark(),
                        const WithMeAvatar(
                          size: 180,
                          expression: MascotExpression.happy,
                        ),
                        const SizedBox(height: WithMeSpace.sm),
                        WithMeButton(
                          label: 'Sign Up',
                          onPressed: () => _enter(context),
                        ),
                        const SizedBox(height: WithMeSpace.md),
                        WithMeButton(
                          label: 'Login',
                          filled: false,
                          onPressed: () => _enter(context),
                        ),
                        const SizedBox(height: WithMeSpace.md),
                        const _GoogleButton(),
                        const SizedBox(height: WithMeSpace.lg),
                        Text(
                          'A calmer, happier you is possible.',
                          style: WithMeText.tagline.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: WithMeSpace.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _enter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WithMeGreetingScreen()),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
        label: Text(
          'Continue with Google',
          style: WithMeText.option.copyWith(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          side: BorderSide(color: WithMeColors.inkFaint.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
          ),
        ),
      ),
    );
  }
}
