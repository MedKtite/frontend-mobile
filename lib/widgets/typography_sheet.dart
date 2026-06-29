import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../providers/reading_settings_provider.dart';

/// The "Aa" typography sheet (Figma 297:2). Each control writes
/// [readingSettingsProvider] immediately, so the reader behind it live-previews.
/// Styled with the *app* tokens (not the reader palette) — it's a settings UI.
Future<void> showTypographySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
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
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.readingHorizontal,
            AppSpacing.sm,
            AppSpacing.readingHorizontal,
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
                      top: AppSpacing.xs, bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.text3,
                    borderRadius: AppRadii.brFull,
                  ),
                ),
              ),
              Center(
                child: Text('Typography',
                    style: AppTypography.title2(colors.text)),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _SectionLabel('TYPEFACE'),
              const SizedBox(height: AppSpacing.sm),
              _TypefaceToggle(value: s.font, onChanged: ctrl.setFont),
              const SizedBox(height: AppSpacing.xl),
              const _SectionLabel('SIZE'),
              const SizedBox(height: AppSpacing.sm),
              _SizeRow(value: s.size, onChanged: ctrl.setSize),
              const SizedBox(height: AppSpacing.xl),
              const _SectionLabel('LINE HEIGHT'),
              const SizedBox(height: AppSpacing.sm),
              _SpacingRow(value: s.spacing, onChanged: ctrl.setSpacing),
              const SizedBox(height: AppSpacing.xl),
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
      Text(text, style: AppTypography.overline(context.appColors.text3));
}

/// Serif / Sans segmented toggle.
class _TypefaceToggle extends StatelessWidget {
  const _TypefaceToggle({required this.value, required this.onChanged});
  final ReaderFont value;
  final ValueChanged<ReaderFont> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget seg(String label, ReaderFont font, TextStyle style) {
      final selected = value == font;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(font),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    color: colors.bg,
                    borderRadius: AppRadii.brLg,
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
              style: style.copyWith(color: selected ? colors.text : colors.text2),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadii.brXl,
      ),
      child: Row(
        children: [
          seg('Serif', ReaderFont.serif,
              AppTypography.title3(colors.text).copyWith(fontSize: 16)),
          seg('Sans', ReaderFont.sans, AppTypography.label(colors.text)),
        ],
      ),
    );
  }
}

/// Four size cells, each previewing "Aa" at an increasing glyph size.
class _SizeRow extends StatelessWidget {
  const _SizeRow({required this.value, required this.onChanged});
  final ReaderSize value;
  final ValueChanged<ReaderSize> onChanged;

  static const _preview = {
    ReaderSize.small: 14.0,
    ReaderSize.medium: 17.0,
    ReaderSize.large: 20.0,
    ReaderSize.xlarge: 24.0,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        for (final size in ReaderSize.values) ...[
          if (size != ReaderSize.values.first)
            const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(size),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == size ? colors.text : colors.surface2,
                  borderRadius: AppRadii.brMd,
                ),
                child: Text(
                  'Aa',
                  style: AppTypography.title3(
                          value == size ? colors.bg : colors.text)
                      .copyWith(
                          fontSize: _preview[size], fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Three line-height cells, each showing three rules at increasing spacing.
class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.value, required this.onChanged});
  final ReaderSpacing value;
  final ValueChanged<ReaderSpacing> onChanged;

  static const _gap = {
    ReaderSpacing.tight: 3.0,
    ReaderSpacing.normal: 5.0,
    ReaderSpacing.loose: 8.0,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget rules(Color color, double gap) {
      Widget rule() => Container(width: 28, height: 1.5, color: color);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [rule(), SizedBox(height: gap), rule(), SizedBox(height: gap), rule()],
      );
    }

    return Row(
      children: [
        for (final sp in ReaderSpacing.values) ...[
          if (sp != ReaderSpacing.values.first)
            const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(sp),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == sp ? colors.text : colors.surface2,
                  borderRadius: AppRadii.brMd,
                ),
                child: rules(value == sp ? colors.bg : colors.text2, _gap[sp]!),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Four theme swatches; the selected one gets an accent ring.
class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.value, required this.onChanged});
  final ReaderThemeMode value;
  final ValueChanged<ReaderThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        for (final mode in ReaderThemeMode.values) ...[
          if (mode != ReaderThemeMode.values.first)
            const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(mode),
              child: Builder(
                builder: (_) {
                  final pal = ReaderPalette.of(mode);
                  final selected = value == mode;
                  return Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pal.bg,
                      borderRadius: AppRadii.brMd,
                      border: Border.all(
                        color: selected ? colors.accent : colors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      'Aa',
                      style: AppTypography.title3(pal.text).copyWith(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
