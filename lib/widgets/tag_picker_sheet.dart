import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// The seven seeded tags, in the Figma's order. Each is also the highlight color.
const kTagNames = <String>[
  'urgent',
  'curious',
  'resonant',
  'beautiful',
  'reference',
  'disagree',
  'revisit',
];

/// "Tag this passage" sheet (Figma 291:2). Returns the chosen tag name (the
/// highlight's `colorTag`), or null if dismissed without choosing.
Future<String?> showTagPickerSheet(BuildContext context,
    {required String passage}) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    isScrollControlled: true,
    builder: (_) => _TagPickerSheet(passage: passage),
  );
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({required this.passage});
  final String passage;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Grabber(),
              Center(
                child:
                    Text('Tag this passage', style: AppTypography.title2(colors.text)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text('How does this make you feel?',
                    style: AppTypography.subtitle(colors.text2)),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PassageReference(passage: widget.passage),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final tag in kTagNames)
                    _TagChip(
                      tag: tag,
                      selected: _selected == tag,
                      onTap: () => setState(() => _selected = tag),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill chip: dot + label; filled with the tag color when selected.
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.selected,
    required this.onTap,
  });
  final String tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tagColor = AppColors.forTag(tag);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? tagColor : Colors.transparent,
          borderRadius: AppRadii.brFull,
          border: selected ? null : Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colors.bg : tagColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              tag,
              style: AppTypography.label(selected ? colors.bg : colors.text)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing the selected passage with an accent rule (shared with the note
/// sheet's reference styling).
class _PassageReference extends StatelessWidget {
  const _PassageReference({required this.passage});
  final String passage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: AppRadii.brXs,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                child: Text(
                  '“$passage”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle(colors.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.text3,
          borderRadius: AppRadii.brFull,
        ),
      ),
    );
  }
}
