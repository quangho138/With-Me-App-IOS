import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The check-in, as data.
///
/// The V1 design walks 18 screens (`image7.png` through `image24.png`). The
/// wording below is transcribed from those mockups verbatim — including the
/// reassurance lines, which are part of the design's voice, not filler.

/// One answer option with its category colour.
class StepOption {
  const StepOption(this.label, this.color);

  final String label;
  final Color color;
}

/// The four dimensions the framework explores, in the order `image15.png`
/// lists them.
enum SignDimension { body, feelings, mind, behaviour }

extension SignDimensionInfo on SignDimension {
  String get label => switch (this) {
        SignDimension.body => 'BODY',
        SignDimension.feelings => 'FEELINGS',
        SignDimension.mind => 'MIND',
        SignDimension.behaviour => 'BEHAVIOR',
      };

  Color get color => switch (this) {
        SignDimension.body => WithMeColors.mint,
        SignDimension.feelings => WithMeColors.pink,
        SignDimension.mind => WithMeColors.peach,
        SignDimension.behaviour => WithMeColors.coral,
      };

  String get question => switch (this) {
        SignDimension.body => 'How is stress showing up in your body?',
        SignDimension.feelings => 'What emotions are you feeling most right now?',
        SignDimension.mind => 'What thoughts are coming up for you?',
        SignDimension.behaviour => 'How is it affecting your behavior?',
      };

  List<StepOption> get options => switch (this) {
        SignDimension.body => kBodySigns,
        SignDimension.feelings => kFeelingSigns,
        SignDimension.mind => kMindSigns,
        SignDimension.behaviour => kBehaviourSigns,
      };
}

/// The rotation of dot colours the design uses down an option list
/// (`image16`-`image19`): peach, coral, pink, mint, teal, then grey for
/// "Other".
const List<Color> _dots = [
  WithMeColors.peach,
  WithMeColors.coral,
  WithMeColors.pink,
  WithMeColors.mint,
  WithMeColors.teal,
  WithMeColors.slate,
];

List<StepOption> _list(List<String> labels) => [
      for (var i = 0; i < labels.length; i++)
        StepOption(labels[i], _dots[i % _dots.length]),
    ];

// --- image16 - image19 ------------------------------------------------------

final List<StepOption> kBodySigns = _list([
  'Tension',
  'Headaches',
  'Sleep issues',
  'Low energy',
  'Stomach issues',
  'Other',
]);

final List<StepOption> kFeelingSigns = _list([
  'Anxious',
  'Overwhelmed',
  'Frustrated',
  'Sad',
  'Angry',
  'Other',
]);

final List<StepOption> kMindSigns = _list([
  'Racing thoughts',
  "Can't focus",
  'Negative thoughts',
  'Worrying',
  'Self-doubt',
  'Other',
]);

final List<StepOption> kBehaviourSigns = _list([
  'Avoiding tasks',
  'Procrastinating',
  'Overeating',
  'Withdrawing',
  'Overworking',
  'Other',
]);

// --- image10 ----------------------------------------------------------------

/// Where the stress is coming from. The design lays these out two-up with
/// "Something else" as a full-width row underneath.
const List<StepOption> kStressAreas = [
  StepOption('Home', WithMeColors.mint),
  StepOption('Work', WithMeColors.peach),
  StepOption('School', WithMeColors.pink),
  StepOption('Social', WithMeColors.coral),
];

// --- image11 - image14 ------------------------------------------------------

/// The per-area stressor sets, three-up. Keyed by the area labels above.
final Map<String, List<StepOption>> kStressorsByArea = {
  'Work': _list([
    'Colleagues',
    'Boss',
    'Employees',
    'Workload',
    'Time mgmt',
    'Environment',
  ]),
  'Home': _list([
    'Partner',
    'Family',
    'In-laws',
    'Financial',
    'Domestic duties',
    'Sickness',
  ]),
  'School': _list([
    'Homework',
    'Exam pressure',
    'Organization',
    'Bullying',
    'Performance',
    'Financial',
  ]),
  'Social': _list([
    'Social media',
    'Traffic',
    'Isolation',
    'Friends',
    'Disputes',
    'Sports performance',
  ]),
};

