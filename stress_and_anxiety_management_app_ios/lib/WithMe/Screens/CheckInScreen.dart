import 'package:flutter/material.dart';

import '../Components/WithMeBackdrop.dart';
import '../Components/WithMeControls.dart';
import '../Data/CheckInSteps.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'ActionPlanScreen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _controller = PageController();
  final _answers = CheckInAnswers();
  int _index = 0;
  MascotExpression _backgroundExpression = kCheckInSteps.first.expression;

  CheckInStep get _step => kCheckInSteps[_index];
  bool get _canContinue => _answers.isAnswered(_step);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == kCheckInSteps.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ActionPlanScreen(answers: _answers)),
      );
      return;
    }
    _controller.nextPage(
      duration: WithMeMotion.medium,
      curve: WithMeMotion.ease,
    );
  }

  void _back() {
    if (_index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _controller.previousPage(
      duration: WithMeMotion.medium,
      curve: WithMeMotion.ease,
    );
  }

  MascotExpression _expressionForScale(CheckInStep step, int value) {
    switch (step.id) {
      case 'stress_level':
        if (value >= 4) return MascotExpression.sad;
        if (value == 3) return MascotExpression.thinking;
        return MascotExpression.happy;
      case 'motivation':
        if (value >= 4) return MascotExpression.encouraging;
        if (value == 3) return MascotExpression.listening;
        return MascotExpression.sad;
      default:
        return step.expression;
    }
  }

  MascotExpression _expressionForOption(CheckInStep step, String label) {
    final l = label.toLowerCase();

    const sadWords = {
      'anxious',
      'overwhelmed',
      'frustrated',
      'sad',
      'angry',
      'tension',
      'headaches',
      'sleep',
      'low energy',
      'stomach',
      'negative',
      'self-doubt',
      'withdrawing',
      'overeating',
      'overworking',
    };
    const thinkingWords = {
      'work',
      'school',
      'social',
      'home',
      'racing',
      "can't focus",
      'worrying',
      'procrastinating',
      'avoiding',
      'other',
    };
    const positiveWords = {
      'feel calmer',
      'be more in control',
      'improve my focus',
      'be kinder to myself',
      'take small steps',
    };

    if (sadWords.any(l.contains)) return MascotExpression.sad;
    if (thinkingWords.any(l.contains)) return MascotExpression.thinking;
    if (positiveWords.any(l.contains)) return MascotExpression.encouraging;

    switch (step.id) {
      case 'emotion':
        return MascotExpression.sad;
      case 'mind':
      case 'life_area':
        return MascotExpression.thinking;
      case 'intention':
        return MascotExpression.encouraging;
      default:
        return step.expression;
    }
  }

  MascotExpression _expressionForCurrentAnswer(CheckInStep step) {
    if (!_answers.isAnswered(step)) return step.expression;

    if (step.kind == StepKind.scale) {
      return _expressionForScale(step, _answers.scale(step.id)!);
    }

    final picked = _answers.selected(step.id);
    if (picked.isEmpty) return step.expression;
    return _expressionForOption(step, picked.last);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          dimmed: true,
          expression: _backgroundExpression,
          child: SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kCheckInSteps.length,
                    onPageChanged: (i) => setState(() {
                      _index = i;
                      _backgroundExpression = _expressionForCurrentAnswer(kCheckInSteps[i]);
                    }),
                    itemBuilder: (context, i) => _StepView(
                      step: kCheckInSteps[i],
                      answers: _answers,
                      onChanged: () => setState(() {}),
                      onScaleSelected: (value) => setState(() {
                        _backgroundExpression = _expressionForScale(kCheckInSteps[i], value);
                      }),
                      onOptionSelected: (option) => setState(() {
                        _backgroundExpression = option == null
                            ? kCheckInSteps[i].expression
                            : _expressionForOption(kCheckInSteps[i], option.label);
                      }),
                    ),
                  ),
                ),
                _footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WithMeSpace.md,
        WithMeSpace.sm,
        WithMeSpace.md,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: WithMeSpace.sm,
          vertical: WithMeSpace.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded),
              color: WithMeColors.tealDeep,
              tooltip: 'Back',
            ),
            Expanded(
              child: Column(
                children: [
                  StepDots(count: kCheckInSteps.length, index: _index),
                  const SizedBox(height: 6),
                  Text(
                    'WITH ME CHECK-IN',
                    style: WithMeText.sectionLabel.copyWith(
                      color: WithMeColors.tealDeep,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WithMeSpace.md,
        WithMeSpace.sm,
        WithMeSpace.md,
        WithMeSpace.lg,
      ),
      child: Container(
        padding: const EdgeInsets.all(WithMeSpace.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.66),
          borderRadius: BorderRadius.circular(WithMeSpace.radiusLg),
          boxShadow: WithMeSpace.cardShadow,
          border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WithMeAvatarBadge(
              size: 54,
              expression: _canContinue
                  ? (_backgroundExpression == MascotExpression.sad
                      ? MascotExpression.listening
                      : MascotExpression.encouraging)
                  : _backgroundExpression,
            ),
            const SizedBox(width: WithMeSpace.md),
            Expanded(
              child: WithMeButton(
                label: _index == kCheckInSteps.length - 1
                    ? 'See my plan'
                    : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: _canContinue ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({
    required this.step,
    required this.answers,
    required this.onChanged,
    required this.onScaleSelected,
    required this.onOptionSelected,
  });

  final CheckInStep step;
  final CheckInAnswers answers;
  final VoidCallback onChanged;
  final ValueChanged<int> onScaleSelected;
  final ValueChanged<StepOption?> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.md,
        vertical: WithMeSpace.md,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          WithMeSpace.lg,
          WithMeSpace.lg,
          WithMeSpace.lg,
          WithMeSpace.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(WithMeSpace.radiusXl),
          boxShadow: WithMeSpace.cardShadow,
          border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              step.section,
              style: WithMeText.sectionLabel,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WithMeSpace.sm),
            Container(
              constraints: const BoxConstraints(minHeight: 92),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: WithMeSpace.lg,
                vertical: WithMeSpace.lg,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
                boxShadow: WithMeSpace.cardShadow,
              ),
              child: Text(
                step.question,
                style: WithMeText.question,
                textAlign: TextAlign.center,
              ),
            ),
            if (step.helper != null) ...[
              const SizedBox(height: WithMeSpace.sm),
              Text(
                step.helper!,
                style: WithMeText.caption,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: WithMeSpace.xl),
            _answerArea(),
          ],
        ),
      ),
    );
  }

  Widget _answerArea() {
    switch (step.kind) {
      case StepKind.scale:
        return ScaleSelector(
          value: answers.scale(step.id),
          lowLabel: step.lowLabel,
          highLabel: step.highLabel,
          onChanged: (v) {
            answers.setScale(step.id, v);
            onScaleSelected(v);
            onChanged();
          },
        );
      case StepKind.grid:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: WithMeSpace.md,
          crossAxisSpacing: WithMeSpace.md,
          childAspectRatio: 1.18,
          children: [
            for (final o in step.options)
              OptionGridCard(
                icon: o.icon,
                label: o.label,
                tint: o.tint ?? WithMeColors.teal,
                selected: answers.selected(step.id).contains(o.label),
                onTap: () {
                  answers.toggle(step.id, o.label, multiSelect: step.multiSelect);
                  final selected = answers.selected(step.id);
                  StepOption? active;
                  if (selected.isNotEmpty) {
                    active = step.options.firstWhere(
                      (item) => selected.contains(item.label),
                    );
                  }
                  onOptionSelected(active);
                  onChanged();
                },
              ),
          ],
        );
      case StepKind.list:
        return Column(children: _tiles());
      case StepKind.gauge:
        final stress = answers.scale('stress_level') ?? 3;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: WithMeSpace.sm),
              child: IntentionGauge(value: (5 - stress) / 4),
            ),
            const SizedBox(height: WithMeSpace.lg),
            ..._tiles(),
          ],
        );
    }
  }

  List<Widget> _tiles() => [
        for (final o in step.options)
          OptionTile(
            icon: o.icon,
            label: o.label,
            tint: o.tint,
            selected: answers.selected(step.id).contains(o.label),
            onTap: () {
              answers.toggle(step.id, o.label, multiSelect: step.multiSelect);
              final selected = answers.selected(step.id);
              StepOption? active;
              if (selected.isNotEmpty) {
                active = step.options.firstWhere(
                  (item) => selected.contains(item.label),
                );
              }
              onOptionSelected(active);
              onChanged();
            },
          ),
      ];
}
