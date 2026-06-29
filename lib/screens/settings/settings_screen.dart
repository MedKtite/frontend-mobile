import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../widgets/auth_scaffold.dart';

/// Settings (frames `318:2` / `318:46`). Profile header reads the authenticated
/// user; the rows are stubs until their sub-screens / preferences land. Sign
/// out clears the session and returns to Login.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what — coming soon')));
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;

    final name = user?.displayName ?? 'Your account';
    final email = user?.email ?? '';
    final initial =
        user?.avatarInitial ?? (name.isEmpty ? '?' : name[0].toUpperCase());

    return Scaffold(
      backgroundColor: colors.bg,
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
                    _ProfileCard(name: name, email: email, initial: initial),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(label: 'APPEARANCE', rows: [
                      _SettingsRow(
                        label: 'Theme',
                        value: 'System',
                        onTap: () => _comingSoon(context, 'Theme'),
                      ),
                      _SettingsRow(
                        label: 'Typography',
                        value: 'Serif · 17',
                        onTap: () => _comingSoon(context, 'Typography'),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(label: 'READING & LISTENING', rows: [
                      _SettingsRow(
                        label: 'Reading defaults',
                        onTap: () => _comingSoon(context, 'Reading defaults'),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(label: 'NOTIFICATIONS', rows: [
                      _SettingsRow(
                        label: 'Notifications',
                        value: 'On',
                        onTap: () => _comingSoon(context, 'Notifications'),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(label: 'SUBSCRIPTION', rows: [
                      _SettingsRow(
                        label: 'Marginalia Pro',
                        value: 'Annual',
                        onTap: () => _comingSoon(context, 'Subscription'),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),
                    _Section(label: 'ACCOUNT', rows: [
                      _SettingsRow(
                        label: 'Sign out',
                        destructive: true,
                        onTap: () => _signOut(context, ref),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
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
    required this.name,
    required this.email,
    required this.initial,
  });

  final String name;
  final String email;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accentSoft,
              ),
              child: Text(
                initial,
                style: AppTypography.serif(TextStyle(
                  color: colors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ),
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
            const SizedBox(width: AppSpacing.md),
            const _ProBadge(),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: AppRadii.brFull,
      ),
      child: Text('PRO', style: AppTypography.overline(colors.bg)),
    );
  }
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
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(label, style: AppTypography.overline(colors.text3)),
        ),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: colors.border, indent: AppSpacing.lg),
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
    required this.onTap,
  });

  final String label;
  final String? value;
  final bool destructive;
  final VoidCallback onTap;

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
              style: AppTypography.body(destructive ? colors.danger : colors.text),
            ),
            const Spacer(),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(value!, style: AppTypography.label(colors.text2)),
              ),
            Icon(Icons.chevron_right, size: 20, color: colors.text3),
          ],
        ),
      ),
    );
  }
}
