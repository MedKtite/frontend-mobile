import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/adaptive_modal.dart';
import '../../providers/language_provider.dart';

Future<String?> showLanguagePickerSheet(
  BuildContext context, {
  required String selectedLanguageCode,
}) {
  return showAdaptiveModal<String>(
    context: context,
    backgroundColor: context.appColors.surface,
    builder: (_) => _LanguagePickerSheet(selected: selectedLanguageCode),
  );
}

class _LanguageOptionData {
  const _LanguageOptionData(this.code, this.nativeName, this.englishName);
  final String code;
  final String nativeName;
  final String englishName;
}

const _supportedLanguages = [
  _LanguageOptionData('en', 'English', 'English'),
  _LanguageOptionData('fr', 'Français', 'French'),
  _LanguageOptionData('es', 'Español', 'Spanish'),
  _LanguageOptionData('ar', 'العربية', 'Arabic'),
];

class _LanguagePickerSheet extends ConsumerWidget {
  const _LanguagePickerSheet({required this.selected});
  final String selected;

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
              Text('Language', style: AppTypography.title2(colors.text)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose the app language.',
                style: AppTypography.subtitle(colors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final lang in _supportedLanguages) ...[
                _LanguageOption(
                  data: lang,
                  selected: lang.code == selected,
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage(lang.code);
                    Navigator.of(context).pop(lang.code);
                  },
                ),
                if (lang != _supportedLanguages.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.data,
    required this.selected,
    required this.onTap,
  });
  final _LanguageOptionData data;
  final bool selected;
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
                child: Icon(
                  Icons.language_outlined,
                  size: 22,
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nativeName,
                      style: AppTypography.body(
                        colors.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      data.englishName,
                      style: AppTypography.caption(colors.text2),
                    ),
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
