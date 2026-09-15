import 'package:flutter/material.dart';

import '../Components/ActionButton.dart';
import '../Screens/CalendarScreenWithCallback.dart';
import '../Screens/MoodSelectionScreen.dart';
import '../Screens/SelfReflectionScreen.dart';
import '../WithMe/Screens/WithMeGreetingScreen.dart';
import '../WithMe/Theme/WithMeTheme.dart';

class HomeViewModel {
  List<Widget> getButtons(BuildContext context) {
    return [
      ActionButton(
        label: 'Talk to With Me',
        icon: Icons.favorite_rounded,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WithMeGreetingScreen()),
        ),
      ),
      const SizedBox(height: WithMeSpace.sm),
      ActionButton(
        label: 'Dashboard',
        icon: Icons.dashboard_rounded,
        onPressed: () => Navigator.pushNamed(context, '/dashboard'),
      ),
      const SizedBox(height: WithMeSpace.sm),
      ActionButton(
        label: 'Awareness Questions',
        icon: Icons.psychology_alt_rounded,
        onPressed: () => _showDateSelectionDialog(context),
      ),
      const SizedBox(height: WithMeSpace.sm),
      ActionButton(
        label: 'Breathing Exercise',
        icon: Icons.air_rounded,
        onPressed: () => Navigator.pushNamed(context, '/breathing-exercise'),
      ),
      const SizedBox(height: WithMeSpace.sm),
      ActionButton(
        label: 'Mood Tracker',
        icon: Icons.emoji_emotions_rounded,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarScreenWithCallback(
                onDateSelected: (selectedDate) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoodSelectionScreen(
                        selectedDate: selectedDate,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Map<String, dynamic>> getMenuItems() {
    return [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.psychology_alt_rounded, 'label': 'Awareness Questions'},
      {'icon': Icons.emoji_emotions_rounded, 'label': 'Mood Tracker'},
    ];
  }

  void _showDateSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: WithMeColors.creamLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
          ),
          title: const Text(
            'When would you like to reflect?',
            style: WithMeText.question,
          ),
          content: const Text(
            "Choose today's experiences or select a different date.",
            style: WithMeText.body,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            WithMeSpace.lg,
            0,
            WithMeSpace.lg,
            WithMeSpace.lg,
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToReflection(context, DateTime.now());
                  },
                  icon: const Icon(Icons.today_rounded),
                  label: const Text('Use today'),
                ),
                const SizedBox(height: WithMeSpace.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToCalendarSelection(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WithMeColors.teal,
                    side: const BorderSide(color: WithMeColors.teal),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        WithMeSpace.radiusPill,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Choose a different date'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _navigateToReflection(BuildContext context, DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfReflectScreen(selectedDate: selectedDate),
      ),
    );
  }

  void _navigateToCalendarSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarScreenWithCallback(
          onDateSelected: (selectedDate) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelfReflectScreen(
                  selectedDate: selectedDate,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
