import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/adaptive_modal.dart';
import '../glass_panel.dart';

Future<ThemeMode?> showThemePickerSheet(
  BuildContext context, {
  required ThemeMode selected,
}) {
  return showAdaptiveModal<ThemeMode>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ThemePickerSheet(selected: selected),
  );
}

String themeModeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet({required this.selected});

  final ThemeMode selected;

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
              Text('Theme', style: AppTypography.title2(colors.text)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose how Marginalia appears.',
                style: AppTypography.subtitle(colors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final mode in ThemeMode.values) ...[
                _ThemeOption(
                  mode: mode,
                  selected: mode == selected,
                  onTap: () => Navigator.of(context).pop(mode),
                ),
                if (mode != ThemeMode.values.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, subtitle) = switch (mode) {
      ThemeMode.light => (Icons.light_mode_outlined, 'Always use light mode'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Always use dark mode'),
      ThemeMode.system =>
        (Icons.brightness_auto_outlined, 'Match your device setting'),
    };

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      themeModeLabel(mode),
                      style: AppTypography.body(colors.text)
                          .copyWith(fontWeight: FontWeight.w600),
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
