import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

class DeleteBookDialog extends StatelessWidget {
  const DeleteBookDialog({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.brXl,
          boxShadow: [
            BoxShadow(
              color: colors.text.withValues(alpha: 0.14),
              blurRadius: AppSpacing.xxl,
              offset: const Offset(0, AppSpacing.sm),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete book?', style: AppTypography.title2(colors.text)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '“$title” will be permanently removed from your library.',
              style: AppTypography.subtitle(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTypography.label(colors.text2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.bg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brFull,
                    ),
                  ),
                  child: Text('Delete', style: AppTypography.label(colors.bg)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
