import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// Asks which shelf a book goes on. Returns `'reading'` / `'listening'`, or null
/// if dismissed. Used both to re-shelf an owned book and to add a catalog result.
Future<String?> showShelfPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ShelfPicker(),
  );
}

class _ShelfPicker extends StatelessWidget {
  const _ShelfPicker();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: AppRadii.brFull,
                ),
              ),
              Text('Add to shelf', style: AppTypography.title2(colors.text)),
              const SizedBox(height: AppSpacing.xl),
              _ShelfOption(
                icon: Icons.menu_book_outlined,
                label: 'Reading',
                onTap: () => Navigator.of(context).pop('reading'),
              ),
              const SizedBox(height: AppSpacing.md),
              _ShelfOption(
                icon: Icons.headphones_outlined,
                label: 'Listening',
                onTap: () => Navigator.of(context).pop('listening'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: AppTypography.label(colors.text2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShelfOption extends StatelessWidget {
  const _ShelfOption({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brLg,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(icon, size: 22, color: colors.text2),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTypography.body(colors.text)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
