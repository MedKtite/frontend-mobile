import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/notification_preferences_model.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/setting/marginalia_time_picker.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Notification Settings',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: prefsAsync.when(
                loading: () => const AppProgressLoading(),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, color: colors.danger, size: 36),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Failed to load notification settings',
                        style: AppTypography.title3(colors.text),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () => ref.read(notificationPreferencesProvider.notifier).load(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (prefs) => _SettingsContent(prefs: prefs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.sourceSerif4(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: colors.text,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final NotificationPreferencesModel prefs;

  const _SettingsContent({required this.prefs});

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:00 $period';
  }

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref, {
    required int initialHour,
    required String title,
    String? subtitle,
    required Future<void> Function(int) onSave,
  }) async {
    final time = await showMarginaliaTimePicker(
      context,
      initialTime: TimeOfDay(hour: initialHour, minute: 0),
      title: title,
      subtitle: subtitle,
    );

    if (time != null) {
      await onSave(time.hour);
      if (context.mounted) {
        showAppSnack(context, 'Schedule updated to ${_formatHour(time.hour)}');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.xxxl,
      ),
      children: [
        // Master switch
        _CardContainer(
          child: _ToggleRow(
            title: 'Allow Notifications',
            subtitle: 'Enable or pause all alerts from Marginalia',
            value: prefs.enabled,
            onChanged: (val) => notifier.toggleMasterSwitch(val),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Section: Reading Habits
        _SectionHeader(title: 'READING HABITS'),
        const SizedBox(height: AppSpacing.xs),
        _CardContainer(
          children: [
            _ToggleRow(
              title: 'Daily Reading Ritual',
              subtitle: 'Gentle notification to pick up where you left off',
              value: prefs.enabled && (prefs.categories['reading_reminder'] ?? true),
              enabled: prefs.enabled,
              onChanged: (val) => notifier.toggleCategory('reading_reminder', val),
            ),
            if (prefs.enabled && (prefs.categories['reading_reminder'] ?? true)) ...[
              _Divider(),
              _ActionRow(
                title: 'Reminder Time',
                value: _formatHour(prefs.ritualTimeLocal),
                enabled: prefs.enabled,
                onTap: () => _selectTime(
                  context,
                  ref,
                  initialHour: prefs.ritualTimeLocal,
                  title: 'Select Reading Reminder Time',
                  onSave: (hour) => notifier.update(prefs.copyWith(ritualTimeLocal: hour)),
                ),
              ),
            ],
            _Divider(),
            _ToggleRow(
              title: 'Passage of the Day',
              subtitle: 'Resurfacing memorable highlights from your library',
              value: prefs.enabled && (prefs.categories['passage'] ?? true),
              enabled: prefs.enabled,
              onChanged: (val) => notifier.toggleCategory('passage', val),
            ),
            if (prefs.enabled && (prefs.categories['passage'] ?? true)) ...[
              _Divider(),
              _ActionRow(
                title: 'Morning Delivery Time',
                value: _formatHour(prefs.passageTimeLocal),
                enabled: prefs.enabled,
                onTap: () => _selectTime(
                  context,
                  ref,
                  initialHour: prefs.passageTimeLocal,
                  title: 'Select Morning Delivery Time',
                  onSave: (hour) => notifier.update(prefs.copyWith(passageTimeLocal: hour)),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Section: Milestones & Insights
        _SectionHeader(title: 'MILESTONES & INSIGHTS'),
        const SizedBox(height: AppSpacing.xs),
        _CardContainer(
          children: [
            _ToggleRow(
              title: 'Reading Streaks & Challenges',
              subtitle: 'Milestones, streak protection, and monthly goals',
              value: prefs.enabled && (prefs.categories['streak_update'] ?? true),
              enabled: prefs.enabled,
              onChanged: (val) => notifier.toggleCategory('streak_update', val),
            ),
            _Divider(),
            _ToggleRow(
              title: 'Weekly Reading Insights',
              subtitle: 'Sunday summary of reading time & margin notes captured',
              value: prefs.enabled && (prefs.categories['weekly_insights'] ?? true),
              enabled: prefs.enabled,
              onChanged: (val) => notifier.toggleCategory('weekly_insights', val),
            ),
            _Divider(),
            _ToggleRow(
              title: 'Chapter & Book Milestones',
              subtitle: 'Quiet celebration upon finishing chapters or books',
              value: prefs.enabled && (prefs.categories['milestone'] ?? true),
              enabled: prefs.enabled,
              onChanged: (val) => notifier.toggleCategory('milestone', val),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Section: Quiet Hours
        _SectionHeader(title: 'QUIET HOURS'),
        const SizedBox(height: AppSpacing.xs),
        _CardContainer(
          children: [
            _ActionRow(
              title: 'Quiet Window Start',
              subtitle: 'No non-urgent notifications after this time',
              value: _formatHour(prefs.quietStartLocal),
              enabled: prefs.enabled,
              onTap: () => _selectTime(
                context,
                ref,
                initialHour: prefs.quietStartLocal,
                title: 'Quiet Window Starts',
                onSave: (hour) => notifier.update(prefs.copyWith(quietStartLocal: hour)),
              ),
            ),
            _Divider(),
            _ActionRow(
              title: 'Quiet Window End',
              subtitle: 'Resume scheduled notifications in the morning',
              value: _formatHour(prefs.quietEndLocal),
              enabled: prefs.enabled,
              onTap: () => _selectTime(
                context,
                ref,
                initialHour: prefs.quietEndLocal,
                title: 'Quiet Window Ends',
                onSave: (hour) => notifier.update(prefs.copyWith(quietEndLocal: hour)),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Section: Inbox Actions
        _SectionHeader(title: 'INBOX MANAGEMENT'),
        const SizedBox(height: AppSpacing.xs),
        _CardContainer(
          child: _ActionRow(
            title: 'Mark All Notifications as Read',
            value: '',
            onTap: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              showAppSnack(context, 'All notifications marked as read');
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable UI Components
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.sans(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: colors.text3,
          ),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;

  const _CardContainer({this.child, this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: child ?? Column(mainAxisSize: MainAxisSize.min, children: children ?? []),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
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
                    color: enabled ? colors.text : colors.text3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.sans(
                      TextStyle(
                        fontSize: 12.5,
                        color: colors.text3,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch(
            value: value,
            activeThumbColor: colors.gilt,
            activeTrackColor: colors.gilt.withValues(alpha: 0.3),
            inactiveThumbColor: colors.text3,
            inactiveTrackColor: colors.surface2,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
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
                      color: enabled ? colors.text : colors.text3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.sans(
                        TextStyle(
                          fontSize: 12.5,
                          color: colors.text3,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                value,
                style: AppTypography.sans(
                  TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: enabled ? colors.gilt : colors.text3,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.text3,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.appColors.border.withValues(alpha: 0.08),
      indent: AppSpacing.lg,
    );
  }
}
