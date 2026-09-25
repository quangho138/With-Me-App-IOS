import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ExerciseChooseScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/BeforeWeStartScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/BreathingScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/SighScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Theme/WithMeTheme.dart';

void main() {
  test('focus uses exactly three four-second phases', () {
    expect(BreathPattern.fourFourFour.phases.map((p) => (p.$1,p.$2)).toList(),
      [('Inhale',4),('Hold',4),('Exhale',4)]);
    expect(BreathPattern.fourFourFour.roundSeconds,12);
  });
  for (final entry in [
    ('De-stress Your Day', BreathPattern.fourSevenEight),
    ('Ease Your Sleep', BreathPattern.fourSevenEight),
    ('Strengthen Your Focus', BreathPattern.fourFourFour),
  ]) {
    testWidgets('${entry.$1} preserves its v6 content', (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: buildWithMeTheme(),
          home: const ExerciseChooseScreen(),
        ),
      );
      await t.tap(find.text(entry.$1));
      await t.pump();
      await t.tap(find.text('Continue'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(
        t.widget<BeforeWeStartScreen>(find.byType(BeforeWeStartScreen)).pattern,
        entry.$2,
      );
      if (entry.$1 == 'De-stress Your Day') {
        await t.tap(find.text('None'));
        await t.tap(find.text('Next'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        expect(find.text('4 · 7 · 8'), findsOneWidget);
        expect(find.text('4 · 4 · 4 · 4'), findsNothing);
        expect(find.text('4 · 4 · 4'), findsNothing);
      }
      await t.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'sigh plays two distinct quick inhales and completes chosen cycles',
    (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          theme: buildWithMeTheme(),
          home: const ExerciseChooseScreen(),
        ),
      );
      await t.tap(find.text('Physiological Sigh'));
      await t.pump();
      await t.tap(find.text('Continue'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byType(SighScreen), findsOneWidget);
      await t.tap(find.text('1'));
      await t.pump();
      await t.tap(find.text('Start breathing'));
      await t.pump();
      await t.pump(const Duration(seconds: 4));
      expect(find.text('Quick inhale · 1'), findsOneWidget);
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Quick inhale · 2'), findsOneWidget);
      await t.tap(find.text('Pause'));
      await t.pump();
      await t.pump(const Duration(seconds: 10));
      expect(find.text('Quick inhale · 2'), findsOneWidget);
      await t.tap(find.text('Resume'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Long exhale'), findsOneWidget);
      await t.pump(const Duration(seconds: 8));
      expect(find.text('Session complete'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
}
