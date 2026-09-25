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
    this.background,
  });

  /// The mascot-and-wordmark lockup. Absent on the welcome screen, which shows
  /// the full-size wordmark instead, and on the menu.
  final bool lockup;

  /// Centred screen title — "Monthly Calendar", "Your Insights", "Settings".
  final String? title;

  /// What the back chevron does. Left null, the chevron still appears
  /// whenever there is a page to return to and simply pops - every screen
  /// gets a way back without having to ask for one. Pass this only when back
  /// means something else, like stepping through the check-in.
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
  final Widget? background;

  /// The explicit handler, or a plain pop when the navigator has somewhere
  /// to go. Null on a root screen - welcome, or home after signing in -
  /// where there is no previous page and a chevron would lead nowhere.
  VoidCallback? _backAction(BuildContext context) {
    if (onBack != null) return onBack;
    final navigator = Navigator.of(context);
    return navigator.canPop() ? () => navigator.maybePop() : null;
  }

  @override
  Widget build(BuildContext context) {
    final back = _backAction(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The chevron sits beside the title when there is one; otherwise
        // beside the lockup; otherwise on a row of its own, top left.
        if (lockup) _Lockup(onBack: title == null ? back : null),
        if (title != null) _Title(title!, onBack: back),
        if (!lockup && title == null && back != null)
          Padding(
            padding: const EdgeInsets.only(top: WithMeSpace.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: WithMeBackChevron(onTap: back),
            ),
          ),
        // Expanded either way, so the action stays pinned to the bottom: a
        // Spacer beside a Flexible scroll view would split the free space
        // between them and cut the content in half.
        if (child != null)
          Expanded(
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: WithMeSpace.lg),
                    child: child,
                  )
                : child!,
          )
        else
          const Spacer(),
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (background != null) Positioned.fill(child: background!),
          Scaffold(
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
                        builder: (context, constraints) =>
                            SingleChildScrollView(
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
        ],
      ),
    );
  }
}

/// Mascot badge plus the script wordmark, top left of nearly every screen.
class _Lockup extends StatelessWidget {
  const _Lockup({this.onBack});

  /// Set on screens with no title row, so the way back still has a place.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: WithMeSpace.md,
        bottom: WithMeSpace.sm,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            WithMeBackChevron(onTap: onBack!),
            const SizedBox(width: WithMeSpace.sm),
          ],
          const WithMeAvatarBadge(size: 30),
          const SizedBox(width: WithMeSpace.sm),
          Text('With Me', style: WithMeText.wordmark.copyWith(fontSize: 22)),
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
      padding: const EdgeInsets.only(
        top: WithMeSpace.sm,
        bottom: WithMeSpace.lg,
      ),
      child: onBack == null
          ? Center(child: label)
          : Row(
              children: [
                WithMeBackChevron(onTap: onBack!),
                const SizedBox(width: WithMeSpace.sm),
                Expanded(child: label),
                // Balance the chevron so the title stays optically centred.
                const SizedBox(width: 24 + WithMeSpace.sm),
              ],
            ),
    );
  }
}

class WithMeBackChevron extends StatelessWidget {
  const WithMeBackChevron({super.key, required this.onTap, this.color});

  final VoidCallback onTap;

  /// Teal by default; the soundscape draws it white on its dark scene.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // Labelled, so a screen reader announces "Back" rather than an unnamed
    // button.
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Icon(
            Icons.chevron_left_rounded,
            size: 24,
            color: color ?? WithMeColors.teal,
          ),
        ),
      ),
    );
  }
}
