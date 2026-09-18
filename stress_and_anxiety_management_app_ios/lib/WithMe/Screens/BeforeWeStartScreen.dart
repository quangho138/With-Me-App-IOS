import 'package:flutter/material.dart';

import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'BreathingScreen.dart';

/// `image30.png` — "Before we start".
///
/// A three-up sound picker and a five-up cycle picker, with the running total
/// underneath.
class BeforeWeStartScreen extends StatefulWidget {
  const BeforeWeStartScreen({
    super.key,
    this.pattern = BreathPattern.fourSevenEight,
  });

  static const String route = '/before-we-start';

  final BreathPattern pattern;

  @override
  State<BeforeWeStartScreen> createState() => _BeforeWeStartScreenState();
}

class _BeforeWeStartScreenState extends State<BeforeWeStartScreen> {
  static const List<String> _sounds = [
    'Waves', 'Birds', 'Fire', 'Forest', 'Rain', 'None',
  ];
  static const List<int> _cycleChoices = [1, 2, 3, 5, 10];

  String _sound = 'Waves';
  int _cycles = 5;

  @override
  Widget build(BuildContext context) {
    final seconds = _cycles * widget.pattern.roundSeconds;

    return WithMeScaffold(
      title: 'Before we start',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Next',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BreathingScreen(
              pattern: widget.pattern,
              cycles: _cycles,
              sound: _sound,
            ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sound choice', style: WithMeText.fieldLabel),
          const SizedBox(height: WithMeSpace.sm),
          for (var row = 0; row < 2; row++) ...[
            if (row > 0) const SizedBox(height: WithMeSpace.md),
            Row(
              children: [
                for (var col = 0; col < 3; col++) ...[
                  if (col > 0) const SizedBox(width: WithMeSpace.md),
                  Expanded(
                    child: _Pill(
                      label: _sounds[row * 3 + col],
                      selected: _sound == _sounds[row * 3 + col],
                      onTap: () =>
                          setState(() => _sound = _sounds[row * 3 + col]),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: WithMeSpace.xl),
          Text('Number of cycles', style: WithMeText.fieldLabel),
          const SizedBox(height: WithMeSpace.sm),
          Row(
            children: [
              for (var i = 0; i < _cycleChoices.length; i++) ...[
                if (i > 0) const SizedBox(width: WithMeSpace.sm),
                Expanded(
                  child: _Pill(
                    label: '${_cycleChoices[i]}',
                    selected: _cycles == _cycleChoices[i],
                    onTap: () => setState(() => _cycles = _cycleChoices[i]),
                    circular: true,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: WithMeSpace.md),
          Text(
            '$_cycles cycles ≈ $seconds seconds',
            style: WithMeText.caption,
          ),
          const SizedBox(height: WithMeSpace.xl),
          const Center(
            child: WithMeAvatar(size: 140, expression: MascotExpression.happy),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.circular = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WithMeMotion.fast,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? WithMeColors.teal : WithMeColors.cream,
          borderRadius: BorderRadius.circular(
            circular ? 24 : WithMeSpace.radiusPill,
          ),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Text(
          label,
          style: WithMeText.option.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : WithMeColors.ink,
          ),
        ),
      ),
    );
  }
}
