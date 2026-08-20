import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../providers/reading_settings_provider.dart';

/// The "Aa" typography sheet (Figma 297:2 + extended reader settings).
/// Each control writes [readingSettingsProvider] immediately, so the reader
/// live-previews behind it.
Future<void> showTypographySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (_) => const _TypographySheet(),
  );
}

class _TypographySheet extends ConsumerWidget {
  const _TypographySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final s = ref.watch(readingSettingsProvider);
    final ctrl = ref.read(readingSettingsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
            AppSpacing.pageHorizontal,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    bottom: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.text3,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Reading Display',
                  style: AppTypography.title2(colors.text),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('TYPEFACE'),
              const SizedBox(height: AppSpacing.sm),
              _TypefaceGrid(value: s.font, onChanged: ctrl.setFont),

              const SizedBox(height: AppSpacing.lg),
              const _SectionLabel('SIZE'),
              const SizedBox(height: AppSpacing.sm),
              _SizeRow(value: s.size, onChanged: ctrl.setSize),

              const SizedBox(height: AppSpacing.lg),
              const _SectionLabel('LINE HEIGHT'),
              const SizedBox(height: AppSpacing.sm),
              _SpacingRow(value: s.spacing, onChanged: ctrl.setSpacing),

              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('MARGINS'),
                        const SizedBox(height: AppSpacing.sm),
                        _MarginRow(value: s.margin, onChanged: ctrl.setMargin),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('ALIGNMENT'),
                        const SizedBox(height: AppSpacing.sm),
                        _AlignmentRow(
                          value: s.alignment,
                          onChanged: ctrl.setAlignment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              const _SectionLabel('THEME'),
              const SizedBox(height: AppSpacing.sm),
              _ThemeRow(value: s.theme, onChanged: ctrl.setTheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.caption(context.appColors.text3).copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ));
}

/// 4-Font Selector: Source Serif, Newsreader, Inter, Lexend (Dyslexic).
class _TypefaceGrid extends StatelessWidget {
  const _TypefaceGrid({required this.value, required this.onChanged});
  final ReaderFont value;
  final ValueChanged<ReaderFont> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final fonts = [
      (ReaderFont.serif, 'Source Serif', GoogleFonts.sourceSerif4(fontSize: 14)),
      (ReaderFont.newsreader, 'Newsreader', GoogleFonts.newsreader(fontSize: 14)),
      (ReaderFont.sans, 'Inter', GoogleFonts.inter(fontSize: 14)),
      (ReaderFont.dyslexic, 'Dyslexic', GoogleFonts.lexend(fontSize: 13)),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: fonts.map((item) {
          final isSelected = value == item.$1;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(item.$1),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      )
                    : null,
                child: Text(
                  item.$2,
                  style: item.$3.copyWith(
                    color: isSelected ? colors.text : colors.text2,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SizeRow extends StatelessWidget {
  const _SizeRow({required this.value, required this.onChanged});
  final ReaderSize value;
  final ValueChanged<ReaderSize> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: ReaderSize.values.map((size) {
          final isSelected = value == size;
          final letterSize = switch (size) {
            ReaderSize.small => 13.0,
            ReaderSize.medium => 16.0,
            ReaderSize.large => 19.0,
            ReaderSize.xlarge => 22.0,
          };
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(size),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      )
                    : null,
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: letterSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? colors.text : colors.text2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.value, required this.onChanged});
  final ReaderSpacing value;
  final ValueChanged<ReaderSpacing> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: ReaderSpacing.values.map((sp) {
          final isSelected = value == sp;
          final label = switch (sp) {
            ReaderSpacing.tight => 'Tight',
            ReaderSpacing.normal => 'Normal',
            ReaderSpacing.loose => 'Loose',
          };
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(sp),
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      )
                    : null,
                child: Text(
                  label,
                  style: AppTypography.label(
                    isSelected ? colors.text : colors.text2,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MarginRow extends StatelessWidget {
  const _MarginRow({required this.value, required this.onChanged});
  final ReaderMargin value;
  final ValueChanged<ReaderMargin> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: ReaderMargin.values.map((m) {
          final isSelected = value == m;
          final label = switch (m) {
            ReaderMargin.narrow => 'S',
            ReaderMargin.normal => 'M',
            ReaderMargin.wide => 'L',
          };
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(m),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      )
                    : null,
                child: Text(
                  label,
                  style: AppTypography.label(
                    isSelected ? colors.text : colors.text2,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AlignmentRow extends StatelessWidget {
  const _AlignmentRow({required this.value, required this.onChanged});
  final ReaderAlignment value;
  final ValueChanged<ReaderAlignment> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final options = [
      (ReaderAlignment.left, Icons.format_align_left_rounded),
      (ReaderAlignment.justify, Icons.format_align_justify_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = value == opt.$1;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(opt.$1),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  opt.$2,
                  size: 18,
                  color: isSelected ? colors.text : colors.text2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.value, required this.onChanged});
  final ReaderThemeMode value;
  final ValueChanged<ReaderThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ReaderThemeMode.values.map((theme) {
        final isSelected = value == theme;
        final p = ReaderPalette.of(theme);
        final label = switch (theme) {
          ReaderThemeMode.light => 'Light',
          ReaderThemeMode.sepia => 'Sepia',
          ReaderThemeMode.dark => 'Dark',
          ReaderThemeMode.black => 'Black',
        };

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(theme),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: p.bg,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: isSelected ? p.accent : p.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: p.text,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
