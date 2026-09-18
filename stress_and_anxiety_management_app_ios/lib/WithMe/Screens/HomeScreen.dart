import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'CheckInScreen.dart';
import 'DashboardScreen.dart';
import 'ExerciseChooseScreen.dart';
import 'MenuScreen.dart';
import 'MonthlyCalendarScreen.dart';

/// `image5.png` — Home.
///
/// Measured: the welcome card is 342 x 93 at y 294 with a 20 pt radius; the
/// quick-actions panel holds four 55 pt rows inset 16 from the panel edge
/// (x 40 against the page's 24), the first filled teal.
class WithMeHomeScreen extends StatefulWidget {
  const WithMeHomeScreen({super.key});

  static const String route = '/home';

  @override
  State<WithMeHomeScreen> createState() => _WithMeHomeScreenState();
}

class _WithMeHomeScreenState extends State<WithMeHomeScreen> {
  String? _name;

  @override
  void initState() {
    super.initState();
    DatabaseHelper()
        .getUserName()
        .then((name) {
          if (mounted) setState(() => _name = name);
        })
        // Greeting the user by name is a nicety; without a database the
        // screen just says "Welcome back!".
        .catchError((_) {});
  }

  void _go(Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final greeting =
        _name == null || _name!.isEmpty ? 'Welcome back!' : 'Welcome back, $_name!';

    return WithMeScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuHeader(onTap: () => _go(const MenuScreen())),
          const SizedBox(height: WithMeSpace.lg),
          const Center(
            child: WithMeAvatar(size: 99, expression: MascotExpression.happy),
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(
              horizontal: WithMeSpace.lg,
              vertical: WithMeSpace.lg,
            ),
            child: Column(
              children: [
                Text(
                  greeting,
                  style: WithMeText.option.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: WithMeColors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What would you like to do?',
                  style: WithMeText.body.copyWith(color: WithMeColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: WithMeSpace.lg),
          _QuickActions(
            onCheckIn: () => _go(const CheckInScreen()),
            onDashboard: () => _go(const DashboardScreen()),
            onExercises: () => _go(const ExerciseChooseScreen()),
            onCalendar: () => _go(const MonthlyCalendarScreen()),
          ),
        ],
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          const Icon(Icons.menu_rounded, size: 26, color: WithMeColors.teal),
          const SizedBox(width: WithMeSpace.md),
          Text(
            'Home',
            style: WithMeText.title.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

/// The peach panel with the four shortcuts.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onCheckIn,
    required this.onDashboard,
    required this.onExercises,
    required this.onCalendar,
  });

  final VoidCallback onCheckIn;
  final VoidCallback onDashboard;
  final VoidCallback onExercises;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WithMeSpace.lg),
      decoration: BoxDecoration(
        color: WithMeColors.peach.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: SectionLabel('Quick actions')),
          const SizedBox(height: WithMeSpace.md),
          _Action(label: 'CHECK IN', filled: true, onTap: onCheckIn),
          const SizedBox(height: WithMeSpace.md),
          _Action(label: 'DASHBOARD', onTap: onDashboard),
          const SizedBox(height: WithMeSpace.md),
          _Action(label: 'IMMEDIATE EXERCISES', onTap: onExercises),
          const SizedBox(height: WithMeSpace.md),
          _Action(label: 'MONTHLY CALENDAR', onTap: onCalendar),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: WithMeSpace.rowHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? WithMeColors.teal : WithMeColors.cream,
          borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Text(
          label,
          style: WithMeText.option.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: filled ? Colors.white : WithMeColors.teal,
          ),
        ),
      ),
    );
  }
}
