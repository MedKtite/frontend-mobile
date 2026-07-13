import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

enum NavTab { home, margins, library, insights, profile }

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final NavTab current;
  final ValueChanged<NavTab> onSelect;

  static const double _radius = 32; // floating pill — rounded on ALL corners
  static const double _barHeight = 72;
  static const double _blur = 20; // Figma: BACKGROUND_BLUR 20
  static const double _glassThickness = 12; // refraction depth (liquid only)

  // (tab, inactive icon, active icon, label). Margins uses the tag-dots
  // glyph (null icon → _TagDotsIcon) per the reference design.
  static const _items = <(NavTab, IconData?, IconData?, String)>[
    (NavTab.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
    (NavTab.margins, null, null, 'Margins'),
    (NavTab.library, Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'Library'),
    (NavTab.insights, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Insights'),
    (NavTab.profile, Icons.person_outline, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Fixed-height content — the pill floats, so the system inset lives in
    // the OUTER margin below rather than stretching the bar to the edge.
    final bar = SizedBox(
      height: _barHeight,
      child: Row(
        children: [
          for (final (tab, icon, activeIcon, label) in _items)
            Expanded(
              child: _NavItem(
                icon: tab == current ? activeIcon : icon,
                label: label,
                active: tab == current,
                onTap: () => onSelect(tab),
              ),
            ),
        ],
      ),
    );

    final Widget pill;
    if (!ImageFilter.isShaderFilterSupported || !isLight) {
      // Dark liquid glass renders an inherent lit edge that reads as a border.
      // Use the same borderless frosted surface as the shader fallback instead.
      final tint = colors.surface.withValues(alpha: isLight ? 0.82 : 0.86);
      pill = ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
          child: DecoratedBox(
            decoration: BoxDecoration(color: tint),
            child: bar,
          ),
        ),
      );
    } else {
      final tint = colors.surface.withValues(alpha: isLight ? 0.55 : 0.65);
      pill = ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            glassColor: tint,
            blur: _blur,
            thickness: _glassThickness,
          ),
          child: LiquidGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: _radius),
            child: DecoratedBox(
              decoration: const BoxDecoration(),
              child: bar,
            ),
          ),
        ),
      );
    }

    // Floating: side margins + a gap above the home indicator; content
    // scrolls beneath and around it (AppShell sets extendBody: true).
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: pill,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  /// null → the Margins tag-dots glyph instead of a Material icon.
  final IconData? icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = active ? colors.accent : colors.text3;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.brMd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Active pill in the soft accent tint — a clear, on-brand indicator.
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: active ? colors.accentSoft : Colors.transparent,
              borderRadius: AppRadii.brFull,
            ),
            child: icon == null
                ? _TagDotsIcon(active: active)
                : Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption(color).copyWith(
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Margins glyph — a 2×2 of tag-colored dots (the reference design's
/// nav icon). Dimmed when inactive so it sits with the outline icons.
class _TagDotsIcon extends StatelessWidget {
  const _TagDotsIcon({required this.active});

  final bool active;

  static const _tones = [
    AppColors.tagUrgent,
    AppColors.tagCurious,
    AppColors.tagResonant,
    AppColors.tagReference,
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.45,
      child: SizedBox(
        width: 22,
        height: 22,
        child: Center(
          child: Wrap(
            spacing: 3,
            runSpacing: 3,
            children: [
              for (final tone in _tones)
                Container(
                  width: 7,
                  height: 7,
                  decoration:
                      BoxDecoration(color: tone, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
