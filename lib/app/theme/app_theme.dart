import 'package:flutter/material.dart';
import 'tokens/colors.dart';
import 'tokens/radii.dart';
import 'tokens/typography.dart';

/// Material themes wired to Marginalia tokens. Don't reference Material's
/// default colorScheme/textTheme directly in screens — use [AppColorsExtension]
/// via `context.appColors.text` and [AppTypography] explicitly.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark()  => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;
    final ext = isLight ? AppColorsExtension.light : AppColorsExtension.dark;

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      // Transparent: the AppBackground texture (MaterialApp.builder) is the
      // real page surface. Screens needing an opaque surface (reading view)
      // set their Scaffold color explicitly.
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        surface:    ext.surface,
        primary:    ext.accent,
        secondary:  ext.accent,
        onSurface:  ext.text,
        onPrimary:  isLight ? AppColors.lightSurface : AppColors.darkSurface,
        outline:    ext.border,
      ),
      textTheme: base.textTheme.apply(
        bodyColor:    ext.text,
        displayColor: ext.text,
      ),
      // Inverted-ink primary button: text-color bg + bg-color label.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ext.text,
          foregroundColor: ext.bg,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.label(ext.bg).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ext.text,
          side: BorderSide(color: ext.border, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.label(ext.text).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: ext.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: ext.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: ext.accent, width: 1.5),
        ),
        hintStyle: AppTypography.body(ext.text3),
        labelStyle: AppTypography.label(ext.text2),
      ),
      dividerColor: ext.border,
      // Android's zoom page transition snapshots the outgoing screen with
      // toImageSync — liquid_glass_renderer's transform tracker then calls
      // markNeedsPaint mid-paint and asserts. Rendering the transition live
      // (no snapshot) looks identical and avoids the crash entirely.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android:
              ZoomPageTransitionsBuilder(allowSnapshotting: false),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[ext],
    );
  }
}
