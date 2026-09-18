import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';

/// Help.
///
/// The V1 menu (`image40.png`) has a "Help" row but the design document never
/// shows the screen behind it. Rather than lose the answers the old FAQ screen
/// carried, they are kept here and restyled — the wording is the same, with
/// "HowRU" updated to the product's current name.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  static const String route = '/help';

  static const List<(String, String)> questions = [
    (
      'What is With Me?',
      'With Me is a mental wellness and stress management application '
          'designed to help you track emotional patterns and practise '
          'mindfulness.',
    ),
    (
      'How does With Me work?',
      'You can log emotions, track stress levels, and reach coping '
          'strategies like breathing exercises and journaling prompts.',
    ),
    (
      'Does With Me replace therapy?',
      'No. With Me is not a substitute for professional mental health care.',
    ),
    (
      'Is my data secure?',
      'Your logs are stored on this device.',
    ),
    (
      'Who can use With Me?',
      'Designed for ages 18+. Minors should have supervision.',
    ),
    (
      'Can I delete my data?',
      'Yes — Settings has "Delete my account", which clears everything on '
          'this device.',
    ),
    (
      'Does With Me share my info?',
      'No. Your data is not sold or shared with advertisers.',
    ),
    (
      "What if I'm in crisis?",
      'Please contact local emergency services or a crisis hotline.',
    ),
  ];

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Help',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < HelpScreen.questions.length; i++) ...[
            if (i > 0) const SizedBox(height: WithMeSpace.md),
            GestureDetector(
              onTap: () => setState(() => _open = _open == i ? null : i),
              behavior: HitTestBehavior.opaque,
              child: WithMeCard(
                radius: WithMeSpace.radiusMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            HelpScreen.questions[i].$1,
                            style: WithMeText.option.copyWith(
                              fontWeight: FontWeight.w600,
                              color: WithMeColors.teal,
                            ),
                          ),
                        ),
                        Icon(
                          _open == i
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 22,
                          color: WithMeColors.inkSoft,
                        ),
                      ],
                    ),
                    if (_open == i) ...[
                      const SizedBox(height: WithMeSpace.sm),
                      Text(
                        HelpScreen.questions[i].$2,
                        style:
                            WithMeText.body.copyWith(color: WithMeColors.ink),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
