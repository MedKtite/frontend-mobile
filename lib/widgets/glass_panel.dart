import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = AppRadii.lg,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;

  /// Corner radius — pass an [AppRadii] double (uniform; the liquid shape
  /// doesn't support per-corner radii).
  final double radius;

  final EdgeInsetsGeometry padding;

  static const double _frostBlur = 20; // design-system frost blur (§16)
  // Liquid path: LOW blur so the backdrop stays visible through the glass
  // (heavy blur mushes it to white), DEEP thickness so edges bend hard.
  static const double _glassBlur = 5;
  static const double _thickness = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = BorderRadius.circular(radius);
    final content = Padding(padding: padding, child: child);

    if (!ImageFilter.isShaderFilterSupported) {
      // ── Skia fallback: plain frost. ──
      final tint = colors.surface.withValues(alpha: isLight ? 0.55 : 0.62);
      return ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _frostBlur, sigmaY: _frostBlur),
          child: DecoratedBox(
            decoration: BoxDecoration(color: tint),
            child: content,
          ),
        ),
      );
    }

    // ── Impeller: liquid glass. Lighter tint — refraction supplies body. ──
    final tint = colors.surface.withValues(alpha: isLight ? 0.22 : 0.30);
    return ClipRRect(
      borderRadius: br,
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: tint,
          blur: _glassBlur,
          thickness: _thickness,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: radius),
          child: content,
        ),
      ),
    );
  }
}
