import 'package:flutter/material.dart';

import '../../Database/LocalDatabase.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Data/CheckInSteps.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'YourDayScreen.dart';

/// The guided check-in — `image7.png` through `image24.png`.
///
/// Fourteen pages: mood, stress, motivation, where the stress is coming from,
/// which stressors, the signs intro, then one page per dimension (body,
/// feelings, mind, behaviour), the intention gauge, strategies, the strategy
/// detail, and the five-part self-reflection.
///
/// Answers land in the existing tables on the way out — `insertMood`,
/// `insertControlGauge`, `insertStressor` and `insertReflection`. The date
/// format those queries rely on (`YYYY-MM-DD`) is handled inside
/// `DatabaseHelper`.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  static const String route = '/check-in';

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _answers = CheckInAnswers();
  final _db = DatabaseHelper();
  final _customStressor = TextEditingController();

  int _index = 0;

  /// Which way the last move went, so the transition slides with it.
  bool _forward = true;

  String? _name;

  static const int _pageCount = 14;

  @override
  void initState() {
    super.initState();
    _db
        .getUserName()
        .then((n) {
          if (mounted) setState(() => _name = n);
        })
        .catchError((_) {});
  }

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
    if (_index == 0) {
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
      await _db.insertStressor(
        today,
        _answers.area!,
        detail: _answers.stressors.isEmpty
            ? null
            : _answers.stressors.join(', '),
      );
    }
    if (_answers.reflection.values.any((v) => v != null)) {
      await _db.insertReflection(
        who: _answers.reflection['Who?'] ?? '',
        what: _answers.reflection['What?'] ?? '',
        when: _answers.reflection['When?'] ?? '',
        where: _answers.reflection['Where?'] ?? '',
        why: _answers.reflection['Why?'] ?? '',
        date: today,
      );
    }
  }

  static String _moodLabel(int index) =>
      const ['Rough', 'Low', 'Okay', 'Pretty good', 'Good'][index];

  /// The design shows a segmented progress bar on the scale steps only
  /// (`image8`, `image9`), and the lockup everywhere else.
  bool get _showsProgress => _index == 1 || _index == 2;

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      lockup: !_showsProgress,
      onBack: _back,
      action: WithMeButton(label: _actionLabel, onPressed: _next),
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showsProgress) ...[
            const SizedBox(height: WithMeSpace.md),
            StepProgressBar(count: _pageCount, index: _index),
          ],
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
                child: _step(_index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The fourteen steps, in the order the document walks them.
  Widget _step(int index) => switch (index) {
        0 => _MoodStep(answers: _answers, name: _name, onChanged: _touch),
        1 => _ScaleStep(
            question:
                'On a scale of 1 to 5, how would you rate your stress today?',
            value: _answers.stress,
            lowLabel: 'Calm',
            highLabel: 'Overwhelmed',
            selectedColor: WithMeColors.coral,
            mascotSize: 120,
            onChanged: (v) => _touch(() => _answers.stress = v),
          ),
        2 => _ScaleStep(
            question:
                'How motivated do you feel to make a positive change today?',
            value: _answers.motivation,
            lowLabel: 'Not today',
            highLabel: 'Ready',
            reassurance: "Low is okay. We'll keep it small.",
            mascotSize: 110,
            onChanged: (v) => _touch(() => _answers.motivation = v),
          ),
        3 => _AreaStep(answers: _answers, onChanged: _touch),
        4 => _StressorStep(
            answers: _answers,
            custom: _customStressor,
            onChanged: _touch,
          ),
        5 => const _SignsIntroStep(),
        6 || 7 || 8 || 9 => _SignsStep(
            dimension: SignDimension.values[index - 6],
            answers: _answers,
            onChanged: _touch,
          ),
        10 => _IntentionStep(answers: _answers, onChanged: _touch),
        11 => _StrategyStep(answers: _answers, onChanged: _touch),
        12 => _StrategyDetailStep(answers: _answers, onChanged: _touch),
        _ => _ReflectionStep(answers: _answers, onChanged: _touch),
      };

  String get _actionLabel => switch (_index) {
        11 => 'Continue',
        12 => 'Save rating',
        13 => 'Finish check-in',
        _ => 'Continue',
      };

  void _touch(VoidCallback change) => setState(change);
}

// --- image7 -----------------------------------------------------------------

class _MoodStep extends StatelessWidget {
  const _MoodStep({
    required this.answers,
    required this.name,
    required this.onChanged,
  });

