import 'package:flutter/material.dart';

import '../WithMe/Components/CompanionFab.dart';
import '../WithMe/Components/WithMeBackdrop.dart';
import '../WithMe/Theme/WithMeTheme.dart';
import 'NavBar.dart';

/// Shared shell for the legacy screens, visually aligned with the reference
/// "With Me" check-in design while preserving the existing navigation.
class MainScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MainScaffold({super.key, required this.body, this.title = 'HOWRU.LIFE'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: WithMeColors.sand,
      appBar: NavBar(scaffoldKey: _scaffoldKey),
      drawer: Drawer(
        backgroundColor: WithMeColors.creamLight,
        surfaceTintColor: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              _drawerHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: WithMeSpace.sm),
                  children: [
                    _drawerItem(
                      icon: Icons.favorite_rounded,
                      label: 'With Me Companion',
                      context: context,
                      onTap: () => _navigateTo(context, '/with-me/chat'),
                    ),
                    _drawerItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      context: context,
                      onTap: () => _navigateTo(context, '/dashboard'),
                    ),
                    _drawerItem(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Membership',
                      context: context,
                      onTap: () => _navigateTo(context, '/membership'),
                    ),
                    _drawerItem(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      context: context,
                      onTap: () => _navigateTo(context, '/settings'),
                    ),
                    _drawerItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About',
                      context: context,
                      onTap: () => _navigateTo(context, '/about'),
                    ),
                    _drawerItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Frequently Asked Questions',
                      context: context,
                      onTap: () => _navigateTo(context, '/faq'),
                    ),
                    const Divider(height: WithMeSpace.xl),
                    _drawerItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      context: context,
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/logout',
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: WithMeBackdrop(child: body),
      floatingActionButton: const CompanionFab(),
    );
  }

  Widget _drawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        WithMeSpace.lg,
        WithMeSpace.lg,
        WithMeSpace.lg,
        WithMeSpace.md,
      ),
      decoration: BoxDecoration(
        color: WithMeColors.tealSoft.withValues(alpha: 0.65),
        border: Border(
          bottom: BorderSide(
            color: WithMeColors.teal.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: WithMeSpace.sm),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: WithMeColors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: WithMeSpace.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: WithMeText.title.copyWith(fontSize: 20)),
                  const SizedBox(height: 2),
                  const Text('Your space to check in', style: WithMeText.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.sm,
        vertical: 2,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
        ),
        leading: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: WithMeColors.tealSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: WithMeColors.teal, size: 19),
        ),
        title: Text(label, style: WithMeText.option),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: WithMeColors.inkFaint,
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }
}
