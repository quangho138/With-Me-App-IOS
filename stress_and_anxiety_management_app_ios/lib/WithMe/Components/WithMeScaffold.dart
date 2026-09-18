import 'package:flutter/material.dart';

import '../Mascot/WithMeAvatar.dart';
import '../Theme/WithMeTheme.dart';
import 'WithMeBackdrop.dart';

/// The page shell every screen in the V1 design shares.
///
/// Measured from the mockups (see `docs/WITH_ME_SPEC_V1.md`):
///
///   * 24 pt page margin, on 189 of ~200 detected rectangles
///   * the header lockup — mascot badge plus script wordmark — top left
///   * an optional centred title under it
///   * a 60 pt primary action pinned 24 from the bottom, on 27 of 45 screens
///
/// The mockup screen is 590 px tall against 844 pt of real iPhone, so there is
/// roughly 50 pt of slack. It is absorbed by the [Spacer] between the content
/// and the action — never by scaling type or padding.
class WithMeScaffold extends StatelessWidget {
  const WithMeScaffold({
    super.key,
    this.lockup = true,
    this.title,
    this.onBack,
    this.child,
    this.action,
    this.footnote,
    this.bottomNav,
    this.scrollable = true,
    this.dimmed = false,
  });

  /// The mascot-and-wordmark lockup. Absent on the welcome screen, which shows
  /// the full-size wordmark instead, and on the menu.
  final bool lockup;

  /// Centred screen title — "Monthly Calendar", "Your Insights", "Settings".
  final String? title;

  /// Adds the back chevron the design places to the left of the title.
  final VoidCallback? onBack;

  final Widget? child;

  /// Bottom-pinned primary action.
  final Widget? action;

  /// Script line under the action — "Every step counts", "Small steps, bright
  /// futures" — or the disclaimer on the welcome and about screens.
  final Widget? footnote;

  final Widget? bottomNav;

  /// Off for screens that lay out to a fixed height (the breathing players).
  final bool scrollable;

  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lockup) const _Lockup(),
        if (title != null) _Title(title!, onBack: onBack),
        if (child != null)
          scrollable
              ? Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: WithMeSpace.lg),
                    child: child,
                  ),
                )
              : Expanded(child: child!),
        if (scrollable) const Spacer(),
        if (action != null) ...[
          const SizedBox(height: WithMeSpace.lg),
          action!,
        ],
        if (footnote != null) ...[
          const SizedBox(height: WithMeSpace.md),
          Center(child: footnote),
        ],
        SizedBox(height: bottomNav == null ? WithMeSpace.xl : WithMeSpace.md),
        if (bottomNav != null) bottomNav!,
      ],
    );

    return WithMeBackdrop(
      dimmed: dimmed,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: WithMeSpace.page,
            child: scrollable
                ? content
                // Fixed-height screens lay out against Spacers, which cannot
                // shrink. Give them the viewport as a minimum and let anything
                // shorter than the 844 pt reference scroll rather than
                // overflow.
                : LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(child: content),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Mascot badge plus the script wordmark, top left of nearly every screen.
class _Lockup extends StatelessWidget {
  const _Lockup();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: WithMeSpace.md, bottom: WithMeSpace.sm),
      child: Row(
        children: [
          const WithMeAvatarBadge(size: 30),
          const SizedBox(width: WithMeSpace.sm),
          Text(
            'With Me',
            style: WithMeText.wordmark.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text, {this.onBack});

  final String text;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: WithMeText.title,
      textAlign: TextAlign.center,
    );

    return Padding(
      padding: const EdgeInsets.only(top: WithMeSpace.sm, bottom: WithMeSpace.lg),
      child: onBack == null
          ? Center(child: label)
          : Row(
              children: [
                _BackChevron(onTap: onBack!),
                const SizedBox(width: WithMeSpace.sm),
                Expanded(child: label),
                // Balance the chevron so the title stays optically centred.
                const SizedBox(width: 24 + WithMeSpace.sm),
              ],
            ),
    );
  }
}

class _BackChevron extends StatelessWidget {
  const _BackChevron({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          Icons.chevron_left_rounded,
          size: 24,
          color: WithMeColors.teal,
        ),
      ),
    );
  }
}
