import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'Screens/HomeScreen.dart';
import 'Screens/AboutScreen.dart';
import 'Screens/DashboardScreen.dart';
import 'Screens/BreathingExercisesSelectionScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/SignUpScreen.dart';
import 'Screens/FaqScreen.dart';
import 'Screens/SettingScreen.dart';
import 'WithMe/Screens/CheckInScreen.dart';
import 'WithMe/Screens/CompanionChatScreen.dart';
import 'WithMe/Screens/MascotGalleryScreen.dart';
import 'WithMe/Screens/WithMeGreetingScreen.dart';
import 'WithMe/Screens/WithMeWelcomeScreen.dart';
import 'WithMe/Theme/WithMeTheme.dart';

/// Entry point of the Flutter application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // On web (Chrome) SQLite has no native library, so point the database at
  // the web implementation. On phones/desktop the default factory is used.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  // The database is no longer wiped on launch — the companion needs its
  // conversation history and the user's logs to survive a restart.
  runApp(const MyApp()); // Runs the root widget of the app
}

/// Root widget of the app, extending StatelessWidget because the app state
/// does not need to be mutable at this level
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the main wrapper that provides material design styling,
    // themes, navigation, and routes to the app.
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Hides the debug banner in the top-right
      title: 'HOWRU.LIFE', // App title shown in task manager or window
      // Use the warm cream / teal visual system from the reference UI as
      // the default theme. Screens with their own local styling can still
      // override it, but shared controls now feel like one product.
      theme: buildWithMeTheme(),

      // Routes define named navigation paths for different screens
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(), // Main home screen
        '/about': (context) => const AboutScreen(), // About screen
        '/dashboard': (context) =>
            const DashboardScreen(), // Dashboard with stats and recent reflections
        '/breathing-exercise': (context) =>
            const BreathingExercisesSelectionScreen(), // Breathing exercises for stress relief
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/logout': (context) => const LoginScreen(),
        '/faq': (context) => const FaqScreen(), // FAQ Screen
        '/settings': (context) => const SettingScreen(),
        // Placeholder screens for features not implemented yet
        '/membership': (context) =>
            const PlaceholderScreen(title: 'Membership'),

        // --- With Me AI companion -------------------------------------------
        '/with-me': (context) => const WithMeWelcomeScreen(),
        '/with-me/greeting': (context) => const WithMeGreetingScreen(),
        '/with-me/chat': (context) => const CompanionChatScreen(),
        '/with-me/check-in': (context) => const CheckInScreen(),
        '/with-me/avatar': (context) => const MascotGalleryScreen(),
      },
    );
  }
}

/// A simple placeholder screen for pages not yet implemented.
/// Accepts a title to display in the AppBar and body.
class PlaceholderScreen extends StatelessWidget {
  final String title; // The title to display in AppBar and body

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold provides the basic material design layout structure:
      // AppBar at the top, Body in the main content area
      appBar: AppBar(
        title: Text(title), // Displays the passed-in title
      ),
      body: Center(
        child: Text(
          title == 'Membership' 
            ? 'Membership Prices Coming soon' 
            : 'This is the $title page', // Simple placeholder text in the center
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
