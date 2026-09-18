import 'package:flutter/material.dart';

/// Design tokens for "With Me".
///
/// Every value here is measured off the 45 mockups in
/// `WITH ME Complete App Design V1.docx` — see `docs/WITH_ME_SPEC_V1.md` for
/// the derivation and `tool/measure_mockups.py` to reproduce it. The document
/// itself carries no numbers, so nothing below should be "tidied" without
/// re-running the measurement.
///
/// The reference device is iPhone 14/15 (390 x 844 pt). The mockups' inner
/// screen is 290 x 590 px, giving a constant x1.3448 conversion.
class WithMeColors {
  WithMeColors._();

  // --- Brand ---------------------------------------------------------------
  /// Primary. Buttons, headings, selected tiles, active tabs.
  static const Color teal = Color(0xFF0D6B63);
  /// Deepest teal — device frame stroke in the mockups, pressed states here.
  static const Color tealInk = Color(0xFF0B3E3C);
  static const Color tealLight = Color(0xFF3FA0A0);
  /// Deprecated alias kept while the legacy companion screens are rebuilt.
  static const Color tealDeep = tealInk;
  static const Color tealSoft = Color(0xFFD7EDEC);

  // --- Paper ---------------------------------------------------------------
  /// Card and unselected-row fill.
  static const Color cream = Color(0xFFFCFAF4);
  /// Menu / settings row fill, a touch warmer.
  static const Color creamWarm = Color(0xFFFDF9F2);
  /// Kept for the speech bubble, which reads brighter than a card.
  static const Color creamLight = Color(0xFFFFFDF8);
  static const Color creamShadow = Color(0x1A6B5A3E);

  // --- Page gradient -------------------------------------------------------
  /// Top of the page gradient.
  static const Color skyMint = Color(0xFFC9E5E0);
  /// Bottom of the page gradient.
  static const Color sandPeach = Color(0xFFF1CCAF);

  /// The whole background. A plain two-stop vertical gradient — the mockups
  /// have no beach scene, no sun and no surf lines.
  static const List<Color> page = [skyMint, sandPeach];

  // --- Category accents ----------------------------------------------------
  // Calendar legend, option-row dots, stressor tiles, chart series.
  /// Check-in.
  static const Color mint = Color(0xFF9BD4CB);
  /// Exercise.
  static const Color peach = Color(0xFFF5CFB3);
  /// Feeling better.
  static const Color coral = Color(0xFFE38061);
  /// Challenging day.
  static const Color pink = Color(0xFFDD7397);
  /// "Other" / inactive.
  static const Color slate = Color(0xFFC8D3CD);

  /// Series order for charts and for the four-dimension signs flow
  /// (body / feelings / mind / behaviour).
  static const List<Color> series = [mint, peach, pink, coral, teal, slate];

  // --- Mascot body ---------------------------------------------------------
  // Only used by the fallback vector painter; the shipped art is a bitmap.
  static const Color bodyLight = Color(0xFFDCEDDF);
  static const Color bodyMid = Color(0xFFAFD4CD);
  static const Color bodyDeep = Color(0xFF7FBDB6);
  static const Color bodyShade = Color(0xFF5FA49E);
  static const Color tattoo = Color(0xFF4E9C9C);
  static const Color blush = Color(0xFFF3A58E);
  static const Color eye = Color(0xFF16313B);
  static const Color eyeIris = Color(0xFF2E6E86);

  // Retained so the fallback painter and older screens still compile.
  static const Color hibiscus = coral;
  static const Color hibiscusDeep = Color(0xFFD75F4C);
  static const Color hibiscusSoft = Color(0xFFFBE0DA);
  static const Color lei = Color(0xFFF6C95C);
  static const Color leiSoft = Color(0xFFFDF0CE);
  static const Color leaf = Color(0xFF6FA35C);
  static const Color leafDeep = Color(0xFF4E7D42);
  static const Color leafSoft = Color(0xFFE1EFD8);
  static const Color sand = skyMint;

  // --- Text ----------------------------------------------------------------
  /// Body copy and row labels.
  static const Color ink = Color(0xFF14413F);
  static const Color inkSoft = Color(0xFF5A7A77);
  static const Color inkFaint = Color(0xFF8CA5A1);
  /// Destructive rows — "Log out", "Delete my account".
  static const Color danger = Color(0xFFD04A3C);

  // --- Semantic ------------------------------------------------------------
  static const Color calm = mint;
  static const Color caution = peach;
  static const Color alert = coral;

