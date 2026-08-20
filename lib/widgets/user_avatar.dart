import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/typography.dart';
import '../core/widgets/app_snackbar.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/backend/profile_service.dart';

class UserAvatar extends ConsumerWidget {
  final User? user;
  final double size;
  final bool isEditable;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 48,
    this.isEditable = false,
    this.onTap,
  });

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      final name = file.name;

      if (bytes == null || bytes.isEmpty) {
        if (context.mounted) {
          showAppSnack(context, 'Could not read selected image file.');
        }
        return;
      }

      // Check size limit: max 5MB
      if (bytes.length > 5 * 1024 * 1024) {
        if (context.mounted) {
          showAppSnack(context, 'Image size must be under 5 MB.');
        }
        return;
      }

      if (context.mounted) {
        showAppSnack(context, 'Uploading profile photo...');
      }

      final service = ref.read(profileServiceProvider);
      final updated = await service.uploadAvatar(bytes: bytes, filename: name);
      ref.read(authProvider.notifier).updateUser(updated);

      if (context.mounted) {
        showAppSnack(context, 'Profile photo updated successfully.');
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnack(context, 'Failed to upload photo: ${e.toString()}');
      }
    }
  }

  Future<void> _removeAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(profileServiceProvider);
      final updated = await service.deleteAvatar();
      ref.read(authProvider.notifier).updateUser(updated);

      if (context.mounted) {
        showAppSnack(context, 'Profile photo removed.');
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnack(context, 'Failed to remove photo: ${e.toString()}');
      }
    }
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final hasCustomAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Photo',
                style: AppTypography.serif(
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.gilt.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_outlined, color: colors.gilt, size: 20),
                ),
                title: Text('Choose from Gallery / Files', style: AppTypography.body(colors.text)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadImage(context, ref);
                },
              ),
              if (hasCustomAvatar)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.danger.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: colors.danger, size: 20),
                  ),
                  title: Text('Remove Photo', style: AppTypography.body(colors.danger)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _removeAvatar(context, ref);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final avatarUrl = user?.avatarUrl;
    final initial = user?.avatarInitial ??
        (user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'M');

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('data:image')) {
        try {
          final commaIndex = avatarUrl.indexOf(',');
          if (commaIndex != -1) {
            final base64Str = avatarUrl.substring(commaIndex + 1);
            final Uint8List imageBytes = base64Decode(base64Str);
            return Image.memory(
              imageBytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallback(context, initial),
            );
          }
        } catch (_) {}
      } else if (avatarUrl.startsWith('http')) {
        return Image.network(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(context, initial),
        );
      }
    }

    return _buildFallback(context, initial);
  }

  Widget _buildFallback(BuildContext context, String initial) {
    final colors = context.appColors;
    return Center(
      child: Text(
        initial,
        style: AppTypography.serif(
          TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w600,
            color: colors.gilt,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.gilt.withValues(alpha: 0.12),
        border: Border.all(
          color: colors.gilt.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImageContent(context),
    );

    if (!isEditable && onTap == null) {
      return avatar;
    }

    return GestureDetector(
      onTap: onTap ?? () => _showAvatarOptions(context, ref),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (isEditable)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.text,
                  border: Border.all(color: colors.surface, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: size * 0.18,
                    color: colors.bg,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
