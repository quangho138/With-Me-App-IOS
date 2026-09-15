import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Components/SpeechBubble.dart';
import '../Components/WithMeBackdrop.dart';
import '../Mascot/MascotExpression.dart';
import '../Theme/WithMeTheme.dart';
import 'CheckInScreen.dart';
import 'CompanionChatScreen.dart';

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
          expression: MascotExpression.happy,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: WithMeSpace.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: WithMeSpace.md,
                                vertical: WithMeSpace.sm,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.34),
                                borderRadius:
                                    BorderRadius.circular(WithMeSpace.radiusPill),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                              child: Text(
                                'WITH ME COMPANION',
                                textAlign: TextAlign.center,
                                style: WithMeText.sectionLabel.copyWith(
                                  color: WithMeColors.tealDeep,
                                ),
                              ),
                            ),
                            const SizedBox(height: WithMeSpace.lg),
                            SpeechBubble(
                              text:
                                  "Hi!\nI'm here with you.\nHow are you feeling today?",
                              typewriter: true,
                              maxWidth: constraints.maxWidth,
                              onFinished: () {
                                if (mounted) setState(() => _speaking = false);
                              },
                            ),
                            const Spacer(),
                            _TapToTalk(
                                onTap: () => _openChat(context),
                                speaking: _speaking),
                            const SizedBox(height: WithMeSpace.sm),
                            Text(
                              'Tap to talk',
                              style: WithMeText.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: WithMeColors.ink,
                              ),
                            ),
                            const SizedBox(height: WithMeSpace.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(WithMeSpace.md),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.58),
                                borderRadius:
                                    BorderRadius.circular(WithMeSpace.radiusLg),
                                boxShadow: WithMeSpace.cardShadow,
                              ),
                              child: TextButton(
                                onPressed: () => _startCheckIn(context),
                                child: Text(
                                  'Or walk me through a check-in  →',
                                  style: WithMeText.option.copyWith(
                                    color: WithMeColors.teal,
                                    fontWeight: FontWeight.w700,
                                  ),
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

class _TapToTalk extends StatefulWidget {
  const _TapToTalk({required this.onTap, required this.speaking});

  final VoidCallback onTap;
  final bool speaking;

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
          width: 124,
          height: 124,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (var i = 0; i < 2; i++) _ring((_pulse.value + i * 0.5) % 1.0),
                  child!,
                ],
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WithMeColors.teal,
                boxShadow: WithMeSpace.liftShadow,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.72),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ring(double t) {
    final eased = math.pow(t, 0.7).toDouble();
    return Container(
      width: 72 + eased * 52,
      height: 72 + eased * 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: (1 - t) * 0.42),
          width: 2,
        ),
      ),
    );
  }
}
