import 'package:flutter/material.dart';

/// Design tokens for the "With Me" AI companion experience.
///
/// The palette is taken from the product owners' Hawaiian-style concept board:
/// warm cream paper, deep teal ink and controls, hibiscus coral accents,
/// leaf greens, and a sunset gradient backdrop.
///
/// These tokens are deliberately kept separate from the legacy HOWRU.LIFE
/// blue-grey theme so the two can coexist while the companion is rolled out.
class WithMeColors {
  WithMeColors._();

  // --- Ink / brand ---------------------------------------------------------
  /// Primary teal used for buttons, headings and the wordmark.
  static const Color teal = Color(0xFF1F7A7A);
  static const Color tealDeep = Color(0xFF135C5C);
  static const Color tealLight = Color(0xFF3FA0A0);
  static const Color tealSoft = Color(0xFFD7EDEC);

  // --- Paper / surfaces ----------------------------------------------------
  /// Page background behind the sunset gradient.
  static const Color sand = Color(0xFFFDF4E3);
  /// Card and answer-tile fill.
  static const Color cream = Color(0xFFFBF2DE);
  /// Slightly brighter cream for the speech bubble.
  static const Color creamLight = Color(0xFFFFF9EC);
  static const Color creamShadow = Color(0x1A6B5A3E);

  // --- Accents -------------------------------------------------------------
  /// Hibiscus petal.
  static const Color hibiscus = Color(0xFFEF7E6B);
  static const Color hibiscusDeep = Color(0xFFD75F4C);
  static const Color hibiscusSoft = Color(0xFFFBE0DA);
  /// Plumeria lei.
  static const Color lei = Color(0xFFF6C95C);
  static const Color leiSoft = Color(0xFFFDF0CE);
  /// Leaf crown.
  static const Color leaf = Color(0xFF6FA35C);
  static const Color leafDeep = Color(0xFF4E7D42);
  static const Color leafSoft = Color(0xFFE1EFD8);

  // --- Mascot body ---------------------------------------------------------
  static const Color bodyLight = Color(0xFFDCEDDF);
  static const Color bodyMid = Color(0xFFAFD4CD);
  static const Color bodyDeep = Color(0xFF7FBDB6);
  static const Color bodyShade = Color(0xFF5FA49E);
  static const Color tattoo = Color(0xFF4E9C9C);
  static const Color blush = Color(0xFFF3A58E);
  static const Color eye = Color(0xFF16313B);
  static const Color eyeIris = Color(0xFF2E6E86);

  // --- Text ----------------------------------------------------------------
  static const Color ink = Color(0xFF2F4A4A);
  static const Color inkSoft = Color(0xFF6A8383);
  static const Color inkFaint = Color(0xFF9DAFAF);

  // --- Sunset backdrop -----------------------------------------------------
  static const List<Color> sunset = [
    Color(0xFFFBE3C6), // high sky
    Color(0xFFFAD3B4), // haze
    Color(0xFFF6CBB2), // horizon glow
    Color(0xFFCDE4DF), // sea
    Color(0xFFEDD9BC), // sand
  ];

  // --- Semantic ------------------------------------------------------------
  static const Color calm = Color(0xFF69B08A);
  static const Color caution = Color(0xFFE2A33F);
  static const Color alert = Color(0xFFD8604C);

  /// Gauge sweep used on the Intention screen, low stress -> high stress.
  static const List<Color> gauge = [
    Color(0xFFD8604C),
    Color(0xFFE79350),
    Color(0xFFE9C85B),
    Color(0xFF9FC062),
    Color(0xFF69B08A),
  ];
}

/// Spacing, radius and elevation scale.
class WithMeSpace {
  WithMeSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  /// Soft, warm card shadow — never a hard grey drop shadow.
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

/// Text styles. Uses the platform default family so the project stays
/// dependency-free; swap `fontFamily` here if a brand face is licensed later.
class WithMeText {
  WithMeText._();

  static const TextStyle wordmark = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: WithMeColors.teal,
    letterSpacing: 0.2,
    height: 1.1,
  );

  static const TextStyle tagline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: WithMeColors.hibiscus,
    letterSpacing: 0.3,
  );

  /// The question the companion asks — the loudest thing on most screens.
  static const TextStyle question = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: WithMeColors.ink,
    height: 1.35,
  );

  static const TextStyle bubble = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: WithMeColors.ink,
    height: 1.4,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: WithMeColors.teal,
  );

  static const TextStyle option = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    color: WithMeColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: WithMeColors.inkSoft,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: WithMeColors.inkFaint,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: WithMeColors.inkFaint,
    letterSpacing: 1.1,
  );
}

/// Motion constants. The companion should never feel snappy or mechanical —
/// everything eases slowly, the way a calm person moves.
class WithMeMotion {
  WithMeMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 620);

  /// One full breath cycle of the idle avatar.
  static const Duration breath = Duration(milliseconds: 3800);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve gentle = Curves.easeInOutSine;
  static const Curve pop = Curves.easeOutBack;
}

/// Builds the [ThemeData] applied to the With Me section of the app.
ThemeData buildWithMeTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: WithMeColors.sand,
    colorScheme: base.colorScheme.copyWith(
      primary: WithMeColors.teal,
      onPrimary: Colors.white,
      secondary: WithMeColors.hibiscus,
      onSecondary: Colors.white,
      surface: WithMeColors.cream,
      onSurface: WithMeColors.ink,
    ),
    splashFactory: InkSparkle.splashFactory,
    textTheme: base.textTheme.apply(
      bodyColor: WithMeColors.ink,
      displayColor: WithMeColors.teal,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: WithMeColors.teal),
      titleTextStyle: WithMeText.title,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WithMeColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        textStyle: WithMeText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WithMeSpace.radiusPill),
        ),
      ),
    ),
  );
}
