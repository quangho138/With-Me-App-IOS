import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/ScenicKit.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Data/CheckInSteps.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/RealMascot.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'SettingsScreen.dart';
import 'YourDayScreen.dart';

/// Today's guided check-in — `image7.png` through `image23.png`, opened from
/// today's date on the monthly calendar.
///
/// Ten pages: mood, stress, motivation, where the stress is coming from,
/// which stressors, a choice of body / feelings / mind / behaviour, the one
/// page for whichever was chosen, the intention-to-change dial, strategies
/// and the strategy detail.
///
/// Continue stays disabled until the page is answered; back always works. The five-part self-reflection that used to close it
/// (`image24`) is now the Check In section on its own - see `CheckInScreen`.
///
/// Answers land in the existing tables on the way out — `insertMood`,
/// `insertControlGauge` and `insertStressor`. The date format those queries
/// rely on (`YYYY-MM-DD`) is handled inside `DatabaseHelper`.
class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key, this.initialStep = 0})
      : assert(initialStep >= 0 && initialStep < pageCount);

  /// Which page to open on. The calendar lists every page, and tapping one
  /// starts there.
  final int initialStep;

  static const String route = '/daily-check-in';

  static const int pageCount = 10;

  /// The page that depends on the body / feelings / mind / behaviour choice.
  static const int signsPage = 6;

  /// Each page's heading, in order - what the calendar lists for today.
  /// Keep it in step with `_step`.
  static List<String> pageTitles(String? name) => [
        "Hi! I'm here with you. How are you feeling today?",
        'On a scale of 1 to 5, how would you rate your stress today?',
        'How motivated do you feel to make a positive change today?',
        'Where is most of your stress coming from right now?',
        "What's weighing on you?",
        'What are the signs? Body, feelings, mind or behavior',
        // One page, whichever the previous choice named.
        'How stress is showing up for you',
        'Intention to change',
        'Select strategies and actions',
        'Strategy details',
      ];

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final _answers = CheckInAnswers();
  final _db = DatabaseHelper();
  final _customStressor = TextEditingController();

  /// Where this visit began. The signs page cannot open on its own - it
  /// needs the choice before it - so asking for it starts one page earlier.
  late final int _start = widget.initialStep == DailyCheckInScreen.signsPage
      ? DailyCheckInScreen.signsPage - 1
      : widget.initialStep;

  late int _index = _start;

  /// Which way the last move went, so the transition slides with it.
  bool _forward = true;

  static const int _pageCount = DailyCheckInScreen.pageCount;

  @override
  void dispose() {
    _customStressor.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pageCount - 1) {
      _finish();
      return;
    }
    setState(() {
      _forward = true;
      _index++;
    });
  }

  void _back() {
    // Back from the page this visit started on returns to wherever it was
    // opened from - the calendar - rather than walking into pages the user
    // chose to skip.
    if (_index == _start) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _forward = false;
      _index--;
    });
  }

  Future<void> _finish() async {
    try {
      await _save();
    } catch (_) {
      // The check-in is done either way — losing the write must not trap the
      // user on the last step. sqflite has no web implementation, so the
      // browser preview always lands here.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't save this check-in on this device."),
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const YourDayScreen()),
    );
  }

  Future<void> _save() async {
    final today = DateTime.now();

    if (_answers.mood != null) {
      await _db.insertMood(today, _moodLabel(_answers.mood!));
    }
    if (_answers.stress != null) {
      // The gauge stores how in-control the day felt, so invert the stress
      // rating: 1 stress is 5 control.
      await _db.insertControlGauge(today, 6 - _answers.stress!);
    }
    if (_answers.area != null) {
      // Signs share the stressor's detail column - there is no signs table -
      // and only the chosen dimension's count; the others were never shown.
      final dimension = _answers.signDimension;
      final detail = [
        ..._answers.stressors,
        if (dimension != null) ..._answers.signs[dimension]!,
      ];
      await _db.insertStressor(
        today,
        _answers.area!,
        detail: detail.isEmpty ? null : detail.join(', '),
      );
    }
  }

  /// The four faces on the greeting, as stored.
  static String _moodLabel(int index) => MoodFace.values[index].label;

  @override
  Widget build(BuildContext context) {
    // The first four pages are the V2 reference screens 2-5, on the beach.
    if (_index < 4) return _scenic(context);

    return WithMeScaffold(
      onBack: _back,
      action: WithMeButton(
        label: _actionLabel,
        onPressed: _answered ? _next : null,
      ),
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: WithMeSpace.lg),
          // One step at a time rather than a PageView: the page shell measures
          // its content so a short device scrolls instead of overflowing, and
          // a viewport cannot be measured.
          Expanded(
            child: AnimatedSwitcher(
              duration: WithMeMotion.medium,
              switchInCurve: WithMeMotion.ease,
              switchOutCurve: WithMeMotion.ease,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(_forward ? 0.12 : -0.12, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(_index),
                child: _StepMood(expression: _reaction, child: _step(_index)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pages 4 to 9 - the first four are built by [_scenic].
  Widget _step(int index) => switch (index) {
        4 => _StressorStep(
            answers: _answers,
            custom: _customStressor,
            onChanged: _touch,
          ),
        5 => _SignsIntroStep(answers: _answers, onChanged: _touch),
        6 => _SignsStep(
            dimension: _answers.signDimension ?? SignDimension.body,
            answers: _answers,
            onChanged: _touch,
          ),
        7 => _IntentionStep(answers: _answers, onChanged: _touch),
        8 => _StrategyStep(answers: _answers, onChanged: _touch),
        _ => _StrategyDetailStep(answers: _answers, onChanged: _touch),
      };

  // ---------------------------------------------------------------------------
  // The V2 pages - reference screens 2 to 5
  // ---------------------------------------------------------------------------

  /// The rendered companion's pose for pages 0 to 3. Each page opens on the
  /// pose the reference shows, then answers move it: hard ones make it sad,
  /// middling ones get a smirk, good ones a happy hop. The reference's own
  /// example answers (stress 4, motivation 3) land on its pictured poses.
  RealPose get _realPose {
    final a = _answers;
    switch (_index) {
      case 0:
        return switch (a.mood) {
          null => RealPose.heart,
          0 => RealPose.sad,
          1 => RealPose.smirk,
          2 => RealPose.happy,
          _ => RealPose.excited,
        };
      case 1:
        return switch (a.stress) {
          null => RealPose.think,
          1 || 2 => RealPose.happy,
          3 => RealPose.smirk,
          4 => RealPose.think,
          _ => RealPose.sad,
        };
      case 2:
        return switch (a.motivation) {
          null => RealPose.idle,
          1 => RealPose.sad,
          2 => RealPose.smirk,
          _ => RealPose.excited,
        };
      default:
        return a.area == null ? RealPose.think : RealPose.sad;
    }
  }

  Widget _scenic(BuildContext context) {
    return Scaffold(
      body: ScenicBackdrop(
        scene: 'sunset',
        child: LayoutBuilder(
          builder: (context, box) {
            final h = box.maxHeight;
            final w = box.maxWidth;
            // The area grid is tall, so the companion sits smaller there,
            // as on the reference.
            final mascot = _index == 3 ? h * 0.36 : h * 0.45;

            return Stack(
              children: [
                // Sitting on the rock, behind the Continue pill.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: h * 0.07,
                  child: Center(
                    child: RealMascot(pose: _realPose, height: mascot),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            ScenicBack(onTap: _back),
                            Expanded(
                              child: Center(
                                child: _index == 0
                                    ? const SizedBox.shrink()
                                    : ScenicProgress(
                                        value: (_index + 1) / _pageCount,
                                        width: w * 0.36,
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: _index == 0 ? _settingsGear(context) : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.07),
                        child: AnimatedSwitcher(
                          duration: WithMeMotion.medium,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(_forward ? 0.08 : -0.08, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ),
                          child: KeyedSubtree(
                            key: ValueKey(_index),
                            child: _scenicContent(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                        child: ScenicPill(
                          label: 'Continue',
                          height: 60,
                          onPressed: _answered ? _next : null,
                        ),
                      ),
                      SizedBox(height: h * 0.025),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _settingsGear(BuildContext context) => Semantics(
        button: true,
        label: 'Settings',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: Colors.white,
            size: 26,
            shadows: [Shadow(color: Color(0x66000000), blurRadius: 6)],
          ),
        ),
      );

  Widget _scenicContent() {
    final a = _answers;
    switch (_index) {
      case 0:
        // The faces sit at the top of the greeting, above what the
        // companion says.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MoodFacesCard(
              value: a.mood == null ? null : MoodFace.values[a.mood!],
              onChanged: (f) => _touch(() => a.mood = f.index),
            ),
            const SizedBox(height: 16),
            const SpeechBubble(
              tailAt: 0.6,
              child: BubbleText(
                "Hi!\nI'm here with you.\nHow are you\nfeeling today?",
                size: 27,
              ),
            ),
          ],
        );
      case 1:
        return SpeechBubble(
          tailAt: 0.62,
          child: Column(
            children: [
              const BubbleText(
                'On a scale of 1 to 5,\nhow would you rate\nyour stress today?',
              ),
              const SizedBox(height: 20),
              NumberChoice(
                value: a.stress,
                onChanged: (v) => _touch(() => a.stress = v),
              ),
            ],
          ),
        );
      case 2:
        return SpeechBubble(
          tailAt: 0.62,
          child: Column(
            children: [
              const BubbleText(
                'How motivated\ndo you feel to make\na positive change\ntoday?',
              ),
              const SizedBox(height: 20),
              NumberChoice(
                value: a.motivation,
                onChanged: (v) => _touch(() => a.motivation = v),
              ),
            ],
          ),
        );
      default:
        const areas = [
          ('Home', Icons.home_rounded, Color(0xFF3E9C52)),
          ('Work', Icons.work_rounded, Color(0xFF1C7C84)),
          ('School', Icons.school_rounded, Color(0xFF1C7C84)),
          ('Social', Icons.groups_rounded, Color(0xFFEA6A58)),
        ];
        Widget tile(int i) => AreaTile(
              label: areas[i].$1,
              icon: areas[i].$2,
              color: areas[i].$3,
              selected: a.area == areas[i].$1,
              onTap: () => _touch(() => a.area = areas[i].$1),
            );
        return SpeechBubble(
          tailAt: 0.62,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              const BubbleText(
                'Where is most of your\nstress coming from\nright now?',
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: tile(0)),
                const SizedBox(width: 12),
                Expanded(child: tile(1)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: tile(2)),
                const SizedBox(width: 12),
                Expanded(child: tile(3)),
              ]),
            ],
          ),
        );
    }
  }

  /// How the mascot feels about the current page's answer. Idle - alive but
  /// waiting - until something is picked; then hard answers make it sad,
  /// middling ones get a smirk, good ones a happy hop. Naming a stressor or a
  /// sign gets gentle concern rather than a frown.
  MascotExpression get _reaction {
    MascotExpression scale(int? v, {bool highIsGood = true}) {
      if (v == null || v < 1) return MascotExpression.idle;
      final good = highIsGood ? v >= 4 : v <= 2;
      final bad = highIsGood ? v <= 2 : v >= 4;
      return good
          ? MascotExpression.happy
          : bad
              ? MascotExpression.sad
              : MascotExpression.smirk;
    }

    final a = _answers;
    return switch (_index) {
      // Pages 0-3 use the rendered companion - see [_realPose].
      0 || 1 || 2 || 3 => MascotExpression.idle,
      4 => a.stressors.isEmpty
          ? MascotExpression.idle
          : MascotExpression.concerned,
      // Body, feelings, mind or behaviour is neither good nor bad news.
      5 => a.signDimension == null
          ? MascotExpression.idle
          : MascotExpression.smirk,
      6 => (a.signs[a.signDimension]?.isEmpty ?? true)
          ? MascotExpression.idle
          : MascotExpression.concerned,
      7 => scale(a.readiness == null
          ? null
          : ReadinessGauge.levelOf(a.readiness!) + 1),
      8 => a.strategy == null ? MascotExpression.idle : MascotExpression.happy,
      _ => scale(a.rating),
    };
  }

  /// Whether the current page has what it asks for. Continue waits on it.
  bool get _answered => switch (_index) {
        0 => _answers.mood != null,
        1 => _answers.stress != null,
        2 => _answers.motivation != null,
        3 => _answers.area != null,
        4 => _answers.stressors.isNotEmpty,
        5 => _answers.signDimension != null,
        6 => _answers.signs[_answers.signDimension]?.isNotEmpty ?? false,
        7 => _answers.readiness != null,
        8 => _answers.strategy != null && _answers.action != null,
        _ => _answers.rating > 0,
      };

  String get _actionLabel =>
      _index == _pageCount - 1 ? 'Finish check-in' : 'Continue';

  void _touch(VoidCallback change) => setState(change);
}

// --- image11 - image14 ------------------------------------------------------

class _StressorStep extends StatelessWidget {
  const _StressorStep({
    required this.answers,
    required this.custom,
    required this.onChanged,
  });

  final CheckInAnswers answers;
  final TextEditingController custom;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    final area = answers.area;
    final options = kStressorsByArea[area];

    if (options == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QuestionCard(question: "What's weighing on you?"),
          const SizedBox(height: WithMeSpace.lg),
          WithMeField(controller: custom, hint: 'Add a custom stressor...'),
          const Spacer(),
          const Center(
            child: _StepMascot(size: 71),
          ),
          const Spacer(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionCard(
          question: 'Which stressors affect you ${_phrase(area!)}?',
        ),
        const SizedBox(height: WithMeSpace.lg),
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: kTriTileGutter),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: kTriTileGutter),
                Expanded(
                  child: Builder(builder: (_) {
                    final option = options[row * 3 + col];
                    final on = answers.stressors.contains(option.label);
                    return OptionGridCard(
                      label: option.label,
                      tint: option.color,
                      selected: on,
                      compact: true,
                      onTap: () => onChanged(() {
                        on
                            ? answers.stressors.remove(option.label)
                            : answers.stressors.add(option.label);
                      }),
                    );
                  }),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: WithMeSpace.lg),
        WithMeField(controller: custom, hint: 'Add a custom stressor...'),
        const SizedBox(height: WithMeSpace.md),
        // The design pairs "Save custom" with a second Continue here; the
        // bottom-pinned action already continues, so this one only saves.
        SizedBox(
          width: (WithMeSpace.contentWidth - WithMeSpace.md) / 2,
          child: WithMeButton(
            label: 'Save custom',
            filled: false,
            height: 51,
            onPressed: () => onChanged(() {
              final text = custom.text.trim();
              if (text.isEmpty) return;
              answers.stressors.add(text);
              custom.clear();
            }),
          ),
        ),
        const Spacer(),
        const Center(
          child: _StepMascot(size: 71),
        ),
        const Spacer(),
      ],
    );
  }

  static String _phrase(String area) => switch (area) {
        'Work' => 'at work',
        'Home' => 'at home',
        'School' => 'at school',
        'Social' => 'socially',
        _ => 'right now',
      };
}

// --- image15 ----------------------------------------------------------------

class _SignsIntroStep extends StatelessWidget {
  const _SignsIntroStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WithMeCard(
          // Measured 340 x 128 on image15.
          minHeight: 128,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Formula(
                lead: 'Stressor = ',
                parts: ['body reaction', ' + ', 'situation'],
              ),
              const Divider(height: WithMeSpace.lg, color: WithMeColors.slate),
              _Formula(
                lead: 'Anxiety = ',
                parts: ['anticipation', ' + ', 'event'],
                trail: ' (real or imagined)',
              ),
            ],
          ),
        ),
        // image15 draws these as left-aligned pills, one already picked -
        // measured 172 x ~50, 15 pt radius, 10 apart, 36 below the card.
        const SizedBox(height: 36),
        for (final dimension in SignDimension.values) ...[
          Align(
            alignment: Alignment.centerLeft,
            // A choice, not a list: whichever is picked decides the one
            // page that follows ("How is stress showing up in your body?").
            child: _SignChoice(
              dimension: dimension,
              selected: answers.signDimension == dimension,
              onTap: () =>
                  onChanged(() => answers.signDimension = dimension),
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: WithMeSpace.lg),
        Text(
          'What are the signs?',
          textAlign: TextAlign.center,
          style: WithMeText.question.copyWith(fontSize: 22),
        ),
        const Spacer(),
        const Center(
          child: _StepMascot(size: 66),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Formula extends StatelessWidget {
  const _Formula({required this.lead, required this.parts, this.trail});

  final String lead;
  final List<String> parts;
  final String? trail;

  @override
  Widget build(BuildContext context) {
    final bold = WithMeText.option.copyWith(
      fontWeight: FontWeight.w700,
      color: WithMeColors.teal,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: WithMeText.option,
        children: [
          TextSpan(text: lead),
          for (var i = 0; i < parts.length; i++)
            TextSpan(text: parts[i], style: i.isEven ? bold : null),
          if (trail != null) TextSpan(text: trail),
        ],
      ),
    );
  }
}

// --- image16 - image19 ------------------------------------------------------

class _SignsStep extends StatelessWidget {
  const _SignsStep({
    required this.dimension,
    required this.answers,
    required this.onChanged,
  });

  final SignDimension dimension;
  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    final chosen = answers.signs[dimension]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionCard(question: dimension.question),
        const SizedBox(height: WithMeSpace.lg),
        for (final option in dimension.options)
          Padding(
            padding: const EdgeInsets.only(bottom: kOptionRowGap),
            child: OptionRow(
              label: option.label,
              dot: option.color,
              selected: chosen.contains(option.label),
              onTap: () => onChanged(() {
                chosen.contains(option.label)
                    ? chosen.remove(option.label)
                    : chosen.add(option.label);
              }),
            ),
          ),
        const Spacer(),
      ],
    );
  }
}

// --- Intention to change ----------------------------------------------------
// The product owner's revised screen, replacing the image20 "What is your
// intention today?" list: one dial, read as how ready the user feels.

class _IntentionStep extends StatelessWidget {
  const _IntentionStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  static const List<String> _notes = [
    'Not today is an honest answer too. Noticing it is a step.',
    "A little is still a start. We'll keep it small.",
    'Somewhere in the middle is the most honest answer most days — and it '
        'is enough.',
    "Ready is a good place to be. Let's pick one small thing.",
    "Let's use that energy — one step at a time.",
  ];

  @override
  Widget build(BuildContext context) {
    final readiness = answers.readiness;
    final level =
        readiness == null ? null : ReadinessGauge.levelOf(readiness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionCard(question: 'Intention to change', minHeight: 64),
        const SizedBox(height: WithMeSpace.lg),
        Text(
          'How ready do you feel to do something differently today?',
          textAlign: TextAlign.center,
          style: WithMeText.body.copyWith(color: WithMeColors.ink),
        ),
        const SizedBox(height: WithMeSpace.md),
        Center(
          child: ReadinessGauge(
            value: readiness,
            onChanged: (v) => onChanged(() {
              answers.readiness = v;
              answers.intention =
                  ReadinessGauge.levels[ReadinessGauge.levelOf(v)];
            }),
          ),
        ),
        const SizedBox(height: WithMeSpace.sm),
        Text(
          level == null ? 'Drag the needle' : ReadinessGauge.levels[level],
          textAlign: TextAlign.center,
          style: level == null
              ? WithMeText.caption
              : WithMeText.option.copyWith(
                  fontWeight: FontWeight.w700,
                  color: WithMeColors.teal,
                ),
        ),
        const SizedBox(height: WithMeSpace.md),
        ReassuranceCard(text: _notes[level ?? 2]),
        const Spacer(),
        const Center(
          child: _StepMascot(size: 90),
        ),
        const Spacer(),
      ],
    );
  }
}

// --- image21, image22 -------------------------------------------------------

class _StrategyStep extends StatefulWidget {
  const _StrategyStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  State<_StrategyStep> createState() => _StrategyStepState();
}

class _StrategyStepState extends State<_StrategyStep> {
  final List<String> _customStrategies = [];
  final Map<String, List<String>> _customActions = {};

  List<String> get _strategies => [...kStrategies, ..._customStrategies];

  List<String> get _actions {
    final strategy = widget.answers.strategy;
    if (strategy == null) return const [];
    return [
      ...?kActionsByStrategy[strategy],
      ...?_customActions[strategy],
    ];
  }

  Future<void> _addCustom() async {
    final strategy = TextEditingController();
    final action = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x73143A38),
      builder: (context) => _CustomStrategyDialog(
        strategy: strategy,
        action: action,
      ),
    );

    if (saved == true) {
      final s = strategy.text.trim();
      final a = action.text.trim();
      if (s.isNotEmpty) {
        setState(() {
          _customStrategies.add(s);
          if (a.isNotEmpty) _customActions.putIfAbsent(s, () => []).add(a);
        });
        widget.onChanged(() {
          widget.answers.strategy = s;
          widget.answers.action = a.isEmpty ? null : a;
        });
      }
    }
    strategy.dispose();
    action.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.answers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select strategies and actions',
          textAlign: TextAlign.center,
          style: WithMeText.title,
        ),
        const SizedBox(height: WithMeSpace.lg),
        WithMeDropdown(
          label: 'Stress management strategy',
          value: answers.strategy,
          items: _strategies,
          onChanged: (v) => widget.onChanged(() {
            answers.strategy = v;
            answers.action = null;
          }),
        ),
        const SizedBox(height: WithMeSpace.lg),
        WithMeDropdown(
          label: 'Stress management action',
          value: answers.action,
          items: _actions,
          onChanged: (v) => widget.onChanged(() => answers.action = v),
        ),
        const SizedBox(height: WithMeSpace.lg),
        WithMeCard(
          child: Column(
            children: [
              Text('Pick a rate of effectiveness', style: WithMeText.option),
              const SizedBox(height: WithMeSpace.md),
              StarRating(
                value: answers.rating,
                onChanged: (v) => widget.onChanged(() => answers.rating = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: WithMeSpace.md),
        GestureDetector(
          onTap: _addCustom,
          behavior: HitTestBehavior.opaque,
          child: Text(
            '+ Add custom strategy & action',
            textAlign: TextAlign.center,
            style: WithMeText.body.copyWith(color: WithMeColors.teal),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

/// `image22.png` — the custom strategy dialog.
class _CustomStrategyDialog extends StatelessWidget {
  const _CustomStrategyDialog({required this.strategy, required this.action});

  final TextEditingController strategy;
  final TextEditingController action;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: WithMeColors.creamLight,
      insetPadding: const EdgeInsets.symmetric(horizontal: WithMeSpace.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(WithMeSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add custom strategy & action', style: WithMeText.title.copyWith(fontSize: 19)),
            const SizedBox(height: WithMeSpace.lg),
            _DialogField(controller: strategy, hint: 'Custom strategy'),
            const SizedBox(height: WithMeSpace.md),
            _DialogField(controller: action, hint: 'Custom action'),
            const SizedBox(height: WithMeSpace.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: WithMeText.option.copyWith(
                      fontWeight: FontWeight.w600,
                      color: WithMeColors.inkSoft,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Add',
                    style: WithMeText.option.copyWith(
                      fontWeight: FontWeight.w700,
                      color: WithMeColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: WithMeText.option,
      cursorColor: WithMeColors.teal,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: WithMeText.option.copyWith(color: WithMeColors.inkFaint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: WithMeSpace.lg,
          vertical: WithMeSpace.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
          borderSide: const BorderSide(color: WithMeColors.slate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
          borderSide: const BorderSide(color: WithMeColors.teal, width: 1.6),
        ),
      ),
    );
  }
}

// --- image23 ----------------------------------------------------------------

class _StrategyDetailStep extends StatelessWidget {
  const _StrategyDetailStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Strategy details', textAlign: TextAlign.center, style: WithMeText.title),
        const SizedBox(height: WithMeSpace.lg),
        WithMeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date · ${now.day} ${_month(now.month)} ${now.year}',
                style: WithMeText.body.copyWith(color: WithMeColors.ink),
              ),
              const SizedBox(height: 6),
              _Line('Strategy', answers.strategy ?? '-'),
              const SizedBox(height: 4),
              _Line('Action', answers.action ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: WithMeSpace.md),
        WithMeCard(
          child: Column(
            children: [
              Text(
                'Rate this strategy',
                style: WithMeText.option.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: WithMeSpace.md),
              StarRating(
                value: answers.rating,
                onChanged: (v) => onChanged(() => answers.rating = v),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Center(
          child: _StepMascot(size: 78),
        ),
        const Spacer(),
      ],
    );
  }

  static String _month(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: WithMeText.option.copyWith(
            fontWeight: FontWeight.w700,
            color: WithMeColors.teal,
          ),
          children: [
            TextSpan(text: '$label · '),
            TextSpan(text: value),
          ],
        ),
      );
}

/// Hands the current page's [_DailyCheckInScreenState._reaction] down to
/// whichever mascot the page draws, without threading it through every
/// step's constructor.
class _StepMood extends InheritedWidget {
  const _StepMood({required this.expression, required super.child});

  final MascotExpression expression;

  static MascotExpression of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StepMood>()?.expression ??
      MascotExpression.idle;

  @override
  bool updateShouldNotify(_StepMood old) => old.expression != expression;
}

/// The mascot on a check-in page, reacting to the answer.
class _StepMascot extends StatelessWidget {
  const _StepMascot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      WithMeAvatar(size: size, expression: _StepMood.of(context));
}

/// One of body / feelings / mind / behaviour on the signs page (`image15`).
class _SignChoice extends StatelessWidget {
  const _SignChoice({
    required this.dimension,
    required this.selected,
    required this.onTap,
  });

  final SignDimension dimension;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: dimension.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: WithMeMotion.fast,
          width: 172,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
          decoration: BoxDecoration(
            color: selected ? WithMeColors.teal : WithMeColors.cream,
            borderRadius: BorderRadius.circular(15),
            boxShadow: WithMeSpace.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: dimension.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: WithMeSpace.md),
              Text(
                dimension.label,
                style: WithMeText.option.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: selected ? Colors.white : WithMeColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
