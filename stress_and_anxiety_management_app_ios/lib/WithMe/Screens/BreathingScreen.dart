import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../Components/WithMeCards.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Exercise/AmbientAudio.dart';
import '../Exercise/BreathSession.dart';
import '../Exercise/NatureVideo.dart';
import '../Theme/WithMeTheme.dart';

/// The two patterns the design names.
enum BreathPattern { fourSevenEight, box, fourFourFour }

extension BreathPatternInfo on BreathPattern {
  String get tab => switch (this) {
    BreathPattern.fourFourFour => '4 · 4 · 4',
    BreathPattern.fourSevenEight => '4 · 7 · 8',
    BreathPattern.box => '4 · 4 · 4 · 4',
  };

  String get title => switch (this) {
    BreathPattern.fourFourFour => 'Strengthen Your Focus',
    BreathPattern.fourSevenEight => 'Breathing Exercise',
    BreathPattern.box => 'Box Breathing',
  };

  String get accent => switch (this) {
    BreathPattern.fourFourFour => 'Breathe with me...',
    BreathPattern.fourSevenEight => 'Breathe with me...',
    BreathPattern.box => 'Four equal sides...',
  };

  /// Phase name, seconds, and the colour of its chip.
  List<(String, int, Color)> get phases => switch (this) {
    BreathPattern.fourFourFour => const [
      ('Inhale', 4, WithMeColors.mint),
      ('Hold', 4, WithMeColors.peach),
      ('Exhale', 4, WithMeColors.coral),
    ],
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

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({
    super.key,
    this.pattern = BreathPattern.fourSevenEight,
    this.cycles = 4,
    this.sound = 'Waves',
    this.showPatternTabs,
  }) : assert(cycles > 0);
  static const String route = '/breathing';
  final BreathPattern pattern;
  final int cycles;
  final String sound;
  final bool? showPatternTabs;
  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late BreathPattern _pattern = widget.pattern;
  late BreathSession _session;
  late final Ticker _ticker;
  final _audio = AmbientAudio();
  Duration _lastTick = Duration.zero;
  double _volume = .55;
  bool _muted = false;
  bool _audioFailed = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _makeSession();
    _ticker = createTicker((elapsed) {
      final delta = elapsed - _lastTick;
      _lastTick = elapsed;
      _session.advance(delta);
      if (_session.complete) {
        _ticker.stop();
        _syncAudio();
      }
    });
  }

  void _makeSession() {
    _session = BreathSession(
      durations: _pattern.phases.map((p) => p.$2).toList(),
      cycles: widget.cycles,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _session.running) _pause();
  }

  void _syncAudio() {
    unawaited(
      _audio
          .sync(
            sound: widget.sound,
            playing: _session.running && !_muted,
            volume: _volume,
          )
          .then((_) {
            if (mounted && _audioFailed) setState(() => _audioFailed = false);
          })
          .catchError((Object _) {
            if (mounted) setState(() => _audioFailed = true);
          }),
    );
  }

  void _pause() {
    _ticker.stop();
    _session.pause();
    _syncAudio();
  }

  void _toggle() {
    if (_session.running) {
      _pause();
      return;
    }
    if (_session.complete) _session.reset();
    _lastTick = Duration.zero;
    _session.play();
    _ticker.start();
    _syncAudio();
  }

