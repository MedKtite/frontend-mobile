import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            _TopBar(
              onBack: () => Navigator.of(context).pop(),
              onOpenSettings: () => _showPreferencesSheet(context, ref),
            ),
            const SizedBox(height: AppSpacing.sm),
            _TabFilterBar(
              activeTab: state.activeTab,
              onTabSelected: (tab) => ref.read(notificationsProvider.notifier).setTab(tab),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: state.isLoading && state.items.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.gilt,
                      ),
                    )
                  : RefreshIndicator(
                      color: colors.gilt,
                      backgroundColor: colors.surface,
                      onRefresh: () => ref.read(notificationsProvider.notifier).load(),
                      child: state.items.isEmpty
                          ? _EmptyNotificationsView(tab: state.activeTab)
                          : _NotificationsList(
                              items: state.items,
                              onTapItem: (item) {
                                ref.read(notificationsProvider.notifier).markAsRead(item.id);
                                _handleNotificationTap(context, item);
                              },
                              onDeleteItem: (item) {
                                ref.read(notificationsProvider.notifier).deleteNotification(item.id);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreferencesSheet(BuildContext context, WidgetRef ref) {
    context.push(Routes.notificationSettings);
  }

  void _handleNotificationTap(BuildContext context, NotificationItemModel item) {
    final route = item.data?['target_route'] as String?;
    if (route != null && route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onOpenSettings;

  const _TopBar({
    required this.onBack,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          _CircleIconButton(
            icon: Icons.chevron_left_rounded,
            iconSize: 26,
            onTap: onBack,
          ),

          // Title: "Notifications" in elegant serif italic
          Text(
            'Notifications',
            style: GoogleFonts.sourceSerif4(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: colors.text,
              letterSpacing: -0.3,
            ),
          ),

          // Filter / Settings Button
          _CircleIconButton(
            icon: Icons.tune_rounded,
            iconSize: 19,
            iconColor: colors.gilt,
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    this.iconSize = 22,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surface,
            border: Border.all(
              color: colors.border.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? colors.text,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Tabs (All / Unread / Activity)
// ─────────────────────────────────────────────────────────────────────────────
class _TabFilterBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;

  const _TabFilterBar({
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'All',
              isSelected: activeTab == 'all',
              onTap: () => onTabSelected('all'),
            ),
            _TabButton(
              label: 'Unread',
              isSelected: activeTab == 'unread',
              onTap: () => onTabSelected('unread'),
            ),
            _TabButton(
              label: 'Activity',
              isSelected: activeTab == 'activity',
              onTap: () => onTabSelected('activity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? colors.text : colors.text3,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: colors.gilt,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications List Grouped By Date
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationsList extends StatelessWidget {
  final List<NotificationItemModel> items;
  final ValueChanged<NotificationItemModel> onTapItem;
  final ValueChanged<NotificationItemModel> onDeleteItem;

  const _NotificationsList({
    required this.items,
    required this.onTapItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayItems = <NotificationItemModel>[];
    final earlierItems = <NotificationItemModel>[];

    for (final item in items) {
      final itemDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      if (itemDate.isAtSameMomentAs(today)) {
        todayItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.sm,
      ),
      children: [
        if (todayItems.isNotEmpty) ...[
          _SectionHeader(title: 'TODAY'),
          const SizedBox(height: AppSpacing.xs),
          ...todayItems.map((item) => _NotificationCard(
                item: item,
                onTap: () => onTapItem(item),
                onDelete: () => onDeleteItem(item),
              )),
          const SizedBox(height: AppSpacing.md),
        ],
        if (earlierItems.isNotEmpty) ...[
          _SectionHeader(title: 'EARLIER'),
          const SizedBox(height: AppSpacing.xs),
          ...earlierItems.map((item) => _NotificationCard(
                item: item,
                onTap: () => onTapItem(item),
                onDelete: () => onDeleteItem(item),
              )),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: AppTypography.sans(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: colors.text3,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Card Item
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationItemModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colors.danger.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete_outline_rounded, color: colors.danger),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.015),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Circle
                  _CategoryIconBadge(category: item.parsedCategory),

                  const SizedBox(width: AppSpacing.sm),

                  // Texts & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row: Title + Timestamp
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(item.createdAt),
                              style: AppTypography.sans(
                                TextStyle(
                                  fontSize: 12,
                                  color: colors.text3,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // Row: Body + Golden Unread Dot
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                item.body,
                                style: item.parsedCategory == NotificationCategory.quoteOfTheDay
                                    ? GoogleFonts.sourceSerif4(
                                        fontSize: 13.5,
                                        fontStyle: FontStyle.italic,
                                        color: colors.text2,
                                        height: 1.35,
                                      )
                                    : AppTypography.sans(
                                        TextStyle(
                                          fontSize: 13.5,
                                          color: colors.text2,
                                          height: 1.35,
                                        ),
                                      ),
                              ),
                            ),
                            if (item.isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.gilt,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.gilt.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon Badge
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryIconBadge extends StatelessWidget {
  final NotificationCategory category;

  const _CategoryIconBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    IconData icon;
    switch (category) {
      case NotificationCategory.readingReminder:
        icon = Icons.access_time_rounded;
        break;
      case NotificationCategory.streakUpdate:
        icon = Icons.local_fire_department_outlined;
        break;
      case NotificationCategory.quoteSaved:
        icon = Icons.bookmark_border_rounded;
        break;
      case NotificationCategory.newRecommendation:
        icon = Icons.menu_book_outlined;
        break;
      case NotificationCategory.chapterMilestone:
        icon = Icons.outlined_flag_rounded;
        break;
      case NotificationCategory.weeklyInsights:
        icon = Icons.trending_up_rounded;
        break;
      case NotificationCategory.quoteOfTheDay:
        icon = Icons.format_quote_rounded;
        break;
      case NotificationCategory.challengeProgress:
        icon = Icons.emoji_events_outlined;
        break;
      case NotificationCategory.systemActivity:
      case NotificationCategory.billing:
      case NotificationCategory.other:
        icon = Icons.notifications_none_rounded;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.gilt.withValues(alpha: 0.08),
        border: Border.all(
          color: colors.gilt.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 20,
          color: colors.gilt,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyNotificationsView extends StatelessWidget {
  final String tab;

  const _EmptyNotificationsView({required this.tab});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    String message = 'You have no notifications yet.';
    if (tab == 'unread') {
      message = 'You are all caught up. No unread notifications.';
    } else if (tab == 'activity') {
      message = 'No recent library or system activity.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: colors.text3.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Quiet for now.',
              style: GoogleFonts.sourceSerif4(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: colors.text,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 14,
                  color: colors.text3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Preferences Bottom Sheet (Settings / Filter)
// ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification Settings',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(notificationsProvider.notifier).markAllAsRead();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Mark all as read',
                    style: TextStyle(color: colors.gilt, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            prefsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Failed to load settings', style: TextStyle(color: colors.danger)),
              ),
              data: (prefs) => Column(
                children: [
                  _PreferenceToggleRow(
                    title: 'Daily Reading Reminder',
                    subtitle: 'Gentle nudge at your preferred reading time',
                    value: prefs.categories['reading_reminder'] ?? true,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleCategory('reading_reminder', val),
                  ),
                  _PreferenceToggleRow(
                    title: 'Reading Streaks & Goals',
                    subtitle: 'Celebrate milestones and streak preservation',
                    value: prefs.categories['streak_update'] ?? true,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleCategory('streak_update', val),
                  ),
                  _PreferenceToggleRow(
                    title: 'Memory Resurface & Quotes',
                    subtitle: 'Daily passage from your personal highlights',
                    value: prefs.categories['passage'] ?? true,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleCategory('passage', val),
                  ),
                  _PreferenceToggleRow(
                    title: 'Weekly Reading Insights',
                    subtitle: 'Sunday summary of reading time & margin notes',
                    value: prefs.categories['weekly_insights'] ?? true,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleCategory('weekly_insights', val),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


class _PreferenceToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.sans(
                    TextStyle(
                      fontSize: 12.5,
                      color: colors.text3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: colors.gilt,
            activeTrackColor: colors.gilt.withValues(alpha: 0.3),
            inactiveThumbColor: colors.text3,
            inactiveTrackColor: colors.surface2,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
