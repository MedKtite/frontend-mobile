import 'package:flutter/material.dart';

/// Color tokens — mirrors marginalia-design/design-system.md §15.
/// Two modes (Light · Dark). Never reference raw hex outside this file.
class AppColors {
  AppColors._();

  // ── Light ───────────────────────────────────────────────────────
  static const lightBg          = Color(0xFFFAF8F5);
  static const lightSurface     = Color(0xFFFFFFFF);
  static const lightSurface2    = Color(0xFFF2EFE9);
  static const lightRail        = Color(0xFFF2EFE9);
  static const lightQuote       = Color(0xFFF2EFE9);
  static const lightBorder      = Color(0x141C1C1E); // rgba(28,28,30,0.08)
  static const lightBorderStrong= Color(0x0A1C1C1E); // rgba(28,28,30,0.04)
  static const lightText        = Color(0xFF1C1C1E);
  static const lightText2       = Color(0x941C1C1E); // 0.58
  static const lightText3       = Color(0x521C1C1E); // 0.32
  static const lightAccent      = Color(0xFF3E5C76);
  static const lightAccentSoft  = Color(0x143E5C76);
  // Warm editorial gold — wordmark, brand numerals, highlight underlines.
  // Distinct from `accent` (interactive slate). Not in design-system.md §15;
  // added to mirror the gold treatment in the onboarding Figma frames.
  static const lightGilt        = Color(0xFF9A7B3A);
  // Destructive actions (e.g. Sign out). Not in §15; added for the auth/settings
  // frames. Tag colors are annotation-only (§2) so they can't be reused here.
  static const lightDanger      = Color(0xFFC0463E);
  // Feedback tones (snackbars/status). Not in §15; muted to sit with the
  // literary palette — success leans sage, warning leans amber-orange
  // (kept apart from `gilt`, which is brand gold, not a status).
  static const lightSuccess     = Color(0xFF4E7C5B);
  static const lightWarning     = Color(0xFFB4702A);

  // ── Dark ────────────────────────────────────────────────────────
  static const darkBg           = Color(0xFF1A1A1C);
  static const darkSurface      = Color(0xFF222225);
  static const darkSurface2     = Color(0xFF2A2A2D);
  static const darkRail         = Color(0xFF161618);
  static const darkQuote        = Color(0xFF26262A);
  static const darkBorder       = Color(0x14FFFFFF);
  static const darkBorderStrong = Color(0x0AFFFFFF);
  static const darkText         = Color(0xFFF2F0EC);
  static const darkText2        = Color(0x9EF2F0EC); // 0.62
  static const darkText3        = Color(0x61F2F0EC); // 0.38
  static const darkAccent       = Color(0xFF7FA1C2);
  static const darkAccentSoft   = Color(0x143E5C76);
  static const darkGilt         = Color(0xFFC8A75C);
  static const darkDanger       = Color(0xFFE0746B);
  static const darkSuccess      = Color(0xFF83B393);
  static const darkWarning      = Color(0xFFD99A55);

  // ── Tag (identical in both modes) ──────────────────────────────
  static const tagUrgent    = Color(0xFFFF6B6B);
  static const tagCurious   = Color(0xFFFFA94D);
  static const tagResonant  = Color(0xFFFFD93D);
  static const tagBeautiful = Color(0xFF6BCB77);
  static const tagReference = Color(0xFF4D96FF);
  static const tagDisagree  = Color(0xFF9D6FE0);
  static const tagRevisit   = Color(0xFFA8A8A8);

  /// Map a system-tag name to its color (matches the 7 seeded tags in schema.sql).
  static Color forTag(String name) => switch (name) {
        'urgent'    => tagUrgent,
        'curious'   => tagCurious,
        'resonant'  => tagResonant,
        'beautiful' => tagBeautiful,
        'reference' => tagReference,
        'disagree'  => tagDisagree,
        'revisit'   => tagRevisit,
        _           => tagRevisit, // fallback to neutral
      };
}

