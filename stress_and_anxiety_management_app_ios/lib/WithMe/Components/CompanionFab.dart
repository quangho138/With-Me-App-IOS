import 'package:flutter/material.dart';

import '../Mascot/MascotExpression.dart';
import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';

/// The floating launcher that puts the companion within reach of the legacy
/// HOWRU.LIFE screens.
///
/// A first-time hint bubble appears beside it and then retreats, so the button
/// introduces itself without blocking anything.
class CompanionFab extends StatefulWidget {
  const CompanionFab({
    super.key,
    this.route = '/with-me/chat',
    this.showHint = true,
  });

  final String route;
  final bool showHint;

  @override
  State<CompanionFab> createState() => _CompanionFabState();
}

class _CompanionFabState extends State<CompanionFab> {
  bool _hintVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.showHint) {
      // Let the screen settle before the companion speaks up.
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _hintVisible = true);
      });
      Future.delayed(const Duration(seconds: 7), () {
        if (mounted) setState(() => _hintVisible = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedSlide(
          duration: WithMeMotion.slow,
          curve: WithMeMotion.ease,
          offset: _hintVisible ? Offset.zero : const Offset(0.25, 0),
          child: AnimatedOpacity(
            duration: WithMeMotion.slow,
            opacity: _hintVisible ? 1 : 0,
            child: Container(
              margin: const EdgeInsets.only(right: WithMeSpace.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: WithMeSpace.md,
                vertical: WithMeSpace.sm,
              ),
              decoration: BoxDecoration(
                color: WithMeColors.creamLight,
                borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
                boxShadow: WithMeSpace.liftShadow,
              ),
              child: Text(
                "Hi, I'm here with you.",
                style: WithMeText.option.copyWith(fontSize: 13.5),
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Talk to With Me, your AI companion',
          child: GestureDetector(
            onTap: () {
              setState(() => _hintVisible = false);
              Navigator.pushNamed(context, widget.route);
            },
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [WithMeColors.tealSoft, WithMeColors.leafSoft],
                ),
                border: Border.all(color: WithMeColors.creamLight, width: 2.5),
                boxShadow: WithMeSpace.liftShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: const OverflowBox(
                maxWidth: 76,
                maxHeight: 107,
                alignment: Alignment(0, -0.32),
                child: WithMeAvatar(
                  size: 74,
                  expression: MascotExpression.happy,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
