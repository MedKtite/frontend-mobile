import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/annotations_provider.dart';
import '../../providers/data_sync_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reading_settings_provider.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/setting/theme_picker_sheet.dart';
import '../../widgets/setting/typography_sheet.dart';
import '../../widgets/user_avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});


  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final themeMode = ref.watch(themeProvider);
    final readingSettings = ref.watch(readingSettingsProvider);
    final booksAsync = ref.watch(libraryBooksProvider);
    final highlightsAsync = ref.watch(allHighlightsProvider);
    final notesAsync = ref.watch(allNotesProvider);

    final name = user?.displayName ?? 'Your account';
    final email = user?.email ?? '';


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Settings',
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.home),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  children: [
                    _ProfileCard(user: user, name: name, email: email),
                    const SizedBox(height: AppSpacing.md),
                    _StatsCard(
                      books: booksAsync.valueOrNull?.length ?? 0,
                      highlights: highlightsAsync.valueOrNull?.length ?? 0,
                      notes: notesAsync.valueOrNull?.length ?? 0,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      label: 'APPEARANCE',
                      rows: [
                        _SettingsRow(
                          label: 'Theme',
                          value: themeModeLabel(themeMode),
                          onTap: () => _pickTheme(context, ref, themeMode),
                        ),
                        _SettingsRow(
                          label: 'Typography',
                          value: _typographyLabel(readingSettings),
                          onTap: () => showTypographySheet(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      label: 'NOTIFICATIONS',
                      rows: [
                        _SettingsRow(
                          label: 'Notifications & Alerts',
                          value: (ref.watch(notificationPreferencesProvider).valueOrNull?.enabled ?? true) ? 'On' : 'Off',
                          onTap: () => context.push(Routes.notificationSettings),
                        ),
                      ],
                    ),
                   
                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      label: 'DATA & STORAGE',
                      rows: [
                        _SettingsRow(
                          label: 'Data, Sync & Storage',
                          value: ref.watch(dataSyncProvider).isSyncing ? 'Syncing...' : 'Up to date',
                          onTap: () => context.push(Routes.dataSync),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      label: 'SUPPORT & LEGAL',
                      rows: [
                        _SettingsRow(
                          label: 'Help & feedback',
                          onTap: () => context.push(Routes.helpSupport),
                        ),
                        _SettingsRow(
                          label: 'Privacy',
                          onTap: () => _showInfo(
                            context,
                            'Privacy',
                            'Your library, reading progress, highlights, notes, and tags belong to your account.',
                          ),
                        ),
                        _SettingsRow(
                          label: 'App version',
                          value: 'v0.1.0',
                          icon: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(
                      label: 'ACCOUNT',
                      rows: [
                        _SettingsRow(
                          label: 'Account details',
                          onTap: () => context.push(Routes.profile),
                        ),
                        _SettingsRow(
                          label: 'Sign out',
                          destructive: true,
                          onTap: () => _signOut(context, ref),
                        ),
                       
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTypography.title2(context.appColors.text)),
        content: Text(
          message,
          style: AppTypography.body(context.appColors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Done',
              style: AppTypography.label(context.appColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode selected,
  ) async {
    final choice = await showThemePickerSheet(context, selected: selected);
    if (choice != null) await ref.read(themeProvider.notifier).setTheme(choice);
  }
}

String _typographyLabel(ReadingSettings settings) {
  final font = settings.font == ReaderFont.serif ? 'Serif' : 'Sans';
  final size = switch (settings.size) {
    ReaderSize.small => 14,
    ReaderSize.medium => 17,
    ReaderSize.large => 20,
    ReaderSize.xlarge => 24,
  };
  return '$font · $size';
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(title, style: AppTypography.title2(colors.text)),
            ),
          ),
          const SizedBox(width: 44), // balances the back button
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.name,
    required this.email,
  });

  final User? user;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _Card(
      child: InkWell(
        onTap: () => context.push(Routes.profile),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              UserAvatar(user: user, size: 46),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: AppTypography.title3(colors.text)),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(email, style: AppTypography.label(colors.text2)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.books,
    required this.highlights,
    required this.notes,
  });

  final int books;
  final int highlights;
  final int notes;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            _Stat(value: books, label: 'Books'),
            const _StatDivider(),
            _Stat(value: highlights, label: 'Highlights'),
            const _StatDivider(),
            _Stat(value: notes, label: 'Notes'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: AppTypography.title2(colors.text)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.caption(colors.text2)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 30,
    child: VerticalDivider(width: 1, color: context.appColors.border),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.rows});

  final String label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(label, style: AppTypography.overline(colors.text3)),
        ),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: colors.border,
                    indent: AppSpacing.lg,
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.value,
    this.destructive = false,
    this.onTap,
    this.icon = true,
  });

  final String label;
  final String? value;
  final bool destructive;
  final VoidCallback? onTap;
  final bool icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.body(
                destructive ? colors.danger : colors.text,
              ),
            ),
            const Spacer(),
            if (value != null)
              Padding(
                padding: EdgeInsets.only(right: icon ? AppSpacing.sm : 0),
                child: Text(value!, style: AppTypography.label(colors.text2)),
              ),
            if (icon && onTap != null)
              Icon(Icons.chevron_right, size: 20, color: colors.text3),
          ],
        ),
      ),
    );
  }
}
