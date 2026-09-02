import 'package:flutter/material.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

enum SnackType { success, error, warning, info }

SnackBar appSnackBar(String message, SnackType type) => SnackBar(
  elevation: 0,
  backgroundColor: Colors.transparent,
  behavior: SnackBarBehavior.floating,
  padding: EdgeInsets.zero,
  margin: const EdgeInsets.fromLTRB(
    AppSpacing.lg,
    0,
    AppSpacing.lg,
    AppSpacing.lg,
  ),
  duration: const Duration(seconds: 3),
  content: _SnackContent(message: message, type: type),
);

void showAppSnack(
  BuildContext context,
  String message, {
  SnackType type = SnackType.info,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(appSnackBar(message, type));
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.message, required this.type});

  final String message;
  final SnackType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, background, foreground) = switch (type) {
      SnackType.success => (
        Icons.check_circle_outline_rounded,
        colors.surface,
        colors.success,
      ),
      SnackType.error => (
        Icons.error_outline_rounded,
        colors.danger,
        Colors.white,
      ),
      SnackType.warning => (
        Icons.warning_amber_rounded,
        colors.warning,
        colors.text,
      ),
      SnackType.info => (
        Icons.info_outline_rounded,
        colors.accent,
        Colors.white,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.brMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: foreground),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(foreground),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            icon: Icon(Icons.close_rounded, color: foreground),
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}
