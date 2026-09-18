import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// `image38.png` — "Stay on Track".
///
/// Three timing choices and a repeat toggle. Like the notifications screen,
/// nothing is scheduled — there is no notifications plugin in the project.
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  static const String route = '/reminder';

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  int _choice = 1;
  bool _everyDay = true;

  static const List<(String, String?)> _choices = [
    ('Later today', null),
    ('Tomorrow morning', '8:00'),
    ('Custom time', null),
  ];

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      lockup: false,
      action: WithMeButton(
        label: 'Save Reminder',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder saved. Scheduling comes later.'),
            ),
          );
          Navigator.of(context).pop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: WithMeSpace.xl),
          WithMeCard(
            child: Column(
              children: [
                Text('Stay on Track', style: WithMeText.title),
                const SizedBox(height: WithMeSpace.sm),
                Text(
                  'Set a reminder for your next check-in.',
                  textAlign: TextAlign.center,
                  style: WithMeText.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: WithMeSpace.lg),
          for (var i = 0; i < _choices.length; i++) ...[
            if (i > 0) const SizedBox(height: WithMeSpace.md),
            OptionRow(
              label: _choices[i].$1,
              trailing: _choices[i].$2,
              selected: _choice == i,
              onTap: () => setState(() => _choice = i),
            ),
          ],
          const SizedBox(height: WithMeSpace.md),
          ToggleRow(
            label: 'Every day',
            value: _everyDay,
            onChanged: (v) => setState(() => _everyDay = v),
          ),
          const SizedBox(height: WithMeSpace.xl),
          const Center(
            child: WithMeAvatar(size: 140, expression: MascotExpression.happy),
          ),
        ],
      ),
    );
  }
}
