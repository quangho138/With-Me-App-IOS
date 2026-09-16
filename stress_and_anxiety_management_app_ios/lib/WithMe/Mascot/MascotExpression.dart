/// The emotional states the With Me companion can hold.
///
/// The main set maps to the companion moods the UI uses while the user checks
/// in. [sad] is used for heavier emotions selected in the form, while
/// [concerned] stays available for gentle concern and future safety moments.
enum MascotExpression {
  /// Resting. Soft smile, slow breathing, occasional blink.
  idle,

  /// Warm and pleased. Wider smile, stronger blush.
  happy,

  /// Attentive. Head tilts toward the user, eyes wide, mouth relaxed.
  listening,

  /// Working something out. Eyes glance up, thought dots drift overhead.
  thinking,

  /// A gentler downcast mood for sad / low-energy selections.
  sad,

  /// Cheering the user on. Wink, raised arm waving.
  encouraging,

  /// Marking a win. Both arms up, happy-arc eyes, sparkles, a small hop.
  celebrating,

  /// Gentle concern. Used by the safety layer — never playful.
  concerned,
}

extension MascotExpressionInfo on MascotExpression {
  /// Human label, matching the concept board's caption strip.
  String get label => switch (this) {
        MascotExpression.idle => 'Here with you',
        MascotExpression.happy => 'Happy',
        MascotExpression.listening => 'Listening',
        MascotExpression.thinking => 'Thinking',
        MascotExpression.sad => 'Sad',
        MascotExpression.encouraging => 'Encouraging',
        MascotExpression.celebrating => 'Celebrating',
        MascotExpression.concerned => 'Concerned',
      };

  /// Whether this state animates an arm gesture.
  bool get gestures =>
      this == MascotExpression.encouraging ||
      this == MascotExpression.celebrating;
}
