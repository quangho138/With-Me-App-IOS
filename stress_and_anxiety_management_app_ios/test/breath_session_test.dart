import 'package:flutter_test/flutter_test.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Exercise/BreathSession.dart';

void main() {
  test('4-7-8 transitions and fractional resume preserve time', () {
    final s = BreathSession(durations: [4, 7, 8], cycles: 2);
    s.play();
    s.advance(const Duration(milliseconds: 2500));
    s.pause();
    s.advance(const Duration(seconds: 20));
    expect(s.remaining, 2);
    expect(s.phaseProgress, .625);
    s.play();
    s.advance(const Duration(milliseconds: 1500));
    expect(s.phaseIndex, 1);
    expect(s.remaining, 7);
    s.advance(const Duration(seconds: 7));
    expect(s.phaseIndex, 2);
    s.advance(const Duration(seconds: 8));
    expect(s.round, 2);
    expect(s.phaseIndex, 0);
    s.advance(const Duration(seconds: 30));
    expect(s.complete, true);
    expect(s.running, false);
    expect(s.progress, 1);
    s.reset();
    expect(s.started, false);
    expect(s.remaining, 4);
  });
  test('box includes empty hold and finishes selected cycles', () {
    final s = BreathSession(durations: [4, 4, 4, 4], cycles: 1)..play();
    s.advance(const Duration(seconds: 12));
    expect(s.phaseIndex, 3);
    expect(s.remaining, 4);
    s.advance(const Duration(seconds: 4));
    expect(s.complete, true);
    expect(s.secondsLeft, 0);
  });
}
