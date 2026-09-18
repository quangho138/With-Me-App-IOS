import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/WithMeTheme.dart';

/// The control inventory of the V1 design.
///
/// Sizes are measured, not chosen — `docs/WITH_ME_SPEC_V1.md` records where
/// each one comes from and `tool/measure_mockups.py` reproduces it. The
/// recurring numbers:
///
///   * option row        52 h, 11 gap, 16 r
///   * two-line row      76 h, 12 gap
///   * settings row      55 h (63 with a toggle), 12 gap
///   * two-up tile      163 w, 14 gutter, 105 h, 18 r
///   * three-up tile    106 w, 11 gutter, 84 h, 16 r
///   * primary action   342 x 60, 16 r, pinned 24 from the bottom

const double kOptionRowHeight = 52;
const double kOptionRowGap = 11;
const double kDetailRowHeight = 76;
const double kSettingsRowHeight = 55;
const double kToggleRowHeight = 63;
const double kTileGutter = 14;
const double kTileHeight = 105;
const double kTriTileGutter = 11;
const double kTriTileHeight = 84;

/// Full-width answer row with a colour dot — the signs, thoughts, behaviour
/// and intention screens (`image16`-`image20`).
///
/// Selected rows fill teal and flip the label to white; the dot keeps its
/// category colour either way.
class OptionRow extends StatelessWidget {
  const OptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Category colour of the leading dot. Omit for a row with no dot.
  final Color? dot;

  /// Second line — "2 min · suggested for you" on the exercise rows.
  final String? subtitle;

  /// Right-hand text, e.g. the DONE / NOW / LATER states on "Your day".
  final String? trailing;

  /// Retained from the previous control set; the V1 design uses dots.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final onTeal = selected;
    final height = subtitle == null ? kOptionRowHeight : kDetailRowHeight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WithMeMotion.fast,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
        decoration: BoxDecoration(
          color: selected ? WithMeColors.teal : WithMeColors.cream,
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Row(
          children: [
            if (dot != null) ...[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: WithMeSpace.md),
            ] else if (icon != null) ...[
              Icon(icon, size: 19, color: onTeal ? Colors.white : WithMeColors.teal),
              const SizedBox(width: WithMeSpace.md),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WithMeText.option.copyWith(
                      color: onTeal ? Colors.white : WithMeColors.ink,
                      fontWeight: subtitle == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: WithMeText.body.copyWith(
                        fontSize: 13,
                        color: onTeal
                            ? Colors.white.withValues(alpha: 0.85)
                            : WithMeColors.inkSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: WithMeText.caption.copyWith(
                  color: onTeal ? Colors.white : WithMeColors.inkFaint,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Backwards-compatible name for [OptionRow]. The older companion screens
/// construct it with an icon; the V1 screens pass a dot.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tint,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kOptionRowGap),
      child: OptionRow(
        label: label,
        selected: selected,
        onTap: onTap,
        dot: tint,
        icon: tint == null ? icon : null,
      ),
    );
  }
}

/// Grid tile with a rounded colour chip above the label — the stress-area and
/// stressor screens (`image10`-`image14`).
class OptionGridCard extends StatelessWidget {
  const OptionGridCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tint,
    this.icon,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Colour of the chip.
  final Color tint;

  /// Unused in the V1 design; kept so older callers still compile.
  final IconData? icon;

  /// Three-up tiles are shorter and set their label smaller.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chip = compact ? 22.0 : 26.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: WithMeMotion.fast,
        height: compact ? kTriTileHeight : kTileHeight,
        decoration: BoxDecoration(
          color: selected ? WithMeColors.teal : WithMeColors.cream,
          borderRadius: BorderRadius.circular(
            compact ? WithMeSpace.radiusMd : 18,
          ),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: chip,
              height: chip,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            SizedBox(height: compact ? WithMeSpace.sm : WithMeSpace.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.sm),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: WithMeText.option.copyWith(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : WithMeColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1-5 selector with the two end labels under it (`image8`, `image9`).
///
/// The V1 design draws squircle tiles, not circles — 59 x 58 with an 11 pt
/// radius on `image9`.
class ScaleSelector extends StatelessWidget {
  const ScaleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 5,
    this.lowLabel,
    this.highLabel,
    this.selectedColor,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? lowLabel;
  final String? highLabel;

  /// The design tints the chosen number by how high it is — coral for a 4 on
  /// the stress scale, teal for a 3 on motivation.
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final fill = selectedColor ?? WithMeColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = min; i <= max; i++) ...[
              if (i > min) const SizedBox(width: WithMeSpace.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: WithMeMotion.fast,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == i ? fill : WithMeColors.cream,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: WithMeSpace.cardShadow,
                    ),
                    child: Text(
                      '$i',
                      style: WithMeText.option.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: value == i ? Colors.white : WithMeColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (lowLabel != null || highLabel != null) ...[
          const SizedBox(height: WithMeSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lowLabel ?? '', style: WithMeText.caption),
              Text(highLabel ?? '', style: WithMeText.caption),
            ],
          ),
        ],
      ],
    );
  }
}

/// Mood picker — five circles, the chosen one ringed (`image7`).
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.lowLabel = 'Rough',
    this.midLabel = 'Okay',
    this.highLabel = 'Good',
  });

