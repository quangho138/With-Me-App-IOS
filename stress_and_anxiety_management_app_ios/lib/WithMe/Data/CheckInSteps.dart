import 'package:flutter/material.dart';

import '../Mascot/MascotExpression.dart';
import '../Theme/WithMeTheme.dart';

/// How a step renders its answers.
enum StepKind {
  /// A 1–5 row. Stress Level and Motivation.
  scale,

  /// A 2×2 card grid. Life area.
  grid,

  /// A vertical list of icon tiles. The four dimensions, intention, options.
  list,

  /// The semicircular gauge plus a list of intentions.
  gauge,
}

/// One selectable answer.
class StepOption {
  const StepOption(this.label, this.icon, {this.tint});

  final String label;
  final IconData icon;
  final Color? tint;
}

/// One screen of the guided check-in.
///
/// The storyboard's steps 3–12 are all the same three layouts with different
/// content, so they are described as data here and rendered by a single
/// screen. Adding or reordering a question is a one-line change, and the
/// conversation engine can later read this list to know what it has asked.
class CheckInStep {
  const CheckInStep({
    required this.id,
    required this.section,
    required this.question,
    required this.kind,
    this.options = const [],
    this.multiSelect = false,
    this.lowLabel,
    this.highLabel,
    this.expression = MascotExpression.listening,
    this.helper,
  });

  /// Stable key used when the answers are persisted.
  final String id;

  /// Small label above the question — the framework layer this belongs to.
  final String section;

  final String question;
  final StepKind kind;
  final List<StepOption> options;

  /// Whether more than one answer can be chosen.
  final bool multiSelect;

  final String? lowLabel;
  final String? highLabel;

  /// What the companion's face does while this question is on screen.
  final MascotExpression expression;

  /// Optional supporting line under the question.
  final String? helper;
}

/// The guided check-in, following the product owners' storyboard.
///
/// Opening and greeting are their own screens; this list covers steps 3–12,
/// after which the companion presents the action plan.
const List<CheckInStep> kCheckInSteps = [
  CheckInStep(
    id: 'stress_level',
    section: 'CHECK-IN',
    question: 'On a scale of 1 to 5,\nhow would you rate your stress today?',
    kind: StepKind.scale,
    lowLabel: 'Barely any',
    highLabel: 'Overwhelming',
    expression: MascotExpression.listening,
  ),
  CheckInStep(
    id: 'motivation',
    section: 'CHECK-IN',
    question: 'How motivated do you feel to make\na positive change today?',
    kind: StepKind.scale,
    lowLabel: 'Not today',
    highLabel: 'Ready to go',
    expression: MascotExpression.encouraging,
  ),
  CheckInStep(
    id: 'life_area',
    section: 'CONTEXT',
    question: 'Where is most of your stress\ncoming from right now?',
    kind: StepKind.grid,
    expression: MascotExpression.thinking,
    options: [
      StepOption('Home', Icons.home_rounded, tint: WithMeColors.leaf),
      StepOption('Work', Icons.work_rounded, tint: WithMeColors.teal),
      StepOption('School', Icons.school_rounded, tint: Color(0xFF5E86C7)),
      StepOption('Social', Icons.people_alt_rounded, tint: WithMeColors.hibiscus),
    ],
  ),
  CheckInStep(
    id: 'body',
    section: 'EXPLORE · BODY',
    question: 'How is stress showing up\nin your body?',
    kind: StepKind.list,
    multiSelect: true,
    helper: 'Choose as many as fit.',
    expression: MascotExpression.listening,
    options: [
      StepOption('Tension', Icons.self_improvement_rounded, tint: Color(0xFFD8604C)),
      StepOption('Headaches', Icons.psychology_alt_rounded, tint: Color(0xFFE0766A)),
      StepOption('Sleep issues', Icons.bedtime_rounded, tint: Color(0xFF6E8FC7)),
      StepOption('Low energy', Icons.battery_2_bar_rounded, tint: Color(0xFFE2A33F)),
      StepOption('Stomach issues', Icons.water_drop_rounded, tint: Color(0xFF5EA9A0)),
      StepOption('Other', Icons.more_horiz_rounded, tint: WithMeColors.inkSoft),
    ],
  ),
  CheckInStep(
    id: 'emotion',
    section: 'EXPLORE · EMOTION',
    question: 'What emotions are you\nfeeling most right now?',
    kind: StepKind.list,
    multiSelect: true,
    helper: 'Choose as many as fit.',
    expression: MascotExpression.concerned,
    options: [
      StepOption('Anxious', Icons.bolt_rounded, tint: Color(0xFFD8604C)),
      StepOption('Overwhelmed', Icons.waves_rounded, tint: Color(0xFFE0766A)),
      StepOption('Frustrated', Icons.whatshot_rounded, tint: Color(0xFFE2A33F)),
      StepOption('Sad', Icons.cloud_rounded, tint: Color(0xFF7E8FC0)),
      StepOption('Angry', Icons.local_fire_department_rounded, tint: Color(0xFFC64B3C)),
      StepOption('Other', Icons.more_horiz_rounded, tint: WithMeColors.inkSoft),
    ],
  ),
  CheckInStep(
    id: 'mind',
    section: 'EXPLORE · MIND',
    question: 'What thoughts are\ncoming up for you?',
    kind: StepKind.list,
    multiSelect: true,
    helper: 'Choose as many as fit.',
    expression: MascotExpression.thinking,
    options: [
      StepOption('Racing thoughts', Icons.speed_rounded, tint: Color(0xFF9B6FC0)),
      StepOption("Can't focus", Icons.blur_on_rounded, tint: Color(0xFFC66FA0)),
      StepOption('Negative thoughts', Icons.cloud_queue_rounded, tint: Color(0xFFD8604C)),
      StepOption('Worrying', Icons.help_outline_rounded, tint: Color(0xFF5EA9A0)),
      StepOption('Self-doubt', Icons.star_outline_rounded, tint: WithMeColors.lei),
      StepOption('Other', Icons.more_horiz_rounded, tint: WithMeColors.inkSoft),
    ],
  ),
  CheckInStep(
    id: 'behavior',
    section: 'EXPLORE · BEHAVIOR',
    question: 'How is it affecting\nyour behavior?',
    kind: StepKind.list,
    multiSelect: true,
    helper: 'Choose as many as fit.',
    expression: MascotExpression.listening,
    options: [
      StepOption('Avoiding tasks', Icons.exit_to_app_rounded, tint: Color(0xFF5EA9A0)),
      StepOption('Procrastinating', Icons.hourglass_bottom_rounded, tint: Color(0xFF6E8FC7)),
      StepOption('Overeating', Icons.restaurant_rounded, tint: Color(0xFFE2A33F)),
      StepOption('Withdrawing', Icons.person_off_rounded, tint: Color(0xFFC66FA0)),
      StepOption('Overworking', Icons.work_history_rounded, tint: Color(0xFFD8604C)),
      StepOption('Other', Icons.more_horiz_rounded, tint: WithMeColors.inkSoft),
    ],
  ),
  CheckInStep(
    id: 'intention',
    section: 'REFLECTION',
    question: 'What is your intention today?',
    kind: StepKind.gauge,
    expression: MascotExpression.encouraging,
    options: [
      StepOption('Feel calmer', Icons.spa_rounded, tint: WithMeColors.calm),
      StepOption('Be more in control', Icons.explore_rounded, tint: WithMeColors.teal),
      StepOption('Improve my focus', Icons.center_focus_strong_rounded, tint: Color(0xFF6E8FC7)),
      StepOption('Be kinder to myself', Icons.favorite_rounded, tint: WithMeColors.hibiscus),
      StepOption('Take small steps', Icons.directions_walk_rounded, tint: WithMeColors.leaf),
    ],
  ),
];

