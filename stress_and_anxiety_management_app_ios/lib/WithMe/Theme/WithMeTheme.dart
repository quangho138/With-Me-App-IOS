import 'package:flutter/material.dart';

/// Brand palette, spacing, typography and motion for the With Me companion.
class WithMeColors {
  WithMeColors._();

  // --- Primary palette -----------------------------------------------------
  static const Color teal = Color(0xFF2A8887);
  static const Color tealDeep = Color(0xFF226E71);
  static const Color tealLight = Color(0xFF3FA0A0);
  static const Color tealSoft = Color(0xFFCAE9E5);

  static const Color cream = Color(0xFFF7EEE2);
  static const Color creamLight = Color(0xFFFFFBF5);
  static const Color sand = Color(0xFFE9D5B8);
  static const Color creamShadow = Color(0x2FD5BEA6);

  static const Color hibiscus = Color(0xFFF37A86);
  static const Color hibiscusDeep = Color(0xFFE35C6D);
  static const Color leaf = Color(0xFF7DC36A);
  static const Color leafDeep = Color(0xFF539450);
  static const Color leafSoft = Color(0xFFE1EFD8);
  static const Color lei = Color(0xFFFFD278);

  // --- Mascot body ---------------------------------------------------------
  static const Color bodyLight = Color(0xFFE4F8DE);
  static const Color bodyMid = Color(0xFFC2EDB2);
  static const Color bodyDeep = Color(0xFFA3D88F);
  static const Color bodyShade = Color(0xFF8BC47B);
  static const Color tattoo = Color(0xFF55B6C0);
  static const Color blush = Color(0xFFF3A58E);
  static const Color eye = Color(0xFF16313B);
  static const Color eyeIris = Color(0xFF2E6E86);

  // --- Text ----------------------------------------------------------------
  static const Color ink = Color(0xFF254547);
  static const Color inkSoft = Color(0xFF557678);
  static const Color inkFaint = Color(0xFF87A1A0);

  // --- Scenic support ------------------------------------------------------
  static const Color glass = Color(0xEFFFFAF3);
  static const Color glassSoft = Color(0xD9FFFDF8);
  static const Color sky = Color(0xFF7ED2F0);
  static const Color ocean = Color(0xFF79CFD6);

  // --- Semantic ------------------------------------------------------------
  static const Color calm = Color(0xFF69B08A);
  static const Color caution = Color(0xFFE2A33F);
  static const Color alert = Color(0xFFD8604C);

  static const List<Color> gauge = [
    Color(0xFFD8604C),
    Color(0xFFE79350),
    Color(0xFFE9C85B),
    Color(0xFF9FC062),
    Color(0xFF69B08A),
  ];
}

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
  static const double radiusXl = 30;
  static const double radiusPill = 999;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: WithMeColors.creamShadow,
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> liftShadow = [
    BoxShadow(
      color: Color(0x2A000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}

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

  static const TextStyle question = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: WithMeColors.ink,
    height: 1.32,
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
    color: WithMeColors.tealDeep,
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
    fontWeight: FontWeight.w600,
    color: WithMeColors.inkFaint,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: WithMeColors.inkFaint,
    letterSpacing: 1.2,
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

ThemeData buildWithMeTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: base.colorScheme.copyWith(
      primary: WithMeColors.teal,
      onPrimary: Colors.white,
      secondary: WithMeColors.hibiscus,
      onSecondary: Colors.white,
      surface: WithMeColors.creamLight,
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
      iconTheme: IconThemeData(color: WithMeColors.tealDeep),
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
