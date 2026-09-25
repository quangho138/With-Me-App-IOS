import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/BreathingScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/BeforeWeStartScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Theme/WithMeTheme.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final weight in [400, 500, 600, 700]) {
      final loader = FontLoader('Quicksand')
        ..addFont(
          rootBundle.load(
            'assets/fonts/Quicksand-' + weight.toString() + '.ttf',
          ),
        );
      await loader.load();
    }
    await (FontLoader(
      'Yellowtail',
    )..addFont(rootBundle.load('assets/fonts/Yellowtail-Regular.ttf'))).load();
  });
  Future<void> mount(
    WidgetTester t,
    Widget child, {
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: buildWithMeTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: RepaintBoundary(key: const ValueKey('capture'), child: child),
        ),
      ),
    );
    await t.pump();
  }

  testWidgets('pause, resume, lifecycle and completion work on screen', (
    t,
  ) async {
    await mount(t, const BreathingScreen(sound: 'None', cycles: 1));
    await t.tap(find.text('Start breathing'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 2500));
    await t.tap(find.text('Pause'));
    await t.pump();
    await t.pump(const Duration(seconds: 10));
    await t.tap(find.text('Resume'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 1500));
    expect(find.text('Hold 7 seconds'), findsOneWidget);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await t.pump();
    expect(find.text('Resume'), findsOneWidget);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.tap(find.text('Resume'));
    await t.pump();
    await t.pump(const Duration(seconds: 15));
    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('Breathe again'), findsOneWidget);
    await t.tap(find.text('Breathe again'));
    await t.pump();
    expect(find.text('Inhale 4 seconds'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('sound and cycle selections reach player', (t) async {
    await mount(t, const BeforeWeStartScreen(pattern: BreathPattern.box));
    await t.tap(find.text('Birds'));
    await t.tap(find.text('2'));
    await t.tap(find.text('Next'));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    final screen = t.widget<BreathingScreen>(find.byType(BreathingScreen));
    expect(screen.sound, 'Birds');
    expect(screen.cycles, 2);
    expect(screen.pattern, BreathPattern.box);
  });
  for (final sound in ['Waves', 'Birds', 'Forest', 'Rain', 'Fire', 'None']) {
    testWidgets('renders ' + sound + ' scene', (t) async {
      await mount(t, BreathingScreen(sound: sound));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_EXERCISE')) {
        final boundary = t.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('capture')),
        );
        await t.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('test/exercise_previews').create(recursive: true);
          await File(
            'test/exercise_previews/' + sound.toLowerCase() + '.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
  testWidgets('compact screen and large text remain scrollable', (t) async {
    await mount(
      t,
      const BreathingScreen(sound: 'None', pattern: BreathPattern.box),
      size: const Size(320, 568),
      scale: 1.7,
    );
    expect(t.takeException(), isNull);
    expect(find.text('Start breathing'), findsOneWidget);
    await t.tap(find.text('Start breathing'));
    await t.pump();
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('switching patterns resets a paused session', (t) async {
    await mount(
      t,
      const BreathingScreen(sound: 'None', pattern: BreathPattern.box),
    );
    await t.tap(find.text('Start breathing'));
    await t.pump();
    await t.pump(const Duration(seconds: 5));
    await t.tap(find.text('4 · 7 · 8').first);
    await t.pump();
    expect(find.text('Start breathing'), findsOneWidget);
    expect(find.text('Inhale 4 seconds'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('motion toggle preserves timing and readable cues', (t) async {
    await mount(t, const BreathingScreen(sound: 'None', cycles: 1));
    await t.ensureVisible(find.text('Motion on'));
    await t.tap(find.text('Motion on'));
    await t.pump();
    await t.tap(find.text('Start breathing'));
    await t.pump();
    await t.pump(const Duration(seconds: 4));
    expect(find.text('Hold 7 seconds'), findsOneWidget);
    expect(find.text('Motion off'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
