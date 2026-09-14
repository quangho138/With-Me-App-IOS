import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Components/SpeechBubble.dart';
import '../Components/WithMeBackdrop.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'CheckInScreen.dart';
import 'CompanionChatScreen.dart';

/// Storyboard 2 — Greeting.
///
/// The companion introduces itself, then offers the two ways in: speak, or
/// start the guided check-in. The mic is presentational for now; wiring speech
/// input is out of scope for this UI pass.
class WithMeGreetingScreen extends StatefulWidget {
  const WithMeGreetingScreen({super.key});

  @override
  State<WithMeGreetingScreen> createState() => _WithMeGreetingScreenState();
}

class _WithMeGreetingScreenState extends State<WithMeGreetingScreen> {
  bool _speaking = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.xl),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: WithMeSpace.xl),
                            SpeechBubble(
                              text:
                                  "Hi!\nI'm here with you.\nHow are you feeling today?",
                              typewriter: true,
                              onFinished: () {
                                if (mounted) setState(() => _speaking = false);
                              },
                            ),
                            const Spacer(),
                            WithMeAvatar(
                              size: 200,
                              speaking: _speaking,
                              expression: _speaking
                                  ? MascotExpression.happy
                                  : MascotExpression.listening,
                            ),
                            const SizedBox(height: WithMeSpace.lg),
                            _TapToTalk(onTap: () => _openChat(context)),
                            const SizedBox(height: WithMeSpace.md),
                            Text('Tap to talk', style: WithMeText.body),
                            const SizedBox(height: WithMeSpace.lg),
                            TextButton(
                              onPressed: () => _startCheckIn(context),
                              child: Text(
                                'Or walk me through a check-in  →',
                                style: WithMeText.option.copyWith(
                                  color: WithMeColors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: WithMeSpace.lg),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CompanionChatScreen()),
      );

  void _startCheckIn(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckInScreen()),
      );
}

/// The teal mic button with a slow pulse ring, inviting the user to speak.
class _TapToTalk extends StatefulWidget {
  const _TapToTalk({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_TapToTalk> createState() => _TapToTalkState();
}

class _TapToTalkState extends State<_TapToTalk>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tap to talk to your companion',
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 110,
          height: 110,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Two rings, offset in phase, expanding and fading outward.
                  for (var i = 0; i < 2; i++)
                    _ring((_pulse.value + i * 0.5) % 1.0),
                  child!,
                ],
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: WithMeColors.teal,
                boxShadow: WithMeSpace.liftShadow,
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ring(double t) {
    final eased = math.pow(t, 0.7).toDouble();
    return Container(
      width: 64 + eased * 46,
      height: 64 + eased * 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: WithMeColors.teal.withValues(alpha: (1 - t) * 0.45),
          width: 2,
        ),
      ),
    );
  }
}
