import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens — mirrors design-system.md §3 / §15.
/// Three families:
///   • Source Serif 4 — display, titles, book titles, passage quotes
///   • Inter         — all UI labels, navigation, chips, metadata, captions
///   • Newsreader    — long-form reading body only
class AppTypography {
  AppTypography._();

  // Families ────────────────────────────────────────────────────────
  static TextStyle serif([TextStyle? base]) =>
      GoogleFonts.sourceSerif4(textStyle: base);
  static TextStyle sans([TextStyle? base]) =>
      GoogleFonts.inter(textStyle: base);
  static TextStyle reading([TextStyle? base]) =>
      GoogleFonts.newsreader(textStyle: base);

  // Size ramp (size · line-height · letter-spacing)
  // Stored line-heights match design-system %s (e.g. 102 → height: 1.02).

  /// 40 / 1.0 / -0.8 · Source Serif 4 — "Marginalia" brand wordmark (above the ramp)
  static TextStyle wordmark(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 40,
      height: 1.0,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
    ),
  );

  /// 76 / 0.95 / -1.5 · Source Serif 4 — oversized brand numerals, e.g. "2,138"
  static TextStyle statNumber(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 76,
      height: 0.95,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.5,
    ),
  );

  /// Dedicated tablet-onboarding display ramp from the iPad Figma frames.
  static TextStyle onboardingWatermark(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 780,
      height: 1,
      fontWeight: FontWeight.w500,
      letterSpacing: -40,
    ),
  );

  static TextStyle onboardingWordmark(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 72,
      height: 1,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.8,
    ),
  );

  static TextStyle onboardingHero(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 48,
      height: 1.04,
      fontWeight: FontWeight.w500,
      letterSpacing: -1,
    ),
  );

  static TextStyle onboardingHeroCompact(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 40,
      height: 1.12,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
    ),
  );

  static TextStyle onboardingStat(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 168,
      height: 0.9,
      fontWeight: FontWeight.w500,
      letterSpacing: -8,
    ),
  );

  static TextStyle onboardingSubtitle(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 19,
      height: 1.5,
      fontStyle: FontStyle.italic,
    ),
  );

  static TextStyle onboardingButton(Color color) => sans(
    TextStyle(color: color, fontSize: 15.5, fontWeight: FontWeight.w600),
  );

  /// 34 / 1.02 / -0.6 · Source Serif 4 — screen titles
  static TextStyle display(Color color, {FontWeight? fontWeight}) => serif(
    TextStyle(
      color: color,
      fontSize: 34,
      height: 1.02,
      fontWeight: fontWeight ?? FontWeight.w500,
      letterSpacing: -0.6,
    ),
  );

  /// 30 / 1.05 / -0.6 · Source Serif 4 — section headers, book titles
  static TextStyle title1(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 30,
      height: 1.05,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.6,
    ),
  );

  /// 24 / 1.10 / -0.4 · Source Serif 4 — card titles
  static TextStyle title2(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 24,
      height: 1.10,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.4,
    ),
  );

  /// 18 / 1.20 / -0.2 · Source Serif 4 — compact card / list-row titles
  static TextStyle title3(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 18,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
    ),
  );

  /// 18 / 1.55 · Newsreader — reading body (long-form)
  static TextStyle bodySerif(Color color) =>
      reading(TextStyle(color: color, fontSize: 18, height: 1.55));

  /// 16 / 1.50 · Inter — UI body, notes, descriptions
  static TextStyle body(Color color) =>
      sans(TextStyle(color: color, fontSize: 16, height: 1.50));

  /// 16 / 1.50 · Source Serif 4 *italic* — editorial subtitle (onboarding, empty states)
  static TextStyle subtitle(Color color) => serif(
    TextStyle(
      color: color,
      fontSize: 16,
      height: 1.50,
      fontStyle: FontStyle.italic,
    ),
  );

  /// 14 / 1.40 · Inter — secondary labels, metadata
  static TextStyle label(Color color) =>
      sans(TextStyle(color: color, fontSize: 14, height: 1.40));

  /// 12 / 1.40 · Inter — timestamps, progress, section headers
  static TextStyle caption(Color color) =>
      sans(TextStyle(color: color, fontSize: 12, height: 1.40));

  /// 10 / 1.40 / 1.6 · Inter UPPERCASE — section labels
  static TextStyle overline(Color color) => sans(
    TextStyle(
      color: color,
      fontSize: 10,
      height: 1.40,
      letterSpacing: 1.6,
      fontWeight: FontWeight.w600,
    ),
  );
}
