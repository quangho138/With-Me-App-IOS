import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stress_and_anxiety_management_app_ios/WithMe/Components/WithMeControls.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/WelcomeScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Theme/WithMeTheme.dart';

/// The previous file here was the untouched `flutter create` counter test,
/// which asserted on a counter this app has never had.
///
/// These cover the two things a design-exact rebuild can actually regress
/// without anyone noticing: the entry screen's content, and the measured
/// geometry the whole layout rests on.
void main() {
  /// Everything is measured against iPhone 14/15, so the tests render at that
  /// size rather than the 800 x 600 default.
  void useReferenceDevice(WidgetTester tester) {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('the welcome screen shows the three entry actions', (
    tester,
  ) async {
    useReferenceDevice(tester);
    await tester.pumpWidget(
      MaterialApp(theme: buildWithMeTheme(), home: const WelcomeScreen()),
    );
    await tester.pump();

    // Layered text: the wordmark is halo, outline and fill, and the V2 type
    // is drawn fill-over-outline for weight - so each label is several
    // Text widgets.
    expect(find.text('With Me'), findsWidgets);
    expect(find.text('Your AI Companion'), findsWidgets);
    expect(find.text('Here. With you.'), findsWidgets);
    expect(find.text('Sign Up'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Continue with Google'), findsWidgets);
  });

  testWidgets('the primary action keeps its measured 60 pt height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildWithMeTheme(),
        home: Scaffold(
          body: WithMeButton(label: 'Continue', onPressed: () {}),
        ),
      ),
    );

    final box = tester.getSize(
      find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(Container),
      ).first,
    );
    expect(box.height, WithMeSpace.ctaHeight);
  });

  test('the page grid matches the measured mockups', () {
    // 290 x 590 px inner screen, scaled by 390 / 290. See
    // docs/WITH_ME_SPEC_V1.md and tool/measure_mockups.py.
    expect(WithMeSpace.pageMargin, 24);
    expect(WithMeSpace.contentWidth, 390 - 2 * WithMeSpace.pageMargin);
    expect(WithMeSpace.radiusMd, 16);
    expect(WithMeSpace.ctaHeight, 60);
  });
}
