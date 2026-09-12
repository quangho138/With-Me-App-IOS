import 'package:flutter/material.dart';
import '../Components/ActionButton.dart';
import '../WithMe/Screens/WithMeGreetingScreen.dart';
import '../Screens/CalendarScreen.dart';
import '../Screens/CalendarScreenWithCallback.dart';
import '../Screens/MoodSelectionScreen.dart';
import '../Screens/SelfReflectionScreen.dart';

class HomeViewModel {
  List<Widget> getButtons(BuildContext context) {
    return [
      ActionButton(
        label: 'Talk to With Me',
        icon: Icons.favorite,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WithMeGreetingScreen()),
        ),
      ),
      const SizedBox(height: 12),
      ActionButton(
        label: 'Dashboard',
        icon: Icons.dashboard,
        onPressed: () => Navigator.pushNamed(context, '/dashboard'),
      ),
      const SizedBox(height: 12),
      ActionButton(
        label: 'Awareness Questions',
        icon: Icons.help,
        onPressed: () {
          _showDateSelectionDialog(context);
        },
      ),
      const SizedBox(height: 12),
      ActionButton(
        label: 'Breathing Exercise',
        icon: Icons.air,
        onPressed: () => Navigator.pushNamed(context, '/breathing-exercise'),
      ),
      const SizedBox(height: 12),
      ActionButton(
        label: 'Mood Tracker',
        icon: Icons.emoji_emotions,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarScreenWithCallback(
                onDateSelected: (selectedDate) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoodSelectionScreen(selectedDate: selectedDate),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      // ActionButton(
      //   label: 'Monthly Calendar',
      //   icon: Icons.calendar_today,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const CalendarScreen(),
      //       ),
      //     );
      //   },
      // ),
    ];
  }

  List<Map<String, dynamic>> getMenuItems() {
    return [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.help, 'label': 'Awareness Questions'},
      {'icon': Icons.emoji_emotions, 'label': 'Mood Tracker'},
      //{'icon': Icons.calendar_today, 'label': 'Monthly Calendar'},
    ];
  }

  void _showDateSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2F3941),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'When would you like to reflect?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose to reflect on today\'s experiences or select a different date.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToReflection(context, DateTime.now());
                  },
                  icon: const Icon(Icons.today, color: Colors.white),
                  label: const Text(
                    'Use Today\'s Date',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF546E7A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.maxFinite,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToCalendarSelection(context);
                  },
                  icon: const Icon(Icons.calendar_month, color: Colors.white70),
                  label: const Text(
                    'Choose Different Date',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                builder: (context) => SelfReflectScreen(selectedDate: selectedDate),
              ),
            );
          },
        ),
      ),
    );
  }
}
