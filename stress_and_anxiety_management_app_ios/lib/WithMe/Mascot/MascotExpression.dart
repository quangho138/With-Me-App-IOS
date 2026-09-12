/// The emotional states the With Me companion can hold.
///
/// The first five map one-to-one onto the expression strip on the product
/// owners' concept board (Happy / Listening / Thinking / Encouraging /
/// Celebrating). [idle] is the resting state between beats and [concerned]
/// is reserved for the safety layer, where a cheerful face would be wrong.
enum MascotExpression {
  /// Resting. Soft smile, slow breathing, occasional blink.
  idle,

  /// Warm and pleased. Wider smile, stronger blush.
  happy,

  /// Attentive. Head tilts toward the user, eyes wide, mouth relaxed.
  listening,

  /// Working something out. Eyes glance up, thought dots drift overhead.
  thinking,

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
        MascotExpression.encouraging => 'Encouraging',
        MascotExpression.celebrating => 'Celebrating',
        MascotExpression.concerned => 'Concerned',
      };

  /// Whether this state animates an arm gesture.
  bool get gestures =>
      this == MascotExpression.encouraging ||
      this == MascotExpression.celebrating;
}
