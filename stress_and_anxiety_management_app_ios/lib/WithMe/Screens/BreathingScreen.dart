import 'dart:async';

import 'package:flutter/material.dart';

import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Theme/WithMeTheme.dart';

/// The two patterns the design names.
enum BreathPattern { fourSevenEight, box }

extension BreathPatternInfo on BreathPattern {
  String get tab => switch (this) {
        BreathPattern.fourSevenEight => '4 · 7 · 8',
        BreathPattern.box => '4 · 4 · 4 · 4',
      };

  String get title => switch (this) {
        BreathPattern.fourSevenEight => 'Breathing Exercise',
        BreathPattern.box => 'Box Breathing',
      };

  String get accent => switch (this) {
        BreathPattern.fourSevenEight => 'Breathe with me...',
        BreathPattern.box => 'Four equal sides...',
      };

  /// Phase name, seconds, and the colour of its chip.
  List<(String, int, Color)> get phases => switch (this) {
        BreathPattern.fourSevenEight => const [
            ('Inhale', 4, WithMeColors.mint),
            ('Hold', 7, WithMeColors.peach),
            ('Exhale', 8, WithMeColors.coral),
          ],
        BreathPattern.box => const [
            ('Inhale', 4, WithMeColors.mint),
            ('Hold', 4, WithMeColors.peach),
            ('Exhale', 4, WithMeColors.coral),
            ('Still', 4, WithMeColors.pink),
          ],
      };

  int get roundSeconds =>
      phases.fold<int>(0, (total, phase) => total + phase.$2);
}