  void _switchPattern(int index) {
    _pause();
    setState(() {
      _session.dispose();
      _pattern = BreathPattern.values[index];
      _makeSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _audio.dispose();
    _session.dispose();
    super.dispose();
  }

  String get _sceneName => switch (widget.sound) {
    'Waves' => 'By the ocean',
    'Birds' => 'A quiet morning',
    'Forest' => 'Among the trees',
    'Rain' => 'Under the rain',
    'Fire' => 'Beside the fire',
    _ => 'A moment of stillness',
  };
  String get _sceneDetail => switch (widget.sound) {
    'Waves' => 'Soft tides · warm shore',
    'Birds' => 'Birdsong · woodland nest',
    'Forest' => 'Rustling leaves · gentle wind',
    'Rain' => 'Falling rain · flowing water',
    'Fire' => 'Crackling embers · evening sky',
    _ => 'Just you and your breath',
  };

  @override
  Widget build(BuildContext context) {
    final reduce = _reducedMotion || MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        final phase = _pattern.phases[_session.phaseIndex];
        final complete = _session.complete;
        final started = _session.started;
        final label = complete ? 'Complete' : phase.$1;
        final instruction = complete ? '' : '${phase.$1} ${phase.$2} seconds';
        return WithMeScaffold(
          // Reduced motion freezes the footage on one frame.
          background: NatureVideo(sound: widget.sound, still: reduce),
          title: _pattern.title,
          onBack: () {
            _pause();
            Navigator.of(context).pop();
          },
          action: WithMeButton(
            label: complete
                ? 'Breathe again'
                : _session.running
                ? 'Pause'
                : started
                ? 'Resume'
                : 'Start breathing',
            onPressed: _toggle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showPatternTabs ??
                  widget.pattern == BreathPattern.box) ...[
                SegmentedTabs(
                  labels: [for (final p in BreathPattern.values) p.tab],
                  index: BreathPattern.values.indexOf(_pattern),
                  onChanged: _switchPattern,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _pattern.tab,
                    style: WithMeText.title.copyWith(fontSize: 18),
                  ),
                  Text(
                    complete
                        ? 'Session complete'
                        : 'Cycle ${_session.round} of ${widget.cycles}',
                    style: WithMeText.caption,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: (MediaQuery.sizeOf(context).height * .58).clamp(
                  300.0,
                  520.0,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: _BreathingPath(
                        square: _pattern == BreathPattern.box,
                        progress: _session.phaseProgress,
                        phase: phase.$1,
                        instruction: instruction,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (complete)
                Text(
                  'You made time for yourself.',
                  textAlign: TextAlign.center,
                  style: WithMeText.caption.copyWith(color: Colors.white),
                ),
              if (_audioFailed)
                TextButton(
                  onPressed: _syncAudio,
                  child: const Text('Sound unavailable. Tap to retry.'),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!MediaQuery.disableAnimationsOf(context))
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _reducedMotion = !_reducedMotion),
                      icon: Icon(
                        _reducedMotion
                            ? Icons.motion_photos_off_rounded
                            : Icons.motion_photos_on_rounded,
                        size: 17,
                      ),
                      label: Text(
                        _reducedMotion ? 'Motion off' : 'Motion on',
                        style: WithMeText.caption,
                      ),
                    ),
                  if (started && !complete)
                    TextButton(
                      onPressed: () {
                        _pause();
                        _session.reset();
                      },
                      child: Text('Restart', style: WithMeText.caption),
                    ),
                  if (complete)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BreathingPath extends StatelessWidget {
  const _BreathingPath({
    required this.square,
    required this.progress,
    required this.phase,
    required this.instruction,
  });

  final bool square;
  final double progress;
  final String phase;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: math.min(MediaQuery.sizeOf(context).width - 48, 320),
      height: math.min(MediaQuery.sizeOf(context).height * .48, 390),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _PathPainter(
              square: square,
              progress: progress,
              phase: phase,
            ),
            size: Size.infinite,
          ),
          if (instruction.isNotEmpty)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Text(
                instruction,
                textAlign: TextAlign.center,
                style: WithMeText.title.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({
    required this.square,
    required this.progress,
    required this.phase,
  });
  final bool square;
  final double progress;
  final String phase;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (square) {
      final r = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * .68,
        height: size.height * .68,
      );
      path.addRect(r);
    } else {
      path
        ..moveTo(size.width * .16, size.height * .20)
        ..lineTo(size.width * .84, size.height * .20)
        ..lineTo(size.width * .5, size.height * .76)
        ..close();
    }
    final outline = Paint()
      ..color = const Color(0xffd8f1e9).withValues(alpha: .92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outline);
    final t = progress.clamp(0.0, 1.0).toDouble();
    Offset point;
    if (square) {
      final r = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * .68,
        height: size.height * .68,
      );
      final bl = Offset(r.left, r.bottom), tl = Offset(r.left, r.top);
      final tr = Offset(r.right, r.top), br = Offset(r.right, r.bottom);
      point = switch (phase) {
        'Inhale' => Offset.lerp(bl, tl, t)!,
        'Hold' => Offset.lerp(tl, tr, t)!,
        'Exhale' => Offset.lerp(tr, br, t)!,
        _ => Offset.lerp(br, bl, t)!,
      };
    } else {
      final base = Offset(size.width * .5, size.height * .76);
      final leftTop = Offset(size.width * .16, size.height * .20);
      final rightTop = Offset(size.width * .84, size.height * .20);
      point = switch (phase) {
        'Inhale' => Offset.lerp(base, leftTop, t)!,
        'Hold' => Offset.lerp(leftTop, rightTop, t)!,
        _ => Offset.lerp(rightTop, base, t)!,
      };
    }
    canvas.drawCircle(
      point,
      18,
      Paint()
        ..color = square ? const Color(0xfff5a34d) : const Color(0xfff6e9a6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      point,
      18,
      Paint()
        ..color = Colors.white.withValues(alpha: .8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.square != square ||
      oldDelegate.phase != phase;
}

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
