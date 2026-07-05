import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

enum NavTab { home, search, library, insights, profile }

class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final NavTab current;
  final ValueChanged<NavTab> onSelect;

  static const double _radius = 28;
  static const double _barHeight = 72; // Figma: 72px + safe-area inset below
  static const double _blur = 20; // Figma: BACKGROUND_BLUR 20
  static const double _glassThickness = 12; // refraction depth (liquid only)

  // (tab, inactive icon, active icon, label).
  static const _items = <(NavTab, IconData, IconData, String)>[
    (NavTab.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
    (NavTab.search, Icons.search_rounded, Icons.search_rounded, 'Search'),
    (NavTab.library, Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'Library'),
    (NavTab.insights, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Insights'),
    (NavTab.profile, Icons.person_outline, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bar = SafeArea(
      top: false,
      child: SizedBox(
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
      ),
    );

    Border hairline() =>
        Border(top: BorderSide(color: colors.border, width: 0.5));

    if (!ImageFilter.isShaderFilterSupported) {
      // ── Skia fallback (tests, older devices): plain frost per Figma. ──
      final tint = colors.surface.withValues(alpha: isLight ? 0.82 : 0.86);
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(_radius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
          child: DecoratedBox(
            decoration: BoxDecoration(color: tint, border: hairline()),
            child: bar,
          ),
        ),
      );
    }

    final tint = colors.surface.withValues(alpha: isLight ? 0.55 : 0.65);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(_radius)),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: tint,
          blur: _blur,
          thickness: _glassThickness,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: _radius),
          child: DecoratedBox(
            decoration: BoxDecoration(border: hairline()),
            child: bar,
          ),
        ),
      ),
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

  final IconData icon;
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
            child: Icon(icon, size: 22, color: color),
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