/// `image27.png` (4-7-8) and `image29.png` (box breathing).
///
/// `image28.png` in the document is the **old blue** info screen — a leftover
/// "before" shot next to `image29`. It is rebuilt here in the V1 style as the
/// instructions sheet, reachable from the info affordance.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({
    super.key,
    this.pattern = BreathPattern.fourSevenEight,
    this.cycles = 4,
    this.sound = 'Waves',
    this.showPatternTabs,
  });

  static const String route = '/breathing';

  final BreathPattern pattern;
  final int cycles;
  final String sound;

  /// The pattern switcher. `image29.png` has it; `image27.png` does not —
  /// 4-7-8 is reached from "Ease your sleep", which offers no alternative.
  /// Defaults to showing it only for box breathing, as the document does.
  final bool? showPatternTabs;

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late BreathPattern _pattern = widget.pattern;
  late AnimationController _phase;

  Timer? _ticker;
  int _phaseIndex = 0;
  int _round = 1;
  int _remaining = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _phase = AnimationController(vsync: this);
    _remaining = _pattern.phases.first.$2;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _phase.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _ticker?.cancel();
      _phase.stop();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _startPhase();
  }

  void _startPhase() {
    final phase = _pattern.phases[_phaseIndex];
    setState(() => _remaining = phase.$2);

    _phase
      ..duration = Duration(seconds: phase.$2)
      ..forward(from: 0);

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
        return;
      }
      _advance();
    });
  }

  void _advance() {
    final last = _phaseIndex == _pattern.phases.length - 1;
    if (!last) {
      setState(() => _phaseIndex++);
      _startPhase();
      return;
    }
    if (_round >= widget.cycles) {
      _ticker?.cancel();
      setState(() {
        _running = false;
        _phaseIndex = 0;
        _remaining = _pattern.phases.first.$2;
        _round = 1;
      });
      return;
    }
    setState(() {
      _round++;
      _phaseIndex = 0;
    });
    _startPhase();
  }

  void _switchPattern(int index) {
    _ticker?.cancel();
    _phase.stop();
    setState(() {
      _pattern = BreathPattern.values[index];
      _running = false;
      _phaseIndex = 0;
      _round = 1;
      _remaining = _pattern.phases.first.$2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phases = _pattern.phases;
    final phase = phases[_phaseIndex];
    final box = _pattern == BreathPattern.box;

    return WithMeScaffold(
      onBack: () => Navigator.of(context).pop(),
      scrollable: false,
      action: WithMeButton(
        label: _running ? 'Pause' : 'Start',
        onPressed: _toggle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showPatternTabs ?? widget.pattern == BreathPattern.box) ...[
            SegmentedTabs(
              labels: [for (final p in BreathPattern.values) p.tab],
              index: BreathPattern.values.indexOf(_pattern),
              onChanged: _switchPattern,
            ),
            const SizedBox(height: WithMeSpace.lg),
          ],
          Text(
            _pattern.tab,
            textAlign: TextAlign.center,
            style: WithMeText.title.copyWith(fontSize: 32),
          ),
          const SizedBox(height: WithMeSpace.xs),
          Text(
            _pattern.title,
            textAlign: TextAlign.center,
            style: WithMeText.body.copyWith(color: WithMeColors.ink),
          ),
          const SizedBox(height: WithMeSpace.sm),
          Text(
            _pattern.accent,
            textAlign: TextAlign.center,
            style: WithMeText.accent.copyWith(fontSize: 18),
          ),
          const SizedBox(height: WithMeSpace.lg),
          // image29 runs a rail above the square with a dot travelling along
          // it; image27 has no rail.
          if (box)
            AnimatedBuilder(
              animation: _phase,
              builder: (context, _) => _PhaseRail(
                value: _running ? _phase.value : 0,
              ),
            ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _phase,
                builder: (context, _) => _BreathShape(
                  square: box,
                  label: phase.$1,
                  seconds: _running ? _remaining : phase.$2,
                  showCount: box,
                  progress: _phase.value,
                  running: _running,
                ),
              ),
            ),
          ),
          const SizedBox(height: WithMeSpace.lg),
          _PhaseChips(
            phases: phases,
            // Nothing is the current phase until the exercise is running,
            // which is the state both mockups are captured in.
            active: _running ? _phaseIndex : -1,
            twoUp: box,
          ),
          if (box) ...[
            const SizedBox(height: WithMeSpace.md),
            Text(
              'Round $_round of ${widget.cycles} · '
              '${_pattern.roundSeconds} seconds a round',
              textAlign: TextAlign.center,
              style: WithMeText.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// The rail above the box-breathing square (`image29.png`) — a dark line with
/// a teal dot that travels along it through the phase.
class _PhaseRail extends StatelessWidget {
  const _PhaseRail({required this.value});

  /// 0-1 through the current phase.
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dot = 18.0;
          final travel = (constraints.maxWidth - dot) * value.clamp(0, 1);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: dot / 2),
                color: WithMeColors.tealInk,
              ),
              Padding(
                padding: EdgeInsets.only(left: travel),
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: const BoxDecoration(
                    color: WithMeColors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The circle (4-7-8) or rounded square (box) that grows and shrinks.
class _BreathShape extends StatelessWidget {
  const _BreathShape({
    required this.square,
    required this.label,
    required this.seconds,
    required this.showCount,
    required this.progress,
    required this.running,
  });

  final bool square;
  final String label;
  final int seconds;
  final bool showCount;

  /// 0-1 through the current phase.
  final double progress;

  final bool running;

  @override
  Widget build(BuildContext context) {
    // Grow on the inhale, shrink on the exhale, hold steady otherwise. At
    // rest the shape sits at full size — both mockups show it that way, and
    // starting it small made the square two thirds of its measured 205.
    final scale = !running
        ? 1.0
        : switch (label) {
            'Inhale' => 0.82 + 0.18 * progress,
            'Exhale' => 1.0 - 0.18 * progress,
            _ => 1.0,
          };

    // Measured off image27 and image29: the shape fills most of the content
    // column rather than sitting small in the middle.
    const size = 205.0;

    return SizedBox(
      width: size + 20,
      height: square ? 190 : size + 20,
      child: Center(
        child: AnimatedScale(
          scale: scale,
          duration: WithMeMotion.fast,
          child: Container(
            width: size,
            height: square ? 175 : size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // The circle in image27 fades out at its edge; the square in
              // image29 is a flat fill with a stroke.
              color: square ? WithMeColors.mint.withValues(alpha: 0.42) : null,
              gradient: square
                  ? null
                  // Solid most of the way out, then a short fade — image27's
                  // circle has a defined edge, not a wash.
                  : RadialGradient(
                      colors: [
                        WithMeColors.mint.withValues(alpha: 0.58),
                        WithMeColors.mint.withValues(alpha: 0.52),
                        WithMeColors.mint.withValues(alpha: 0.0),
                      ],
                      stops: const [0, 0.88, 1],
                    ),
              shape: square ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: square ? BorderRadius.circular(28) : null,
              border: square
                  ? Border.all(color: WithMeColors.mint, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: WithMeText.option.copyWith(
                    fontWeight: FontWeight.w600,
                    color: WithMeColors.teal,
                  ),
                ),
                if (showCount)
                  Text(
                    '$seconds',
                    style: WithMeText.title.copyWith(fontSize: 26),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseChips extends StatelessWidget {
  const _PhaseChips({
    required this.phases,
    required this.active,
    required this.twoUp,
  });

  final List<(String, int, Color)> phases;
  final int active;

  /// Box breathing lays its four phases out two-up (`image29`); 4-7-8 stacks
  /// its three (`image27`).
  final bool twoUp;

  @override
  Widget build(BuildContext context) {
    Widget chip(int i) =>
        _PhaseChip(phase: phases[i], active: i == active, tall: !twoUp);

    if (!twoUp) {
      return Column(
        children: [
          for (var i = 0; i < phases.length; i++) ...[
            if (i > 0) const SizedBox(height: WithMeSpace.sm),
            chip(i),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var row = 0; row < (phases.length / 2).ceil(); row++) ...[
          if (row > 0) const SizedBox(height: WithMeSpace.sm),
          Row(
            children: [
              for (var col = 0; col < 2; col++) ...[
                if (col > 0) const SizedBox(width: WithMeSpace.md),
                Expanded(
                  child: row * 2 + col < phases.length
                      ? chip(row * 2 + col)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.phase, required this.active, this.tall = false});

  final (String, int, Color) phase;
  final bool active;

  /// 58 on image27, where three chips stack; 53 on image29's two-up grid.
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? 58 : 53,
      padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.md),
      decoration: BoxDecoration(
        color: WithMeColors.cream,
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        border: active
            ? Border.all(color: WithMeColors.teal, width: 1.6)
            : null,
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: phase.$3, shape: BoxShape.circle),
            child: Text(
              '${phase.$2}',
              style: WithMeText.caption.copyWith(
                color: WithMeColors.tealInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: WithMeSpace.md),
          Text(phase.$1, style: WithMeText.option),
        ],
      ),
    );
  }
}

/// `image28.png`, rebuilt in the V1 style.
///
/// The mockup for this one is the legacy blue screen — see the "known
/// problems" section of `docs/WITH_ME_SPEC_V1.md`.
class BoxBreathingInfoScreen extends StatelessWidget {
  const BoxBreathingInfoScreen({super.key});

  static const List<String> steps = [
    'Inhale deeply through your nose for 4 seconds.',
    'Hold your breath for 4 seconds.',
    'Exhale slowly and steadily through your mouth for 4 seconds.',
    'Hold for 4 seconds before beginning the next cycle.',
    'Repeat for as many cycles as you chose.',
  ];

  @override
  Widget build(BuildContext context) {
    return WithMeScaffold(
      title: '4·4·4·4 Box Breathing',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: 'Next',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const BreathingScreen(pattern: BreathPattern.box),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'To help you relax.',
            textAlign: TextAlign.center,
            style: WithMeText.body,
          ),
          const SizedBox(height: WithMeSpace.lg),
          WithMeCard(
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: WithMeSpace.md),
                  Text(
                    steps[i],
                    textAlign: TextAlign.center,
                    style: WithMeText.body.copyWith(color: WithMeColors.ink),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