/// Step 11 on the storyboard — offered after the plan, not inside the flow.
const List<StepOption> kNextOptions = [
  StepOption('Food for thought', Icons.lightbulb_rounded, tint: WithMeColors.hibiscus),
  StepOption('Daily Log', Icons.edit_note_rounded, tint: Color(0xFFE0766A)),
  StepOption('Self-Reflection', Icons.menu_book_rounded, tint: Color(0xFF9B6FC0)),
  StepOption('Exercises', Icons.fitness_center_rounded, tint: Color(0xFF6E8FC7)),
  StepOption('Mindfulness', Icons.self_improvement_rounded, tint: WithMeColors.leaf),
  StepOption('Other Topics', Icons.more_horiz_rounded, tint: WithMeColors.inkSoft),
];

/// Step 12 on the storyboard.
const List<StepOption> kExercises = [
  StepOption('Breathing Exercise', Icons.air_rounded, tint: WithMeColors.teal),
  StepOption('Focus Exercise', Icons.center_focus_strong_rounded, tint: Color(0xFF6E8FC7)),
  StepOption('Body Relaxation', Icons.self_improvement_rounded, tint: WithMeColors.hibiscus),
  StepOption('Positive Thinking', Icons.star_rounded, tint: WithMeColors.lei),
  StepOption('Let Go', Icons.waves_rounded, tint: WithMeColors.calm),
  StepOption('Other Exercises', Icons.grid_view_rounded, tint: WithMeColors.inkSoft),
];

/// Answers collected during one pass through the flow.
///
/// Pure UI state for now — persistence and the conversation engine will read
/// this same shape when they are wired up.
class CheckInAnswers {
  final Map<String, Set<String>> choices = {};
  final Map<String, int> scales = {};

  int? scale(String id) => scales[id];
  Set<String> selected(String id) => choices[id] ?? <String>{};

  void setScale(String id, int value) => scales[id] = value;

  void toggle(String id, String label, {required bool multiSelect}) {
    final current = choices.putIfAbsent(id, () => <String>{});
    if (multiSelect) {
      current.contains(label) ? current.remove(label) : current.add(label);
    } else {
      current
        ..clear()
        ..add(label);
    }
  }

  bool isAnswered(CheckInStep step) => switch (step.kind) {
        StepKind.scale => scales.containsKey(step.id),
        _ => selected(step.id).isNotEmpty,
      };

  /// The single most useful thing to name back to the user.
  String get focusArea => _first('life_area') ?? 'Everyday life';

  String get mainFeeling => _first('emotion') ?? 'Stress';

  String get goal => _first('intention') ?? 'Feel more in control';

  String? _first(String id) {
    final set = selected(id);
    return set.isEmpty ? null : set.first;
  }
}
