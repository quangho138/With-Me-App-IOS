import 'package:flutter/material.dart';

import '../Components/SpeechBubble.dart';
import '../Components/WithMeBackdrop.dart';
import '../Components/WithMeControls.dart';
import '../Components/WithMeWordmark.dart';
import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// A review surface for the product owners: every expression side by side,
/// plus a large live preview.
///
/// This is the screen to open in a demo when the question is "does the avatar
/// look right?" — it also doubles as a manual regression check on the painter.
class MascotGalleryScreen extends StatefulWidget {
  const MascotGalleryScreen({super.key});

  @override
  State<MascotGalleryScreen> createState() => _MascotGalleryScreenState();
}

class _MascotGalleryScreenState extends State<MascotGalleryScreen> {
  MascotExpression _selected = MascotExpression.happy;
  bool _speaking = false;

  static const _lines = {
    MascotExpression.idle: "I'm right here whenever you need me.",
    MascotExpression.happy: "Hi! I'm here with you.",
    MascotExpression.listening: "I'm listening. Take your time.",
    MascotExpression.thinking: "Let me think about what you said…",
    MascotExpression.encouraging: "You've got this. One small step.",
    MascotExpression.celebrating: "You did it! That's real progress.",
    MascotExpression.concerned: "That sounds hard. You're not alone in it.",
  };

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildWithMeTheme(),
      child: Scaffold(
        body: WithMeBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(WithMeSpace.sm),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: WithMeColors.teal,
                        tooltip: 'Back',
                      ),
                      const Expanded(
                        child: Center(
                          child: WithMeWordmark(scale: 0.6, showTagline: false),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WithMeSpace.xl,
                    ),
                    child: Column(
                      children: [
                        SpeechBubble(
                          key: ValueKey(_selected),
                          text: _lines[_selected]!,
                          typewriter: true,
                          onFinished: () {
                            if (mounted) setState(() => _speaking = false);
                          },
                        ),
                        WithMeAvatar(
                          size: 220,
                          expression: _selected,
                          speaking: _speaking,
                        ),
                        const SizedBox(height: WithMeSpace.lg),
                        Text(
                          _selected.label.toUpperCase(),
                          style: WithMeText.sectionLabel,
                        ),
                        const SizedBox(height: WithMeSpace.lg),
                        Wrap(
                          spacing: WithMeSpace.md,
                          runSpacing: WithMeSpace.md,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final e in MascotExpression.values)
                              _ExpressionSwatch(
                                expression: e,
                                selected: e == _selected,
                                onTap: () => setState(() {
                                  _selected = e;
                                  _speaking = true;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: WithMeSpace.xl),
                        const PromiseCard(compact: true),
                        const SizedBox(height: WithMeSpace.lg),
                        WithMeButton(
                          label: _speaking ? 'Stop talking' : 'Say it again',
                          filled: false,
                          onPressed: () =>
                              setState(() => _speaking = !_speaking),
                        ),
                        const SizedBox(height: WithMeSpace.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpressionSwatch extends StatelessWidget {
  const _ExpressionSwatch({
    required this.expression,
    required this.selected,
    required this.onTap,
  });

  final MascotExpression expression;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: WithMeMotion.fast,
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: WithMeSpace.sm),
        decoration: BoxDecoration(
          color: WithMeColors.creamLight.withValues(alpha: selected ? 1 : 0.7),
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
          border: Border.all(
            color: selected ? WithMeColors.teal : Colors.transparent,
            width: 2,
          ),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Column(
          children: [
            WithMeAvatarBadge(size: 52, expression: expression),
            const SizedBox(height: WithMeSpace.xs),
            Text(
              expression.label,
              textAlign: TextAlign.center,
              style: WithMeText.caption.copyWith(
                color: selected ? WithMeColors.teal : WithMeColors.inkFaint,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
