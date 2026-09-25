import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeScaffold.dart';
import '../Exercise/BreathSession.dart';
import '../Exercise/SighAudio.dart';
import '../Theme/WithMeTheme.dart';

class SighScreen extends StatefulWidget {
  const SighScreen({super.key});
  @override
  State<SighScreen> createState() => _SighScreenState();
}

class _SighScreenState extends State<SighScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const labels = [
    'Deep inhale',
    'Quick inhale · 1',
    'Quick inhale · 2',
    'Long exhale',
  ];
  static const cues = [
    'Breathe in slowly',
    'Take a small extra sip of air',
    'Take one more small sip of air',
    'Let the breath out slowly',
  ];
  int _cycles = 3;
  final _audio = SighAudio();
  bool _muted = false;
  bool _audioFailed = false;
  void _syncAudio() {
    unawaited(
      _audio
          .sync(playing: _session.running && !_muted, elapsed: _session.elapsed)
          .catchError((Object _) {
            if (mounted) setState(() => _audioFailed = true);
          }),
    );
  }

  late BreathSession _session;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = BreathSession(durations: const [4, 1, 1, 8], cycles: _cycles);
    _ticker = createTicker((elapsed) {
      final delta = elapsed - _last;
      _last = elapsed;
      setState(() => _session.advance(delta));
      if (_session.complete) {
        _ticker.stop();
        _syncAudio();
      }
    });
  }

  void _pause() {
    _ticker.stop();
    setState(_session.pause);
    _syncAudio();
  }

  void _play() {
    if (_session.complete) _session.reset();
    _last = Duration.zero;
    setState(_session.play);
    _ticker.start();
    _syncAudio();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _session.running) _pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _audio.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _session.phaseIndex;
    final progress = Curves.easeInOutSine.transform(_session.phaseProgress);
    final inflation = _session.complete
        ? 0.0
        : switch (phase) {
            0 => ui.lerpDouble(0, .72, progress)!,
            1 => ui.lerpDouble(.72, .86, progress)!,
            2 => ui.lerpDouble(.86, 1, progress)!,
            _ => 1 - progress,
          };
    return WithMeScaffold(
      title: 'Psychological Sigh',
      onBack: () => Navigator.of(context).pop(),
      action: WithMeButton(
        label: _session.complete
            ? 'Breathe again'
            : _session.running
            ? 'Pause'
            : _session.started
            ? 'Resume'
            : 'Start breathing',
        onPressed: _session.running ? _pause : _play,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: Icon(
                _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              ),
              label: Text(_muted ? 'Breath sound off' : 'Breath sound on'),
              onPressed: () {
                setState(() => _muted = !_muted);
                _syncAudio();
              },
            ),
          ),
          if (_audioFailed)
            Text(
              'Sound could not play. You can still follow the lungs.',
              style: WithMeText.caption,
            ),
          Text(
            'One deep inhale, two quick inhales, then a long exhale.',
            style: WithMeText.option,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (!_session.started) ...[
            Text(
              'Number of cycles',
              style: WithMeText.fieldLabel,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                for (final n in [1, 2, 3, 5, 10])
                  ChoiceChip(
                    label: Text('$n'),
                    selected: _cycles == n,
                    onSelected: (_) => setState(() {
                      _cycles = n;
                      _session.dispose();
                      _session = BreathSession(
                        durations: const [4, 1, 1, 8],
                        cycles: n,
                      );
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Semantics(
            image: true,
            label: 'Lungs ${phase == 3 ? 'compressing' : 'expanding'}',
            child: SizedBox(
              height: 280,
              child: CustomPaint(
                painter: _LungsPainter(
                  MediaQuery.disableAnimationsOf(context) ? .45 : inflation,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              _session.complete ? 'Session complete' : labels[phase],
              textAlign: TextAlign.center,
              style: WithMeText.title,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _session.complete ? 'Take a moment to settle.' : cues[phase],
            textAlign: TextAlign.center,
            style: WithMeText.option,
          ),
          const SizedBox(height: 16),
          Text(
            'Cycle ${_session.round} of $_cycles',
            textAlign: TextAlign.center,
            style: WithMeText.caption,
          ),
        ],
      ),
    );
  }
}

/// Mirrored rounded silhouettes follow the supplied lung reference.
class _LungsPainter extends CustomPainter {
  const _LungsPainter(this.inflation);
  final double inflation;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 300).clamp(0.0, 1.1);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    final expansion = .79 + .21 * inflation;
    canvas.scale(expansion, .9 + .1 * inflation);
    for (final mirror in [-1.0, 1.0]) {
      canvas.save();
      canvas.scale(mirror, 1);
      final path = Path()
        ..moveTo(20, -114)
        ..cubicTo(39, -132, 104, -83, 124, -29)
        ..cubicTo(140, 13, 148, 78, 124, 106)
        ..cubicTo(110, 124, 88, 86, 57, 77)
        ..cubicTo(26, 68, 21, 59, 23, 31)
        ..cubicTo(29, 4, 13, -15, 17, -41)
        ..cubicTo(22, -71, 13, -101, 20, -114)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xffd0eee0), Color(0xff78b9ad)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(const Rect.fromLTWH(10, -120, 135, 235)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = WithMeColors.tealInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LungsPainter old) => old.inflation != inflation;
}
