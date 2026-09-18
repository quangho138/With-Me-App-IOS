import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'AboutScreen.dart';
import 'HelpScreen.dart';
import 'MembershipScreen.dart';
import 'NotificationsScreen.dart';
import 'ProfileScreen.dart';
import 'SettingsScreen.dart';
import 'WelcomeScreen.dart';

/// `image40.png` — the menu.
///
/// A 94 pt profile card, then eight 55 pt rows on a 9.5 pt gap, closing on
/// "Small steps, bright futures" in the accent script.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const String route = '/menu';

  @override
  Widget build(BuildContext context) {
    void go(Widget screen) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));

    void notWired(String what) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$what is not wired up in this UI pass.')),
        );

    return WithMeScaffold(
      lockup: false,
      footnote: const AccentLine('Small steps, bright futures'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: WithMeSpace.md),
          WithMeCard(
            height: 94,
            radius: 22,
            padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
            child: Row(
              children: [
                const WithMeAvatarBadge(size: 54),
                const SizedBox(width: WithMeSpace.md),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'With Me',
                      style: WithMeText.wordmark.copyWith(fontSize: 28),
                    ),
                    Text('Here. With you.', style: WithMeText.body),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          MenuRow(label: 'My Profile', onTap: () => go(const ProfileScreen())),
          const SizedBox(height: 10),
          MenuRow(
            label: 'Notifications',
            onTap: () => go(const NotificationsScreen()),
          ),
          const SizedBox(height: 10),
          MenuRow(label: 'Settings', onTap: () => go(const SettingsScreen())),
          const SizedBox(height: 10),
          MenuRow(
            label: 'Privacy & data',
            onTap: () => notWired('Privacy & data'),
          ),
          const SizedBox(height: 10),
          MenuRow(label: 'About', onTap: () => go(const WithMeAboutScreen())),
          const SizedBox(height: 10),
          MenuRow(label: 'Help', onTap: () => go(const HelpScreen())),
          const SizedBox(height: 10),
          MenuRow(
            label: 'Membership',
            onTap: () => go(const MembershipScreen()),
          ),
          const SizedBox(height: 10),
          MenuRow(
            label: 'Log out',
            danger: true,
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            ),
          ),
        ],
      ),
    );
  }
}