  /// 0-4, left to right.
  final int? value;
  final ValueChanged<int> onChanged;
  final String lowLabel;
  final String midLabel;
  final String highLabel;

  static const List<Color> _swatches = [
    WithMeColors.pink,
    WithMeColors.coral,
    WithMeColors.peach,
    WithMeColors.mint,
    WithMeColors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _swatches.length; i++)
              GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _swatches[i],
                    border: value == i
                        ? Border.all(color: WithMeColors.teal, width: 2.5)
                        : null,
                  ),
                  // The ring sits outside the swatch in the mockup, so inset
                  // the fill when selected.
                  child: value == i
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _swatches[i],
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: WithMeSpace.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lowLabel, style: WithMeText.caption),
            Text(midLabel, style: WithMeText.caption),
            Text(highLabel, style: WithMeText.caption),
          ],
        ),
      ],
    );
  }
}

/// The bottom-pinned action. 342 x 60, 16 pt radius.
class WithMeButton extends StatelessWidget {
  const WithMeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.icon,
    this.height = WithMeSpace.ctaHeight,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Filled teal, or cream with a teal label (the Log In / Continue with
  /// Google buttons on `image1`).
  final bool filled;

  final IconData? icon;
  final double height;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fill = danger
        ? WithMeColors.danger
        : (filled ? WithMeColors.teal : WithMeColors.cream);
    final ink = filled || danger ? Colors.white : WithMeColors.teal;

    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
            boxShadow: WithMeSpace.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: WithMeText.button.copyWith(color: ink)),
              if (icon != null) ...[
                const SizedBox(width: WithMeSpace.sm),
                Icon(icon, size: 19, color: ink),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented tab control — Triggers / Feelings / Stress (`image32`),
/// Week / Month / Year (`image37`), All / Notes / Exercises (`image45`).
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: WithMeColors.cream,
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: WithMeMotion.fast,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? WithMeColors.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(WithMeSpace.radiusSm),
                  ),
                  child: Text(
                    labels[i],
                    style: WithMeText.option.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: i == index ? Colors.white : WithMeColors.ink,
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

/// The segmented progress bar across the top of a check-in step
/// (`image8`, `image9`).
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: WithMeMotion.fast,
              height: 4,
              decoration: BoxDecoration(
                color: i <= index
                    ? WithMeColors.tealInk
                    : WithMeColors.teal.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Backwards-compatible alias for the older dotted indicator.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) =>
      StepProgressBar(count: count, index: index);
}

/// Labelled text field — "Name", "Email", "Daily check-in time".
class WithMeField extends StatelessWidget {
  const WithMeField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: WithMeText.fieldLabel),
          const SizedBox(height: 6),
        ],
        Container(
          height: kSettingsRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
          decoration: BoxDecoration(
            color: WithMeColors.cream,
            borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
            boxShadow: WithMeSpace.cardShadow,
          ),
          child: Center(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: WithMeText.option,
              cursorColor: WithMeColors.teal,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: WithMeText.option.copyWith(
                  color: WithMeColors.inkFaint,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Labelled dropdown — the strategy and self-reflection screens
/// (`image21`, `image24`).
class WithMeDropdown extends StatelessWidget {
  const WithMeDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String? label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: WithMeText.fieldLabel),
          const SizedBox(height: 6),
        ],
        Container(
          height: kSettingsRowHeight,
          padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
          decoration: BoxDecoration(
            color: WithMeColors.cream,
            borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
            boxShadow: WithMeSpace.cardShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint ?? 'Select one...',
                style: WithMeText.option.copyWith(color: WithMeColors.inkFaint),
              ),
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: WithMeColors.teal,
              ),
              style: WithMeText.option,
              dropdownColor: WithMeColors.cream,
              borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
              items: [
                for (final item in items)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Settings / notifications row with a switch (`image41`, `image42`).
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToggleRowHeight,
      padding: const EdgeInsets.only(left: WithMeSpace.lg, right: WithMeSpace.md),
      decoration: BoxDecoration(
        color: WithMeColors.cream,
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: WithMeText.option)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: WithMeColors.mint,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: WithMeColors.slate,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

/// Plain tappable row — the menu and the non-toggle settings entries.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? trailing;

  /// "Log out", "Delete my account" — coral label, same row otherwise.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: kSettingsRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.lg),
        decoration: BoxDecoration(
          color: WithMeColors.creamWarm,
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
          boxShadow: WithMeSpace.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: WithMeText.option.copyWith(
                  color: danger ? WithMeColors.danger : WithMeColors.ink,
                ),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: WithMeText.caption),
          ],
        ),
      ),
    );
  }
}