  final CheckInAnswers answers;
  final String? name;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    final who = name == null || name!.isEmpty ? 'there' : name!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionCard(question: 'Hello $who,\nhow are you feeling today?'),
        const SizedBox(height: WithMeSpace.md),
        WithMeCard(
          child: Column(
            children: [
              MoodSelector(
                value: answers.mood,
                onChanged: (v) => onChanged(() => answers.mood = v),
              ),
              if (answers.mood != null) ...[
                const SizedBox(height: WithMeSpace.md),
                Text(
                  _caption(answers.mood!),
                  style: WithMeText.option.copyWith(
                    fontWeight: FontWeight.w600,
                    color: WithMeColors.teal,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        const Center(
          child: WithMeAvatar(size: 120, expression: MascotExpression.listening),
        ),
        const Spacer(),
        const ReassuranceCard(text: 'No number, no score. Just how it feels.'),
      ],
    );
  }

  static String _caption(int mood) => const [
        'A rough one today',
        'A bit low today',
        'Okay today',
        'Pretty good today',
        'Good today',
      ][mood];
}

// --- image8, image9 ---------------------------------------------------------

class _ScaleStep extends StatelessWidget {
  const _ScaleStep({
    required this.question,
    required this.value,
    required this.onChanged,
    this.lowLabel,
    this.highLabel,
    this.reassurance,
    this.selectedColor,
    required this.mascotSize,
  });

  final String question;
  final int? value;
  final ValueChanged<int> onChanged;
  final String? lowLabel;
  final String? highLabel;
  final String? reassurance;
  final Color? selectedColor;

  /// Measured per mockup — 120 on image8, 110 on image9.
  final double mascotSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionCard(question: question, minHeight: 128),
        const SizedBox(height: WithMeSpace.lg),
        ScaleSelector(
          value: value,
          onChanged: onChanged,
          lowLabel: lowLabel,
          highLabel: highLabel,
          selectedColor: selectedColor,
        ),
        if (reassurance != null) ...[
          const SizedBox(height: WithMeSpace.lg),
          ReassuranceCard(text: reassurance!),
        ],
        const Spacer(),
        Center(
          child: WithMeAvatar(
            size: mascotSize,
            expression: MascotExpression.thinking,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

// --- image10 ----------------------------------------------------------------

class _AreaStep extends StatelessWidget {
  const _AreaStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    void pick(String area) => onChanged(() {
          answers.area = area;
          answers.stressors.clear();
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionCard(
          question: 'Where is most of your stress coming from right now?',
        ),
        const SizedBox(height: WithMeSpace.lg),
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: kTileGutter),
          Row(
            children: [
              for (var col = 0; col < 2; col++) ...[
                if (col > 0) const SizedBox(width: kTileGutter),
                Expanded(
                  child: Builder(builder: (_) {
                    final option = kStressAreas[row * 2 + col];
                    return OptionGridCard(
                      label: option.label,
                      tint: option.color,
                      selected: answers.area == option.label,
                      onTap: () => pick(option.label),
                    );
                  }),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: kTileGutter),
        OptionRow(
          label: 'Something else',
          selected: answers.area == 'Something else',
          onTap: () => pick('Something else'),
        ),
        const Spacer(),
        const Center(
          child: WithMeAvatar(size: 110, expression: MascotExpression.listening),
        ),
        const Spacer(),
      ],
    );
  }
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
            child: WithMeAvatar(size: 71, expression: MascotExpression.listening),
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
          child: WithMeAvatar(size: 71, expression: MascotExpression.listening),
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
  const _SignsIntroStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WithMeCard(
          child: Column(
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
        const SizedBox(height: WithMeSpace.lg),
        for (final dimension in SignDimension.values) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: kOptionRowGap),
            child: OptionRow(
              label: dimension.label,
              dot: dimension.color,
              selected: false,
              onTap: () {},
            ),
          ),
        ],
        const SizedBox(height: WithMeSpace.sm),
        Text(
          'What are the signs?',
          textAlign: TextAlign.center,
          style: WithMeText.question.copyWith(fontSize: 19),
        ),
        const Spacer(),
        const Center(
          child: WithMeAvatar(size: 66, expression: MascotExpression.thinking),
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

// --- image20 ----------------------------------------------------------------

class _IntentionStep extends StatelessWidget {
  const _IntentionStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    // The needle reads the stress rating from step 2.
    final stress = answers.stress ?? 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionCard(question: 'What is your intention today?'),
        const SizedBox(height: WithMeSpace.md),
        Center(child: IntentionGauge(value: (stress - 1) / 4)),
        const SizedBox(height: WithMeSpace.md),
        for (final option in kIntentions)
          Padding(
            padding: const EdgeInsets.only(bottom: kOptionRowGap),
            child: OptionRow(
              label: option.label,
              dot: option.color,
              selected: answers.intention == option.label,
              onTap: () => onChanged(() => answers.intention = option.label),
            ),
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
          child: WithMeAvatar(size: 78, expression: MascotExpression.encouraging),
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

// --- image24 ----------------------------------------------------------------

class _ReflectionStep extends StatelessWidget {
  const _ReflectionStep({required this.answers, required this.onChanged});

  final CheckInAnswers answers;
  final void Function(VoidCallback) onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QuestionCard(
            question: 'Take a moment for self-reflection',
            subtitle:
                'Select one question from each category that resonates with you today.',
          ),
          const SizedBox(height: WithMeSpace.lg),
          for (final entry in kReflectionPrompts.entries) ...[
            WithMeDropdown(
              label: entry.key,
              value: answers.reflection[entry.key],
              items: entry.value,
              onChanged: (v) =>
                  onChanged(() => answers.reflection[entry.key] = v),
            ),
            const SizedBox(height: WithMeSpace.md),
          ],
        ],
      ),
    );
  }
}
