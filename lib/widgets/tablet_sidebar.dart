import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../providers/auth_provider.dart';
import '../providers/state/auth_state.dart';
import 'glass_nav_bar.dart';

/// Persistent tablet navigation. Wide iPads receive the editorial sidebar;
/// narrower tablets keep the same information in a compact icon rail.
class TabletSidebar extends ConsumerWidget {
  const TabletSidebar({
    super.key,
    required this.current,
    required this.expanded,
    required this.onSelect,
  });

  final NavTab current;
  final bool expanded;
  final ValueChanged<NavTab> onSelect;

  static const _items = <(NavTab, IconData, String)>[
    (NavTab.home, Icons.home_outlined, 'Home'),
    (NavTab.discovery, Icons.explore_outlined, 'Discovery'),
    (NavTab.library, Icons.auto_stories_outlined, 'Library'),
    (NavTab.margins, Icons.format_quote_outlined, 'Margins'),
    (NavTab.insights, Icons.bar_chart_outlined, 'Insights'),
  ];

  static const _tags = <(String, Color)>[
    ('Urgent', AppColors.tagUrgent),
    ('Curious', AppColors.tagCurious),
    ('Resonant', AppColors.tagResonant),
    ('Beautiful', AppColors.tagBeautiful),
    ('Reference', AppColors.tagReference),
    ('Disagree', AppColors.tagDisagree),
    ('Revisit', AppColors.tagRevisit),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final width = expanded
        ? AppSpacing.tabletSidebarExpanded
        : AppSpacing.tabletSidebarCompact;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      decoration: BoxDecoration(
        color: colors.rail,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: expanded
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? AppSpacing.xl : AppSpacing.md,
                vertical: AppSpacing.xl,
              ),
              child: _Brand(expanded: expanded),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? AppSpacing.md : AppSpacing.sm,
              ),
              child: Column(
                children: [
                  for (final (tab, icon, label) in _items) ...[
                    _SidebarItem(
                      icon: icon,
                      label: label,
                      expanded: expanded,
                      active: current == tab,
                      onTap: () => onSelect(tab),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _TagIndex(
              expanded: expanded,
              tags: _tags,
              onTap: () => onSelect(NavTab.margins),
            ),
            const Spacer(),
            Divider(height: 1, color: colors.border),
            _Profile(
              expanded: expanded,
              name: user?.displayName ?? 'Profile',
              email: user?.email,
              initial:
                  user?.avatarInitial ?? _initial(user?.displayName) ?? 'M',
              onTap: () => onSelect(NavTab.profile),
            ),
          ],
        ),
      ),
    );
  }

  static String? _initial(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed[0].toUpperCase();
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: expanded
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Container(
          width: AppSpacing.xxxl,
          height: AppSpacing.xxxl,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.text,
            borderRadius: AppRadii.brMd,
          ),
          child: Text(
            'M',
            style: AppTypography.title3(
              colors.bg,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (expanded) ...[
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              'Marginalia',
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title3(colors.text),
            ),
          ),
        ],
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool expanded;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = active ? colors.text : colors.text2;

    return Tooltip(
      message: expanded ? '' : label,
      child: Material(
        color: active ? colors.surface2 : Colors.transparent,
        borderRadius: AppRadii.brMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brMd,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? AppSpacing.md : AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSpacing.xl, color: foreground),
                if (expanded) ...[
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    label,
                    style: AppTypography.label(foreground).copyWith(
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagIndex extends StatelessWidget {
  const _TagIndex({
    required this.expanded,
    required this.tags,
    required this.onTap,
  });

  final bool expanded;
  final List<(String, Color)> tags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? AppSpacing.xl : AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: expanded
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (expanded) ...[
            Text('TAGS', style: AppTypography.overline(colors.text3)),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final (label, color) in tags)
            InkWell(
              onTap: onTap,
              borderRadius: AppRadii.brSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSpacing.md,
                      height: AppSpacing.md,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (expanded) ...[
                      const SizedBox(width: AppSpacing.md),
                      Text(label, style: AppTypography.label(colors.text2)),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({
    required this.expanded,
    required this.name,
    required this.email,
    required this.initial,
    required this.onTap,
  });

  final bool expanded;
  final String name;
  final String? email;
  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? AppSpacing.xl : AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.xxxl,
              height: AppSpacing.xxxl,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.text,
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: AppTypography.label(
                  colors.bg,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (expanded) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        colors.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (email != null)
                      Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(colors.text3),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.settings_outlined,
                size: AppSpacing.xl,
                color: colors.text3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
