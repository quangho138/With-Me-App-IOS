import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:stress_and_anxiety_management_app_ios/Database/LocalDatabase.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/AboutScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/BeforeWeStartScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/BreathingScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/CheckInScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/CreateAccountScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/DashboardScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/DayDetailScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ExerciseChooseScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/HelpScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/HomeScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/LoginScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/LogsScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/MembershipScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/MenuScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/MonthlyCalendarScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/NotificationsScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ProfileScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ProgressScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/RememberScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ReminderScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ResetPasswordScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/RestYourMindScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/SettingsScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/SoundscapeScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/StrategiesActionsScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/TriggersSignsScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/WelcomeScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/YourDayScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Theme/WithMeTheme.dart';

/// Renders every screen at the reference device size and writes it to
/// `test/goldens/`, so the build can be compared against the mockups rather
/// than eyeballed.
///
///     flutter test --update-goldens test/golden_screens_test.dart
///     python ../tool/compare_screens.py
///
/// Run as a normal test afterwards, it fails on any visual change.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
    _stubPlatformChannels();
    await _seedDatabase();
  });

  for (final entry in _screens.entries) {
    testWidgets('golden: ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      // The mockups include the status bar in their 590 px frame, so the
      // goldens need the device's insets for the two to line up - and for the
      // captures to show what a real iPhone shows.
      tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      tester.view.viewPadding =
          const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildWithMeTheme(),
          home: entry.value(),
        ),
      );
      // The screens load their data in initState. tester.pump advances the
      // fake clock but never lets real async work run, so without this the
      // dashboard, calendar, logs and progress screens all capture their
      // empty state and the user's name never arrives. Alternating real time
      // with a pump lets a chain of awaits finish, not just the first one.
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        await tester.pump();
      }

      // Then settle the entry animations, without waiting on the mascot's
      // breath, which never stops.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
    });
  }
}

/// Screen name -> builder. Named after the mockup each one is built from, so
/// `tool/compare_screens.py` can pair them up.
final Map<String, Widget Function()> _screens = {
  'image1-welcome': () => const WelcomeScreen(),
  'image2-create-account': () => const CreateAccountScreen(),
  'image3-reset-password': () => const ResetPasswordScreen(),
  'image4-profile': () => const ProfileScreen(),
  'image5-home': () => const WithMeHomeScreen(),
  'image6-monthly-calendar': () => const MonthlyCalendarScreen(),
  'image7to24-check-in': () => const CheckInScreen(),
  'image25-exercise-choose': () => const ExerciseChooseScreen(),
  'image26-rest-your-mind': () => const RestYourMindScreen(),
  'image27-breathing-478': () => const BreathingScreen(),
  'image28-box-breathing-info': () => const BoxBreathingInfoScreen(),
  'image29-breathing-4444': () =>
      const BreathingScreen(pattern: BreathPattern.box),
  'image30-before-we-start': () => const BeforeWeStartScreen(),
  'image31-soundscape': () => const SoundscapeScreen(),
  'image32-insights': () => const DashboardScreen(),
  'image33-triggers-and-signs': () => const TriggersSignsScreen(),
  'image34-strategies-and-actions': () => const StrategiesActionsScreen(),
  // Yesterday, so it lands on a seeded entry and can be compared against a
  // mockup that shows a filled-in day.
  'image35-day-detail': () => DayDetailScreen(
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
  'image36-your-day': () => const YourDayScreen(),
  'image37-progress': () => const ProgressScreen(),
  'image38-reminder': () => const ReminderScreen(),
  'image39-remember': () => const RememberScreen(),
  'image40-menu': () => const MenuScreen(),
  'image41-settings': () => const SettingsScreen(),
  'image42-notifications': () => const NotificationsScreen(),
  'image43-membership': () => const MembershipScreen(),
  'image44-about': () => const WithMeAboutScreen(),
  'image45-logs': () => const LogsScreen(),
  'login': () => const WithMeLoginScreen(),
  'help': () => const HelpScreen(),
};

/// Goldens render with a blank test font unless the real faces are loaded, so
/// type metrics would not be comparable to the mockups.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(
        File(path).readAsBytes().then((bytes) => bytes.buffer.asByteData()),
      );
    }
    await loader.load();
  }

  await load('Quicksand', [
    'assets/fonts/Quicksand-400.ttf',
    'assets/fonts/Quicksand-500.ttf',
    'assets/fonts/Quicksand-600.ttf',
    'assets/fonts/Quicksand-700.ttf',
  ]);
  await load('Yellowtail', ['assets/fonts/Yellowtail-Regular.ttf']);

  // Without this every Icon renders as an empty box and the comparison
  // sheets make the chevrons and the hamburger look broken.
  final icons = File(
    '${_flutterRoot()}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    await load('MaterialIcons', [icons.path]);
  }
}

/// Where the SDK keeps the bundled Material icon font.
String _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // `flutter test` runs the Dart in the SDK's own cache, so walk up from it.
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    if (Directory('${dir.path}/bin/cache/artifacts').existsSync()) {
      return dir.path;
    }
    dir = dir.parent;
  }
  return 'C:/flutter';
}

/// sqflite and path_provider have no implementation in a widget test.
///
/// path_provider is a plain channel and can be stubbed. sqflite cannot — it
/// refuses to open a database off a supported platform — so the tests run it
/// on the FFI engine against a throwaway file. The screens then render their
/// real empty state rather than throwing.
void _stubPlatformChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => Directory.systemTemp.createTempSync('withme_golden').path,
  );

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Put a week of check-ins in the database.
///
/// Without it the dashboard, calendar, progress and logs screens all render
/// their empty state, which is correct behaviour but cannot be compared
/// against mockups that show a populated app.
Future<void> _seedDatabase() async {
  final db = DatabaseHelper();
  await db.saveUserName('Maya');

  const moods = ['Okay', 'Pretty good', 'Rough', 'Good', 'Okay', 'Low', 'Good'];
  const areas = ['Work', 'Home', 'Work', 'School', 'Social', 'Work', 'Home'];
  const detail = [
    'Workload, Time mgmt',
    'Financial',
    'Boss, Colleagues',
    'Exam pressure',
    'Social media',
    'Workload',
    'Domestic duties',
  ];

  final today = DateTime.now();
  for (var back = 0; back < moods.length; back++) {
    final date = today.subtract(Duration(days: back));
    await db.insertMood(date, moods[back]);
    await db.insertControlGauge(date, 5 - (back % 4));
    await db.insertStressor(date, areas[back], detail: detail[back]);
    await db.insertReflection(
      who: 'Who did I lean on today?',
      what: 'What took the most out of me?',
      when: 'When did I feel steadiest?',
      where: 'Where did the stress start?',
      why: 'Why did this matter to me?',
      date: date,
    );
  }
}
