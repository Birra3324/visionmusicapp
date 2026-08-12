import 'package:flutter/material.dart';

// ─── Brand Colours ───────────────────────────────────────────────────────────
const kVisionGold = Color(0xFFE9B84F); // Primary metallic gold
const kVisionGoldLight = Color(0xFFF6C85D); // Bright gold — emphasis, selected
const kVisionGoldDim = Color(0xFFAA8840); // Inactive / dimmed gold
const kVisionGoldDeep = Color(0xFFC49A4A); // Pressed / deep gold
const kGoldBright = kVisionGoldLight;
const kGoldMid = kVisionGold;
const kGold = kVisionGold;

// ─── Video accent ────────────────────────────────────────────────────────────
// Gold means music, burgundy means video. The Watch card was previously blue,
// which read as a different product rather than the other half of this one.
// Restrained deep red — saturated enough to separate from gold, dark enough not
// to fight it for attention.
const kVisionRed = Color(0xFF8E2B2B); // Video accent
const kVisionRedDeep = Color(0xFF3A1214); // Video card surface
const kVisionRedBright = Color(0xFFD9483F); // Video badge / icon

// ─── Backgrounds ─────────────────────────────────────────────────────────────
const kBackgroundDark = Color(0xFF0B0806); // Near-black premium background
const kDarkBackground = kBackgroundDark;
const kAppBackground = kBackgroundDark;
const kSurfaceDark = Color(0xFF1A120D); // Elevated surface
const kCardBlack = Color(0xFF25170F); // Card surface
const kDarkCard = kCardBlack;

// ─── Text ────────────────────────────────────────────────────────────────────
const kTextMain = Color(0xFFF7F4EF); // Warm white primary text
const kTextSoft = Color(0xFFA99B90); // Warm grey secondary text
const kTextDim = Color(0xFF7A6E64); // Faint / inactive text
const kTextBlack = Colors.black;

// ─── Spacing ─────────────────────────────────────────────────────────────────
const kSpaceXXS = 4.0;
const kSpaceXS = 8.0;
const kSpaceS = 12.0;
const kSpaceM = 16.0;
const kSpaceL = 24.0;
const kSpaceXL = 32.0;
const kSpaceXXL = 48.0;

// ─── Border radii ────────────────────────────────────────────────────────────
const kRadiusXS = 8.0;
const kRadiusS = 12.0;
const kRadiusM = 16.0;
const kRadiusL = 20.0;
const kRadiusXL = 28.0;

// ─── Typography ───────────────────────────────────────────────────────────────
const kStyleDisplay = TextStyle(
  color: kTextMain,
  fontSize: 32,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.5,
  height: 1.1,
);
const kStyleTitle = TextStyle(
  color: kTextMain,
  fontSize: 22,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.3,
  height: 1.2,
);
const kStyleHeadline = TextStyle(
  color: kTextMain,
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.3,
);
const kStyleBody = TextStyle(
  color: kTextMain,
  fontSize: 15,
  fontWeight: FontWeight.w500,
  height: 1.4,
);
const kStyleCaption = TextStyle(
  color: kTextSoft,
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 1.4,
);
const kStyleLabel = TextStyle(
  color: kTextSoft,
  fontSize: 11,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.6,
);

// ─── Card / Surface decoration helpers ───────────────────────────────────────
BoxDecoration kCardDecoration({double radius = kRadiusL}) => BoxDecoration(
  color: kDarkCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ],
);

BoxDecoration kGlassDecoration({
  double radius = kRadiusL,
  double opacity = 0.85,
}) => BoxDecoration(
  color: kDarkCard.withValues(alpha: opacity),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
);

// ─── Full ThemeData ───────────────────────────────────────────────────────────
ThemeData buildVisionGoldTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kBackgroundDark,
    canvasColor: kBackgroundDark,
    dialogTheme: const DialogThemeData(backgroundColor: kSurfaceDark),
    cardColor: kDarkCard,
    colorScheme: base.colorScheme.copyWith(
      primary: kVisionGold,
      secondary: kVisionGold,
      surface: kSurfaceDark,
      onSurface: kTextMain,
      surfaceContainerHighest: kCardBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: kStyleHeadline,
      iconTheme: IconThemeData(color: kTextMain),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurfaceDark,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black,
      elevation: 0,
      // Transparent indicator removes the oversized gold pill behind the
      // selected tab. Selection is carried by icon and label colour alone,
      // which is what every major streaming app does.
      indicatorColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return kStyleLabel.copyWith(
          color: selected ? kVisionGoldLight : kTextDim,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.2,
          fontSize: 11,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? kVisionGoldLight : kTextDim,
          size: 24,
        );
      }),
      height: 62,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: kVisionGold,
      inactiveTrackColor: Colors.white24,
      thumbColor: kVisionGoldLight,
      overlayColor: Color(0x33E9B84F),
    ),
    iconTheme: const IconThemeData(color: kTextMain),
    dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 0.5),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kVisionGold,
      foregroundColor: Colors.black,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: kCardBlack,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: kVisionGoldLight,
      selectionColor: Color(0x55E9B84F),
      selectionHandleColor: kVisionGoldLight,
    ),
  );
}