// --- image20 ----------------------------------------------------------------

final List<StepOption> kIntentions = _list([
  'Feel calmer',
  'Be more in control',
  'Improve my focus',
  'Be kinder to myself',
  'Take small steps',
]);

// --- image21 ----------------------------------------------------------------

const List<String> kStrategies = [
  'Mental',
  'Physical',
  'Emotional',
  'Creative',
  'Social',
];

/// Actions offered per strategy. "Thought challenging" under Mental is the
/// one the mockup shows selected.
const Map<String, List<String>> kActionsByStrategy = {
  'Mental': ['Thought challenging', 'Reframing', 'Problem solving'],
  'Physical': ['Deep breathing', 'Walking', 'Stretching'],
  'Emotional': ['Journaling', 'Self-compassion', 'Naming the feeling'],
  'Creative': ['Creative writing', 'Drawing', 'Music'],
  'Social': ['Ask for help', 'Reach out', 'Share how I feel'],
};

// --- image24 ----------------------------------------------------------------

/// The five reflection prompts. These map onto the `reflections` table's
/// who / what / where / when / why columns, which must keep working.
const Map<String, List<String>> kReflectionPrompts = {
  'Who?': [
    'Who did I lean on today?',
    'Who made today harder?',
    'Who do I want to talk to?',
  ],
  'What?': [
    'What took the most out of me?',
    'What went better than expected?',
    'What would I do differently?',
  ],
  'Where?': [
    'Where did I feel most at ease?',
    'Where did the stress start?',
    'Where do I want to be tomorrow?',
  ],
  'When?': [
    'When did I feel steadiest?',
    'When did it get hard?',
    'When can I take a break?',
  ],
  'Why?': [
    'Why did this matter to me?',
    'Why did I react that way?',
    'Why is this worth carrying?',
  ],
};

// --- image25, image26 -------------------------------------------------------

/// Immediate exercises (`image25.png`).
const List<(String, String, Color)> kExercises = [
  ('Breathing Exercise', '2 min · suggested for you', WithMeColors.peach),
  ('Breathing, Focus Exercise', '3 min', WithMeColors.mint),
  ('Sleeping Relaxation exercise', '5 min', WithMeColors.pink),
  ('Other exercises', '', WithMeColors.slate),
];

/// The longer guided set (`image26.png`).
const List<(String, String, Color)> kRestExercises = [
  ('Destress your day', '5 min · unwind after work', WithMeColors.coral),
  ('Ease your sleep', '8 min · 4-7-8 breathing', WithMeColors.mint),
  ('Strengthen your focus', '4 min · 4-4-4-4 focus', WithMeColors.peach),
];

/// Everything the user picked during one check-in.
///
/// Persisted through the existing `DatabaseHelper` — mood, control gauge,
/// stressor and reflection all already have tables.
class CheckInAnswers {
  int? mood;
  int? stress;
  int? motivation;
  String? area;
  final Set<String> stressors = {};
  final Map<SignDimension, Set<String>> signs = {
    for (final d in SignDimension.values) d: <String>{},
  };

  /// Which of body, feelings, mind or behaviour the user chose to look at.
  /// Only that one dimension's page follows.
  SignDimension? signDimension;

  /// 0 (not ready) to 1 (very ready) on the intention-to-change dial.
  double? readiness;

  /// The dial's reading in words - "Somewhat ready".
  String? intention;
  String? strategy;
  String? action;
  int rating = 0;
  final Map<String, String?> reflection = {
    for (final key in kReflectionPrompts.keys) key: null,
  };

  bool get isEmpty => mood == null && stress == null && motivation == null;
}
