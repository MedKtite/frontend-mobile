import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/backend/profile_service.dart';
import '../user_avatar.dart';

Future<void> showEditProfileSheet(BuildContext context, {required User user}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditProfileSheet(user: user),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final User user;
  const _EditProfileSheet({required this.user});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _shortNameController = TextEditingController(text: widget.user.shortName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppSnack(context, 'Display name cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(profileServiceProvider);
      final updated = await service.updateProfile(
        displayName: name,
        shortName: _shortNameController.text.trim().isEmpty
            ? null
            : _shortNameController.text.trim(),
      );

      // Update auth state with the updated user profile
      ref.read(authProvider.notifier).updateUser(updated);

      if (mounted) {
        Navigator.of(context).pop();
        showAppSnack(context, 'Profile updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Failed to update profile: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final auth = ref.watch(authProvider);
    final currentUser = auth is AuthAuthenticated ? auth.user : widget.user;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile',
                        style: AppTypography.serif(
                          TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Update your reader name and monogram.',
                        style: AppTypography.sans(
                          TextStyle(fontSize: 13, color: colors.text3),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.text3, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Avatar Photo Picker
              Center(
                child: Column(
                  children: [
                    UserAvatar(
                      user: currentUser,
                      size: 76,
                      isEditable: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap photo to change or remove',
                      style: AppTypography.sans(
                        TextStyle(fontSize: 12, color: colors.text3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Full Display Name Field
              Text(
                'DISPLAY NAME',
                style: AppTypography.sans(
                  TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: colors.text3,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameController,
                style: AppTypography.body(colors.text),
                decoration: InputDecoration(
                  hintText: 'e.g. Mounir',
                  hintStyle: AppTypography.body(colors.text3),
                  filled: true,
                  fillColor: colors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.gilt, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Short Name / Monogram Field
              Text(
                'SHORT MONOGRAM (OPTIONAL)',
                style: AppTypography.sans(
                  TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: colors.text3,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _shortNameController,
                style: AppTypography.body(colors.text),
                maxLength: 12,
                decoration: InputDecoration(
                  hintText: 'e.g. M.',
                  hintStyle: AppTypography.body(colors.text3),
                  filled: true,
                  fillColor: colors.bg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.gilt, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Save Button
              FilledButton(
                onPressed: _isSaving ? null : _handleSave,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.text,
                  foregroundColor: colors.bg,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.bg,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: AppTypography.label(colors.bg).copyWith(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