/// ThemeExtension exposing Marginalia's non-Material tokens.
/// Access via `Theme.of(context).extension<AppColorsExtension>()` or the helper
/// `context.appColors`.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color rail;
  final Color quote;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accentSoft;
  final Color gilt;
  final Color danger;
  final Color success;
  final Color warning;

  const AppColorsExtension({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.rail,
    required this.quote,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentSoft,
    required this.gilt,
    required this.danger,
    required this.success,
    required this.warning,
  });

  static const light = AppColorsExtension(
    bg:           AppColors.lightBg,
    surface:      AppColors.lightSurface,
    surface2:     AppColors.lightSurface2,
    rail:         AppColors.lightRail,
    quote:        AppColors.lightQuote,
    border:       AppColors.lightBorder,
    borderStrong: AppColors.lightBorderStrong,
    text:         AppColors.lightText,
    text2:        AppColors.lightText2,
    text3:        AppColors.lightText3,
    accent:       AppColors.lightAccent,
    accentSoft:   AppColors.lightAccentSoft,
    gilt:         AppColors.lightGilt,
    danger:       AppColors.lightDanger,
    success:      AppColors.lightSuccess,
    warning:      AppColors.lightWarning,
  );

  static const dark = AppColorsExtension(
    bg:           AppColors.darkBg,
    surface:      AppColors.darkSurface,
    surface2:     AppColors.darkSurface2,
    rail:         AppColors.darkRail,
    quote:        AppColors.darkQuote,
    border:       AppColors.darkBorder,
    borderStrong: AppColors.darkBorderStrong,
    text:         AppColors.darkText,
    text2:        AppColors.darkText2,
    text3:        AppColors.darkText3,
    accent:       AppColors.darkAccent,
    accentSoft:   AppColors.darkAccentSoft,
    gilt:         AppColors.darkGilt,
    danger:       AppColors.darkDanger,
    success:      AppColors.darkSuccess,
    warning:      AppColors.darkWarning,
  );

  @override
  AppColorsExtension copyWith({
    Color? bg, Color? surface, Color? surface2, Color? rail, Color? quote,
    Color? border, Color? borderStrong, Color? text, Color? text2, Color? text3,
    Color? accent, Color? accentSoft, Color? gilt, Color? danger,
    Color? success, Color? warning,
  }) {
    return AppColorsExtension(
      bg:           bg ?? this.bg,
      surface:      surface ?? this.surface,
      surface2:     surface2 ?? this.surface2,
      rail:         rail ?? this.rail,
      quote:        quote ?? this.quote,
      border:       border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text:         text ?? this.text,
      text2:        text2 ?? this.text2,
      text3:        text3 ?? this.text3,
      accent:       accent ?? this.accent,
      accentSoft:   accentSoft ?? this.accentSoft,
      gilt:         gilt ?? this.gilt,
      danger:       danger ?? this.danger,
      success:      success ?? this.success,
      warning:      warning ?? this.warning,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bg:           Color.lerp(bg, other.bg, t)!,
      surface:      Color.lerp(surface, other.surface, t)!,
      surface2:     Color.lerp(surface2, other.surface2, t)!,
      rail:         Color.lerp(rail, other.rail, t)!,
      quote:        Color.lerp(quote, other.quote, t)!,
      border:       Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text:         Color.lerp(text, other.text, t)!,
      text2:        Color.lerp(text2, other.text2, t)!,
      text3:        Color.lerp(text3, other.text3, t)!,
      accent:       Color.lerp(accent, other.accent, t)!,
      accentSoft:   Color.lerp(accentSoft, other.accentSoft, t)!,
      gilt:         Color.lerp(gilt, other.gilt, t)!,
      danger:       Color.lerp(danger, other.danger, t)!,
      success:      Color.lerp(success, other.success, t)!,
      warning:      Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
