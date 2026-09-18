import 'package:flutter/material.dart';

import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// `image42.png` — Notifications.
///
/// Four toggle rows, a quiet-hours field, then the mascot and Save.
///
/// Nothing is scheduled: the project has no notifications plugin, so these are
/// preferences with no delivery behind them yet.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String route = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dailyCheckIn = true;
  bool _exerciseNudge = false;
  bool _weeklySummary = true;
  bool _encouragement = true;

  final _quietHours = TextEditingController(text: '10:00 PM – 7:30 AM');

  @override
  void dispose() {
    _quietHours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Notifications',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Save',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences saved on this device.')),
          );
          Navigator.of(context).pop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToggleRow(
            label: 'Daily check-in reminder',
            value: _dailyCheckIn,
            onChanged: (v) => setState(() => _dailyCheckIn = v),
          ),
          const SizedBox(height: WithMeSpace.md),
          ToggleRow(
            label: 'Exercise nudge',
            value: _exerciseNudge,
            onChanged: (v) => setState(() => _exerciseNudge = v),
          ),
          const SizedBox(height: WithMeSpace.md),
          ToggleRow(
            label: 'Weekly insight summary',
            value: _weeklySummary,
            onChanged: (v) => setState(() => _weeklySummary = v),
          ),
          const SizedBox(height: WithMeSpace.md),
          ToggleRow(
            label: 'Encouragement notes',
            value: _encouragement,
            onChanged: (v) => setState(() => _encouragement = v),
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeField(label: 'Quiet hours', controller: _quietHours),
          const SizedBox(height: WithMeSpace.lg),
          const Center(
            child: WithMeAvatar(size: 120, expression: MascotExpression.happy),
          ),
        ],
      ),
    );
  }
}
