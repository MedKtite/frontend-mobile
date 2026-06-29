import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// The five main-tab destinations, in order.
enum NavTab { home, search, library, insights, profile }

/// Compact frosted bottom navigation (design-system.md §16).
///
/// A light `BackdropFilter` frost over a translucent surface tint, a rounded
/// top, a hairline top border, and five tappable destinations. Content scrolls
/// beneath it — use with `extendBody: true`.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final NavTab current;
  final ValueChanged<NavTab> onSelect;

  static const double _radius = 24; // top-corner radius (bottom corners 0)
  static const double _barHeight = 56; // content height; +safe-area inset below
  static const double _blur = 18;

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

    // Translucent surface so the frost reads, but opaque enough for legibility.
    final tint = colors.surface.withValues(alpha: isLight ? 0.82 : 0.86);

    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(_radius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            border: Border(top: BorderSide(color: colors.border, width: 0.5)),
          ),
          child: SafeArea(
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
    // §16: active = full-strength brand ink, inactive = muted. Both from tokens.
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
