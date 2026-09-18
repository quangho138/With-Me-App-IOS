import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'ExerciseChooseScreen.dart';

/// `image36.png` — "Your day".
///
/// The four things today asked for, each with its state on the right, then
/// the nudge toward whichever one is still open.
class YourDayScreen extends StatefulWidget {
  const YourDayScreen({super.key});

  static const String route = '/your-day';

  @override
  State<YourDayScreen> createState() => _YourDayScreenState();
}

enum _TaskState { done, now, later }

class _Task {
  _Task(this.label, this.state, this.color);

  final String label;
  _TaskState state;
  final Color color;
}

class _YourDayScreenState extends State<YourDayScreen> {
  final List<_Task> _tasks = [
    _Task('Morning check-in', _TaskState.done, WithMeColors.teal),
    _Task('Box breathing · 5 cycles', _TaskState.done, WithMeColors.teal),
    _Task('One step: rehearse the opening', _TaskState.now, WithMeColors.coral),
    _Task('Evening log', _TaskState.later, WithMeColors.slate),
  ];

  int get _done => _tasks.where((t) => t.state == _TaskState.done).length;

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: 'Your day',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Do it now',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ExerciseChooseScreen()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WithMeCard(
            padding: const EdgeInsets.symmetric(
              horizontal: WithMeSpace.lg,
              vertical: WithMeSpace.md,
            ),
            child: Column(
              children: [
                for (var i = 0; i < _tasks.length; i++) ...[
                  if (i > 0)
                    const Divider(height: WithMeSpace.lg, color: WithMeColors.slate),
                  _TaskRow(
                    task: _tasks[i],
                    onTap: () => setState(() {
                      _tasks[i].state = _tasks[i].state == _TaskState.done
                          ? _TaskState.later
                          : _TaskState.done;
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: WithMeSpace.md),
          ReassuranceCard(
            tinted: true,
            text: '$_done of ${_tasks.length} done. '
                'The step you chose this morning is still waiting — two '
                'minutes is enough.',
          ),
          const SizedBox(height: WithMeSpace.lg),
          const Center(
            child: WithMeAvatar(
              size: 140,
              expression: MascotExpression.encouraging,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onTap});

  final _Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: task.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: WithMeSpace.md),
          Expanded(child: Text(task.label, style: WithMeText.option)),
          Text(
            switch (task.state) {
              _TaskState.done => 'DONE',
              _TaskState.now => 'NOW',
              _TaskState.later => 'LATER',
            },
            style: WithMeText.sectionLabel.copyWith(
              color: task.state == _TaskState.now
                  ? WithMeColors.coral
                  : WithMeColors.inkFaint,
            ),
          ),
        ],
      ),
    );
  }
}
