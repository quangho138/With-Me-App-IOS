import 'package:flutter/material.dart';

import '../Components/WithMeBackdrop.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeWordmark.dart';
import '../Mascot/MascotExpression.dart';
import '../Theme/WithMeTheme.dart';
import 'WithMeGreetingScreen.dart';

class WithMeWelcomeScreen extends StatelessWidget {
  const WithMeWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          expression: MascotExpression.happy,
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
                        const SizedBox(height: 260),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(WithMeSpace.lg),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
                            boxShadow: WithMeSpace.cardShadow,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'A calmer, happier you is possible.',
                                textAlign: TextAlign.center,
                                style: WithMeText.question.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: WithMeSpace.lg),
                              WithMeButton(
                                label: 'Enter With Me',
                                onPressed: () => _enter(context),
                              ),
                              const SizedBox(height: WithMeSpace.md),
                              WithMeButton(
                                label: 'See companion demo',
                                filled: false,
                                onPressed: () => _enter(context),
                              ),
                            ],
                          ),
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
