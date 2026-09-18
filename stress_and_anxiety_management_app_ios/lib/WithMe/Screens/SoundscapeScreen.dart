import 'dart:async';

import 'package:flutter/material.dart';

import '../Components/WithMeControls.dart';
import '../Theme/WithMeTheme.dart';
import 'BeforeWeStartScreen.dart';

/// `image31.png` — the soundscape player.
///
/// The only screen in the design that abandons the mint-to-peach page
/// gradient: it takes its colour from the soundscape, warm red-to-peach for
/// Fire. There is no audio package in the project, so the transport is a
/// timer — the seam for a real player is [_tick].
class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({
    super.key,
    this.name = 'Fire',
    this.subtitle = 'Crackling logs · 40 min loop',
    this.totalSeconds = 2400,
  });

  static const String route = '/soundscape';

  final String name;
  final String subtitle;
  final int totalSeconds;

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  Timer? _timer;
  int _elapsed = 816; // 13:36, as the mockup shows
  bool _playing = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() => _playing = !_playing);
    _timer?.cancel();
    if (_playing) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  /// Where a real audio player would report position.
  void _tick() {
    if (!mounted) return;
    setState(() {
      _elapsed = _elapsed + 1 >= widget.totalSeconds ? 0 : _elapsed + 1;
    });
  }

  static String _clock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsed / widget.totalSeconds;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7E1F0E), Color(0xFFC2603C), WithMeColors.sandPeach],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: WithMeSpace.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: WithMeSpace.xxl),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: WithMeText.title.copyWith(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: WithMeSpace.xs),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: WithMeText.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: WithMeSpace.xl),
                Center(
                  child: GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      width: 150,
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.30),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: WithMeSpace.xl),
                _Transport(
                  progress: progress,
                  elapsed: _clock(_elapsed),
                  total: _clock(widget.totalSeconds),
                ),
                const SizedBox(height: WithMeSpace.md),
                Row(
                  children: [
                    Expanded(
                      child: WithMeButton(
                        label: 'Add breathing',
                        filled: false,
                        height: 48,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BeforeWeStartScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: WithMeSpace.md),
                    Expanded(
                      child: WithMeButton(
                        label: 'Save favourite',
                        filled: false,
                        height: 48,
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.name} saved.')),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                WithMeButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: WithMeSpace.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Transport extends StatelessWidget {
  const _Transport({
    required this.progress,
    required this.elapsed,
    required this.total,
  });

  final double progress;
  final String elapsed;
  final String total;

  @override
  Widget build(BuildContext context) {
    final ink = Colors.white.withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.all(WithMeSpace.lg),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: WithMeSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(elapsed, style: WithMeText.caption.copyWith(color: ink)),
              Text(total, style: WithMeText.caption.copyWith(color: ink)),
            ],
          ),
          const SizedBox(height: WithMeSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Volume', style: WithMeText.option.copyWith(color: ink)),
              Text('Timer · 20 min',
                  style: WithMeText.option.copyWith(color: ink)),
            ],
          ),
        ],
      ),
    );
  }
}
