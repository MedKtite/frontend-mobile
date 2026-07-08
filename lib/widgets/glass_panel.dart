import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';

/// Reusable glass surface for panels, forms, cards — the SAME material as
/// [GlassNavBar], generalized to any corner radius, so the app has one glass
/// vocabulary everywhere:
/// - Skia / no shader support (Android emulator, tests): blur-20 frost with a
///   high-opacity surface tint (82–86%) + hairline — calm, legible, premium.
/// - Impeller devices: real liquid-glass refraction with a lighter tint.
///
/// Usage: `GlassPanel(padding: EdgeInsets.all(AppSpacing.lg), child: ...)`.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = AppRadii.lg,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;

  /// Corner radius — pass an [AppRadii] double (uniform; the liquid shape
  /// doesn't support per-corner radii).
  final double radius;

  /// Optional clip override for non-uniform shapes (e.g. a bottom sheet's
  /// top-only rounding) — the glass itself stays uniform underneath and the
  /// clip hides what shouldn't show.
  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry padding;

  static const double _blur = 20; // matches GlassNavBar (Figma frost §16)
  static const double _thickness = 12; // refraction depth (liquid only)

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = borderRadius ?? BorderRadius.circular(radius);
    final hairline = Border.all(color: colors.border, width: 0.5);
    final content = Padding(padding: padding, child: child);

    if (!ImageFilter.isShaderFilterSupported) {
      // ── Skia frost — identical material to the nav bar's fallback. ──
      final tint = colors.surface.withValues(alpha: isLight ? 0.82 : 0.86);
      return ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
          child: DecoratedBox(
            decoration: BoxDecoration(color: tint, border: hairline),
            child: content,
          ),
        ),
      );
    }

    // ── Impeller: liquid glass, same settings as the nav bar. ──
    final tint = colors.surface.withValues(alpha: isLight ? 0.55 : 0.65);
    return ClipRRect(
      borderRadius: br,
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: tint,
          blur: _blur,
          thickness: _thickness,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: radius),
          child: DecoratedBox(
            decoration: BoxDecoration(border: hairline),
            child: content,
          ),
        ),
      ),
    );
  }
}
