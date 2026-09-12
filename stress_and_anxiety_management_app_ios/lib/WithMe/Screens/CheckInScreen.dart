import 'package:flutter/material.dart';

import '../Components/WithMeBackdrop.dart';
import '../Components/WithMeControls.dart';
import '../Data/CheckInSteps.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'ActionPlanScreen.dart';

/// Storyboard 3–10 — the guided check-in.
///
/// Every step shares one layout: question at the top, answers in the middle,
/// the companion watching from the bottom, and a Continue button. Only the
/// answer area changes, driven by [kCheckInSteps].
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _controller = PageController();
  final _answers = CheckInAnswers();
  int _index = 0;

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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    // Answers gate progress, so swiping ahead is disabled.
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kCheckInSteps.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _StepView(
                      step: kCheckInSteps[i],
                      answers: _answers,
                      onChanged: () => setState(() {}),
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
        WithMeSpace.sm,
        WithMeSpace.sm,
        WithMeSpace.sm,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back_rounded),
            color: WithMeColors.teal,
            tooltip: 'Back',
          ),
          Expanded(
            child: StepDots(count: kCheckInSteps.length, index: _index),
          ),
          // Balances the back button so the dots stay centred.
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WithMeSpace.xl,
        WithMeSpace.sm,
        WithMeSpace.xl,
        WithMeSpace.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // The companion stays on screen for the whole flow, reacting to
          // each question — this is what makes it feel accompanied.
          WithMeAvatar(
            size: 88,
            expression: _canContinue
                ? MascotExpression.encouraging
                : _step.expression,
          ),
          const SizedBox(width: WithMeSpace.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: WithMeSpace.lg),
              child: WithMeButton(
                label: _index == kCheckInSteps.length - 1
                    ? 'See my plan'
                    : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: _canContinue ? _next : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a single step's question and answer controls.
class _StepView extends StatelessWidget {
  const _StepView({
    required this.step,
    required this.answers,
    required this.onChanged,
  });

  final CheckInStep step;
  final CheckInAnswers answers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: WithMeSpace.xl,
        vertical: WithMeSpace.md,
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
            padding: const EdgeInsets.symmetric(
              horizontal: WithMeSpace.lg,
              vertical: WithMeSpace.lg,
            ),
            decoration: BoxDecoration(
              color: WithMeColors.creamLight.withValues(alpha: 0.92),
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
          childAspectRatio: 1.35,
          children: [
            for (final o in step.options)
              OptionGridCard(
                icon: o.icon,
                label: o.label,
                tint: o.tint ?? WithMeColors.teal,
                selected: answers.selected(step.id).contains(o.label),
                onTap: () {
                  answers.toggle(step.id, o.label,
                      multiSelect: step.multiSelect);
                  onChanged();
                },
              ),
          ],
        );

      case StepKind.list:
        return Column(children: _tiles());

      case StepKind.gauge:
        // The needle reflects how in control the user said they feel, which is
        // the inverse of the stress rating they gave at the start.
        final stress = answers.scale('stress_level') ?? 3;
        return Column(
          children: [
            IntentionGauge(value: (5 - stress) / 4),
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
              onChanged();
            },
          ),
      ];
}
