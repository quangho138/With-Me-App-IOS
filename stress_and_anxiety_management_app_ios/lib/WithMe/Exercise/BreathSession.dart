import 'package:flutter/foundation.dart';

/// One elapsed-time clock drives phase labels, motion, and session progress.
/// Pausing preserves the exact position, including fractional seconds.
class BreathSession extends ChangeNotifier {
  BreathSession({required this.durations, required this.cycles})
    : assert(cycles > 0),
      assert(durations.isNotEmpty);
  final List<int> durations;
  final int cycles;
  Duration elapsed = Duration.zero;
  bool running = false;
  int get roundSeconds => durations.fold(0, (a, b) => a + b);
  int get totalSeconds => roundSeconds * cycles;
  bool get complete => elapsed.inMicroseconds >= totalSeconds * 1000000;
  bool get started => elapsed > Duration.zero || running;
  double get progress =>
      (elapsed.inMicroseconds / (totalSeconds * 1000000)).clamp(0, 1);
  int get round => complete ? cycles : elapsed.inSeconds ~/ roundSeconds + 1;
  double get _within =>
      complete ? 0 : elapsed.inMicroseconds / 1000000 % roundSeconds;
  int get phaseIndex {
    var time = _within;
    for (var i = 0; i < durations.length; i++) {
      if (time < durations[i]) return i;
      time -= durations[i];
    }
    return 0;
  }

  double get phaseProgress {
    final before = durations.take(phaseIndex).fold(0, (a, b) => a + b);
    return ((_within - before) / durations[phaseIndex]).clamp(0, 1);
  }

  int get remaining => (durations[phaseIndex] * (1 - phaseProgress)).ceil();
  int get secondsLeft => (totalSeconds - elapsed.inMicroseconds / 1000000)
      .ceil()
      .clamp(0, totalSeconds);
  void advance(Duration delta) {
    if (!running || complete) return;
    elapsed += delta;
    if (complete) {
      elapsed = Duration(seconds: totalSeconds);
      running = false;
    }
    notifyListeners();
  }

  void play() {
    if (!complete) {
      running = true;
      notifyListeners();
    }
  }

  void pause() {
    running = false;
    notifyListeners();
  }

  void reset() {
    elapsed = Duration.zero;
    running = false;
    notifyListeners();
  }
}
