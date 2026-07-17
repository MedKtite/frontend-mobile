import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/widgets/adaptive_modal.dart';
import 'glass_panel.dart';

/// Asks which shelf a book goes on. Returns `'archived'`, `'reading'`, or
/// `'listening'`; returns null if dismissed. The backend's archived status is
/// presented as the friendlier "Saved" shelf in the UI.
Future<String?> showShelfPicker(BuildContext context) {
  return showAdaptiveModal<String>(
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
    return GlassPanel(
      radius: AppRadii.xl,
      borderRadius: adaptiveModalBorderRadius(context),
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
              AdaptiveModalHandle(color: colors.border),
              Text('Add to shelf', style: AppTypography.title2(colors.text)),
              const SizedBox(height: AppSpacing.xl),
              _ShelfOption(
                icon: Icons.bookmark_outline_rounded,
                label: 'Saved',
                onTap: () => Navigator.of(context).pop('archived'),
              ),
              const SizedBox(height: AppSpacing.md),
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
      color: Colors.transparent,
      borderRadius: AppRadii.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(borderRadius: AppRadii.brLg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(icon, size: 22, color: colors.accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body(colors.text)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: colors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
