import 'package:flutter/material.dart';

import 'WithMe/Screens/AboutScreen.dart';
import 'WithMe/Screens/BeforeWeStartScreen.dart';
import 'WithMe/Screens/BreathingScreen.dart';
import 'WithMe/Screens/CheckInScreen.dart';
import 'WithMe/Screens/CreateAccountScreen.dart';
import 'WithMe/Screens/DashboardScreen.dart';
import 'WithMe/Screens/ExerciseChooseScreen.dart';
import 'WithMe/Screens/HelpScreen.dart';
import 'WithMe/Screens/HomeScreen.dart';
import 'WithMe/Screens/LoginScreen.dart';
import 'WithMe/Screens/LogsScreen.dart';
import 'WithMe/Screens/MembershipScreen.dart';
import 'WithMe/Screens/MenuScreen.dart';
import 'WithMe/Screens/MonthlyCalendarScreen.dart';
import 'WithMe/Screens/NotificationsScreen.dart';
import 'WithMe/Screens/ProfileScreen.dart';
import 'WithMe/Screens/ProgressScreen.dart';
import 'WithMe/Screens/RememberScreen.dart';
import 'WithMe/Screens/ReminderScreen.dart';
import 'WithMe/Screens/ResetPasswordScreen.dart';
import 'WithMe/Screens/RestYourMindScreen.dart';
import 'WithMe/Screens/SettingsScreen.dart';
import 'WithMe/Screens/SoundscapeScreen.dart';
import 'WithMe/Screens/StrategiesActionsScreen.dart';
import 'WithMe/Screens/TriggersSignsScreen.dart';
import 'WithMe/Screens/WelcomeScreen.dart';
import 'WithMe/Screens/YourDayScreen.dart';
import 'WithMe/Theme/WithMeTheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The database is not wiped on launch — the logs have to survive a restart.
  runApp(const WithMeApp());
}

/// With Me.
///
/// The app is now the design in `WITH ME Complete App Design V1.docx` end to
/// end, so the theme lives here rather than being re-applied per screen, and
/// the entry route is the welcome screen (`image1.png`) rather than the old
/// HOWRU.LIFE login.
class WithMeApp extends StatelessWidget {
  const WithMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'With Me',
      theme: buildWithMeTheme(),
      initialRoute: WelcomeScreen.route,
      routes: {
        // Onboarding — image1 to image4
        WelcomeScreen.route: (_) => const WelcomeScreen(),
        CreateAccountScreen.route: (_) => const CreateAccountScreen(),
        WithMeLoginScreen.route: (_) => const WithMeLoginScreen(),
        ResetPasswordScreen.route: (_) => const ResetPasswordScreen(),
        ProfileScreen.route: (_) => const ProfileScreen(),

        // Home and calendar — image5, image6
        WithMeHomeScreen.route: (_) => const WithMeHomeScreen(),
        MonthlyCalendarScreen.route: (_) => const MonthlyCalendarScreen(),

        // The check-in — image7 to image24
        CheckInScreen.route: (_) => const CheckInScreen(),

        // Exercises — image25 to image31
        ExerciseChooseScreen.route: (_) => const ExerciseChooseScreen(),
        RestYourMindScreen.route: (_) => const RestYourMindScreen(),
        BeforeWeStartScreen.route: (_) => const BeforeWeStartScreen(),
        BreathingScreen.route: (_) => const BreathingScreen(),
        SoundscapeScreen.route: (_) => const SoundscapeScreen(),

        // Dashboard — image32 to image39
        DashboardScreen.route: (_) => const DashboardScreen(),
        TriggersSignsScreen.route: (_) => const TriggersSignsScreen(),
        StrategiesActionsScreen.route: (_) => const StrategiesActionsScreen(),
        YourDayScreen.route: (_) => const YourDayScreen(),
        ProgressScreen.route: (_) => const ProgressScreen(),
        ReminderScreen.route: (_) => const ReminderScreen(),
        RememberScreen.route: (_) => const RememberScreen(),

        // Menu and settings — image40 to image45
        MenuScreen.route: (_) => const MenuScreen(),
        SettingsScreen.route: (_) => const SettingsScreen(),
        NotificationsScreen.route: (_) => const NotificationsScreen(),
        MembershipScreen.route: (_) => const MembershipScreen(),
        WithMeAboutScreen.route: (_) => const WithMeAboutScreen(),
        HelpScreen.route: (_) => const HelpScreen(),
        LogsScreen.route: (_) => const LogsScreen(),
      },
    );
  }
}
