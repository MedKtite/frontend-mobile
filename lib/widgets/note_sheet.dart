import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// "Add a note" sheet (Figma 290:2). Returns the note text on save, or null on
Future<String?> showNoteSheet(
  BuildContext context, {
  required String passage,
  required String reference,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    isScrollControlled: true,
    builder: (_) => _NoteSheet(passage: passage, reference: reference),
  );
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.passage, required this.reference});
  final String passage;
  final String reference;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      // Lift above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
                  child: Text('Add a note',
                      style: AppTypography.title2(colors.text)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Text('to your highlight',
                      style: AppTypography.subtitle(colors.text2)),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Reference(reference: widget.reference, passage: widget.passage),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: colors.accent, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 10000,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTypography.subtitle(colors.text),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      border: InputBorder.none,
                      hintText: 'What did this mean to you?',
                      hintStyle: AppTypography.subtitle(colors.text3),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel',
                          style: AppTypography.label(colors.text2)),
                    ),
                    SizedBox(
                      width: 152,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save note'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Reference extends StatelessWidget {
  const _Reference({required this.reference, required this.passage});
  final String reference;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(reference, style: AppTypography.overline(colors.text3)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '“$passage”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subtitle(colors.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