/// Four-item bottom bar — Home / Tools / Progress / More (`image37`).
class WithMeBottomNav extends StatelessWidget {
  const WithMeBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const List<String> labels = ['Home', 'Tools', 'Progress', 'More'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: WithMeSpace.sm),
      decoration: BoxDecoration(
        color: WithMeColors.cream,
        borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        boxShadow: WithMeSpace.cardShadow,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: i == index
                            ? WithMeColors.teal
                            : WithMeColors.slate,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: WithMeText.caption.copyWith(
                        color: i == index
                            ? WithMeColors.teal
                            : WithMeColors.inkFaint,
                        fontWeight:
                            i == index ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Five-star rating (`image21`, `image23`).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 26,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                Icons.star_rounded,
                size: size,
                color: i <= value
                    ? const Color(0xFFE8A33D)
                    : WithMeColors.slate,
              ),
            ),
          ),
      ],
    );
  }
}

/// The intention gauge (`image20`) — a half-ring with a needle.
class IntentionGauge extends StatelessWidget {
  const IntentionGauge({super.key, required this.value, this.size = 170});

  /// 0 (calm) to 1 (overwhelmed).
  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: WithMeMotion.slow,
      curve: WithMeMotion.ease,
      builder: (context, v, _) => CustomPaint(
        size: Size(size, size * 0.62),
        painter: _GaugePainter(v),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - 10;
    final centre = Offset(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: centre, radius: radius);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: WithMeColors.gauge,
      ).createShader(rect);
    canvas.drawArc(rect, math.pi, math.pi, false, arc);

    final angle = math.pi + math.pi * value;
    final tip = centre + Offset(math.cos(angle), math.sin(angle)) * (radius - 16);
    canvas.drawLine(
      centre,
      tip,
      Paint()
        ..color = WithMeColors.tealInk
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(centre, 7, Paint()..color = WithMeColors.tealInk);
    canvas.drawCircle(centre, 3, Paint()..color = WithMeColors.cream);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
