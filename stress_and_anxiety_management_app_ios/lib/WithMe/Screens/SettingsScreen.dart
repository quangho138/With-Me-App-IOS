import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';
import 'WelcomeScreen.dart';

/// `image41.png` — Settings.
///
/// Three 63 pt toggle rows, then six 55 pt rows, the last of them destructive.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String route = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _haptics = true;
  bool _voice = true;

  void _notWired(String what) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$what is not wired up in this UI pass.')),
      );

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WithMeColors.creamLight,
        title: Text('Delete my account', style: WithMeText.title.copyWith(fontSize: 19)),
        content: Text(
          'This clears your check-ins, reflections and name from this device. '
          'It cannot be undone.',
          style: WithMeText.body.copyWith(color: WithMeColors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: WithMeText.option),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: WithMeText.option.copyWith(
                color: WithMeColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await DatabaseHelper().deleteAllData();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Settings',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToggleRow(
            label: 'Sound effects',
            value: _sound,
            onChanged: (v) => setState(() => _sound = v),
          ),
          const SizedBox(height: WithMeSpace.md),
          ToggleRow(
            label: 'Haptics',
            value: _haptics,
            onChanged: (v) => setState(() => _haptics = v),
          ),
          const SizedBox(height: WithMeSpace.md),
          ToggleRow(
            label: 'Voice input',
            value: _voice,
            onChanged: (v) => setState(() => _voice = v),
          ),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(
            label: 'Language — English',
            onTap: () => _notWired('Language'),
          ),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(label: 'Text size', onTap: () => _notWired('Text size')),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(label: 'Theme — Sunset', onTap: () => _notWired('Theme')),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(
            label: 'Privacy & data',
            onTap: () => _notWired('Privacy & data'),
          ),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(
            label: 'Export my data',
            onTap: () => _notWired('Export'),
          ),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(
            label: 'Delete my account',
            danger: true,
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
