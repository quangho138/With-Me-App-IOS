import 'package:flutter/material.dart';

import '../Components/MainScaffold.dart';
import '../Components/WelcomeCardComponent.dart';
import '../ViewModels/HomeViewModel.dart';
import '../WithMe/Mascot/MascotExpression.dart';
import '../WithMe/Mascot/WithMeAvatar.dart';
import '../WithMe/Theme/WithMeTheme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = HomeViewModel();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 420 ? 18.0 : 24.0;

    return MainScaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            WithMeSpace.xl,
            horizontalPadding,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'YOUR SPACE',
                textAlign: TextAlign.center,
                style: WithMeText.sectionLabel,
              ),
              const SizedBox(height: WithMeSpace.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const WithMeAvatar(
                    size: 76,
                    expression: MascotExpression.encouraging,
                  ),
                  const SizedBox(width: WithMeSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How are you doing today?',
                          style: WithMeText.title.copyWith(
                            color: WithMeColors.ink,
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Choose what feels most useful right now.',
                          style: WithMeText.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WithMeSpace.md),
              WelcomeCard(
                fontSize: screenWidth < 420 ? 18 : 20,
                padding: screenWidth < 420 ? 16 : 18,
              ),
              const SizedBox(height: WithMeSpace.xl),
              Text(
                'WHAT WOULD YOU LIKE TO DO?',
                style: WithMeText.sectionLabel.copyWith(
                  color: WithMeColors.inkSoft,
                ),
              ),
              const SizedBox(height: WithMeSpace.sm),
              ...viewModel.getButtons(context),
            ],
          ),
        ),
      ),
    );
  }
}
