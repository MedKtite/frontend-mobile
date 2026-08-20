import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/backend/profile_service.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/setting/change_password_sheet.dart';
import '../../widgets/setting/edit_profile_sheet.dart';
import '../../widgets/user_avatar.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brXl),
        title: Text(
          'Delete Account?',
          style: AppTypography.serif(
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.danger,
            ),
          ),
        ),
        content: Text(
          'This will permanently delete your account, your uploaded books, highlights, margin notes, and reading history.\n\nThis action cannot be undone.',
          style: AppTypography.body(colors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.label(colors.text)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final service = ref.read(profileServiceProvider);
                await service.deleteAccount();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(Routes.login);
                  showAppSnack(context, 'Your account has been deleted.');
                }
              } catch (e) {
                if (context.mounted) {
                  showAppSnack(context, 'Failed to delete account: ${e.toString()}');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initial = user.avatarInitial ??
        (user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'M');
    final isGoogleAuth = user.authProvider == 'google';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Account Details',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl,
                ),
                children: [
                  // 1. Profile Hero Card
                  _ProfileHeroCard(
                    user: user,
                    initial: initial,
                    onEdit: () => showEditProfileSheet(context, user: user),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 2. Personal Information Section
                  _SectionHeader(title: 'PERSONAL INFORMATION'),
                  const SizedBox(height: AppSpacing.xs),
                  _CardContainer(
                    children: [
                      _ProfileInfoRow(
                        label: 'Display Name',
                        value: user.displayName,
                        onTap: () => showEditProfileSheet(context, user: user),
                      ),
                      Divider(height: 1, color: colors.border.withValues(alpha: 0.08), indent: 16),
                      _ProfileInfoRow(
                        label: 'Monogram',
                        value: user.shortName ?? 'Not set',
                        onTap: () => showEditProfileSheet(context, user: user),
                      ),
                      Divider(height: 1, color: colors.border.withValues(alpha: 0.08), indent: 16),
                      _ProfileInfoRow(
                        label: 'Email',
                        value: user.email,
                        badge: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Verified',
                            style: AppTypography.sans(
                              TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.success,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: colors.border.withValues(alpha: 0.08), indent: 16),
                      _ProfileInfoRow(
                        label: 'Sign-in Method',
                        value: isGoogleAuth ? 'Google Account' : 'Email & Password',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 3. Security Section
                  _SectionHeader(title: 'SECURITY & ACCESS'),
                  const SizedBox(height: AppSpacing.xs),
                  _CardContainer(
                    children: [
                      _ProfileInfoRow(
                        label: 'Password',
                        value: isGoogleAuth ? 'Managed by Google' : '••••••••',
                        showChevron: !isGoogleAuth,
                        onTap: isGoogleAuth ? null : () => showChangePasswordSheet(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 4. Membership & Subscription Plan
                  _SectionHeader(title: 'MEMBERSHIP & PLAN'),
                  const SizedBox(height: AppSpacing.xs),
                  _CardContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.gilt.withValues(alpha: 0.1),
                              border: Border.all(color: colors.gilt.withValues(alpha: 0.25)),
                            ),
                            child: Center(
                              child: Icon(Icons.workspace_premium_rounded, color: colors.gilt, size: 22),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Marginalia Pro',
                                  style: AppTypography.serif(
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colors.text,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Unlimited library & cloud reading sync',
                                  style: AppTypography.sans(
                                    TextStyle(fontSize: 12.5, color: colors.text3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(Routes.paywall),
                            child: Text(
                              'Manage',
                              style: AppTypography.label(colors.gilt).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // 5. Danger Zone
                  _SectionHeader(title: 'DANGER ZONE'),
                  const SizedBox(height: AppSpacing.xs),
                  _CardContainer(
                    child: ListTile(
                      title: Text(
                        'Delete Account & Data',
                        style: AppTypography.body(colors.danger).copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Permanently erase your account, library, and notes.',
                        style: AppTypography.caption(colors.text3),
                      ),
                      trailing: Icon(Icons.delete_forever_rounded, color: colors.danger, size: 22),
                      onTap: () => _confirmDeleteAccount(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final User user;
  final String initial;
  final VoidCallback onEdit;

  const _ProfileHeroCard({
    required this.user,
    required this.initial,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Monogram / Photo Avatar
          UserAvatar(
            user: user,
            size: 64,
            isEditable: true,
          ),
          const SizedBox(width: 16),
          // Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTypography.serif(
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTypography.sans(
                    TextStyle(fontSize: 13, color: colors.text3),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Edit Button
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.gilt, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? badge;
  final bool showChevron;
  final VoidCallback? onTap;

  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.badge,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.text,
                ),
              ),
            ),
            const Spacer(),
            if (badge != null) ...[
              badge!,
              const SizedBox(width: 8),
            ],
            Text(
              value,
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 13.5,
                  color: colors.text2,
                ),
              ),
            ),
            if (showChevron || onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18, color: colors.text3),
            ],
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
                style: AppTypography.serif(
                  TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                    letterSpacing: -0.3,
                  ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: child ?? Column(mainAxisSize: MainAxisSize.min, children: children ?? []),
    );
  }
}