  /// Intention gauge sweep, low stress to high.
  static const List<Color> gauge = [mint, mint, peach, coral, coral];
}

/// Spacing, radii and the page grid, in logical points at the 390 pt
/// reference width.
class WithMeSpace {
  WithMeSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Page horizontal margin. Measured at x = 24 on 189 of ~200 rectangles.
  static const double pageMargin = 24;

  /// Content width at the reference: 390 - 2 * 24.
  static const double contentWidth = 342;

  /// Gap between stacked rows and cards.
  static const double rowGap = 12;

  /// Gutter between the columns of a two-up grid. Column width is then 164.
  static const double gridGutter = 14;

  /// Standard list-row height.
  static const double rowHeight = 55;

  /// Primary call-to-action. Bottom-pinned, 24 from the bottom edge.
  static const double ctaHeight = 60;

  static const double radiusSm = 12;
  /// Cards, rows and buttons. Measured at r = 15 on 108 rectangles.
  static const double radiusMd = 16;
  /// Large cards — the question card, the calendar panel.
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  /// Page padding: 24 on each side, nothing vertical (screens manage their own).
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: pageMargin);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: WithMeColors.creamShadow,
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> liftShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}

/// Type.
///
/// Both faces are **provisional** — the design document names no fonts, so
/// these were identified from the renders. See the typography section of
/// `docs/WITH_ME_SPEC_V1.md`. If the product owner supplies the real faces,
/// only [ui] and [script] below need to change.
class WithMeText {
  WithMeText._();

  /// Rounded geometric sans used for all UI copy.
  static const String ui = 'Quicksand';

  /// Upright brush script used for the wordmark and the accent lines
  /// ("Here. With you.", "Every step counts", "Breathe with me...").
  static const String script = 'Yellowtail';

  static const TextStyle wordmark = TextStyle(
    fontFamily: script,
    fontSize: 34,
    color: WithMeColors.teal,
    height: 1.10,
  );

  /// "Here. With you.", "Every step counts", "Small steps, bright futures".
  static const TextStyle accent = TextStyle(
    fontFamily: script,
    fontSize: 20,
    color: WithMeColors.coral,
    height: 1.2,
  );

  /// Deprecated alias for [accent], kept while the legacy companion screens
  /// are rebuilt.
  static const TextStyle tagline = accent;

  /// Screen title — "Monthly Calendar", "Your Insights", "Settings".
  static const TextStyle title = TextStyle(
    fontFamily: ui,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: WithMeColors.teal,
  );

  /// The question inside the check-in card.
  static const TextStyle question = TextStyle(
    fontFamily: ui,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: WithMeColors.teal,
    height: 1.35,
  );

  static const TextStyle bubble = TextStyle(
    fontFamily: ui,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: WithMeColors.ink,
    height: 1.40,
  );

  /// Row and tile labels.
  static const TextStyle option = TextStyle(
    fontFamily: ui,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: WithMeColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: ui,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: WithMeColors.inkSoft,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: ui,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: WithMeColors.inkFaint,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontFamily: ui,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  /// Small all-caps label — "QUICK ACTIONS", "DATE RANGE".
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: ui,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: WithMeColors.inkFaint,
    letterSpacing: 1.1,
  );

  /// Field label above a text input — "Name", "Email", "Sound choice".
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: ui,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: WithMeColors.inkSoft,
  );

  /// The big number on a stat tile.
  static const TextStyle stat = TextStyle(
    fontFamily: ui,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: WithMeColors.teal,
  );
}

class WithMeMotion {
  WithMeMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 620);
  static const Duration breath = Duration(milliseconds: 3800);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve gentle = Curves.easeInOutSine;
  static const Curve pop = Curves.easeOutBack;
}

/// The app-wide theme. With Me is now the whole app, so this belongs on
/// `MaterialApp.theme` rather than on individual screens.
ThemeData buildWithMeTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: WithMeColors.skyMint,
    splashFactory: InkSparkle.splashFactory,
    colorScheme: base.colorScheme.copyWith(
      primary: WithMeColors.teal,
      secondary: WithMeColors.coral,
      surface: WithMeColors.cream,
      onSurface: WithMeColors.ink,
    ),
    textTheme: base.textTheme.apply(fontFamily: WithMeText.ui),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: WithMeText.title,
      iconTheme: IconThemeData(color: WithMeColors.teal),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WithMeColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, WithMeSpace.ctaHeight),
        textStyle: WithMeText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WithMeSpace.radiusMd),
        ),
      ),
    ),
  );
}
