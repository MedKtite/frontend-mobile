import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/adaptive_modal.dart';
import '../../providers/reading_settings_provider.dart';

/// Bottom sheet allowing users to select book view mode (vertical vs horizontal scroll).
Future<ReaderScrollMode?> showBookModePickerSheet(
  BuildContext context, {
  required ReaderScrollMode selected,
}) {
  return showAdaptiveModal<ReaderScrollMode>(
    context: context,
    backgroundColor: context.appColors.surface,
    builder: (_) => _BookModePickerSheet(selected: selected),
  );
}

class _BookModePickerSheet extends ConsumerWidget {
  const _BookModePickerSheet({required this.selected});
  final ReaderScrollMode selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: adaptiveModalBorderRadius(context),
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
              AdaptiveModalHandle(color: colors.border),
              Text('Book Mode View', style: AppTypography.title2(colors.text)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose how pages scroll while reading.',
                style: AppTypography.subtitle(colors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final mode in ReaderScrollMode.values) ...[
                _BookModeOption(
                  mode: mode,
                  selected: mode == selected,
                  onTap: () {
                    ref.read(readingSettingsProvider.notifier).setScrollMode(mode);
                    Navigator.of(context).pop(mode);
                  },
                ),
                if (mode != ReaderScrollMode.values.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookModeOption extends StatelessWidget {
  const _BookModeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ReaderScrollMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (title, subtitle, icon) = switch (mode) {
      ReaderScrollMode.vertical => (
        'Vertical scrolling',
        'Continuous vertical scroll, like a web page',
        Icons.swap_vert_rounded,
      ),
      ReaderScrollMode.horizontal => (
        'Horizontal scrolling',
        'Page-by-page horizontal swipe, like a book',
        Icons.swap_horiz_rounded,
      ),
    };

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body(
                        colors.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTypography.caption(colors.text2)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                size: 20,
                color: selected ? colors.accent : colors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
