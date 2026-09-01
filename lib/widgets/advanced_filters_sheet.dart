import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/widgets/app_text_field.dart';

class AdvancedFilterValues {
  const AdvancedFilterValues({
    required this.title,
    required this.author,
    required this.subject,
    required this.isbn,
    required this.freeOnly,
  });

  final String title;
  final String author;
  final String subject;
  final String isbn;
  final bool freeOnly;
}

/// Presents the "Advanced Filters" modal bottom sheet.
Future<AdvancedFilterValues?> showAdvancedFiltersSheet(
  BuildContext context, {
  required String initialTitle,
  required String initialAuthor,
  required String initialSubject,
  required String initialIsbn,
  required bool initialFreeOnly,
}) {
  return showModalBottomSheet<AdvancedFilterValues>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AdvancedFiltersSheet(
      initialTitle: initialTitle,
      initialAuthor: initialAuthor,
      initialSubject: initialSubject,
      initialIsbn: initialIsbn,
      initialFreeOnly: initialFreeOnly,
    ),
  );
}

class AdvancedFiltersSheet extends StatefulWidget {
  const AdvancedFiltersSheet({
    super.key,
    required this.initialTitle,
    required this.initialAuthor,
    required this.initialSubject,
    required this.initialIsbn,
    required this.initialFreeOnly,
  });

  final String initialTitle;
  final String initialAuthor;
  final String initialSubject;
  final String initialIsbn;
  final bool initialFreeOnly;

  @override
  State<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<AdvancedFiltersSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late String _selectedSubject;
  late bool _freeOnly;

  static const _categories = [
    (label: 'Classics', icon: Icons.account_balance_outlined),
    (label: 'Fiction', icon: Icons.menu_book_outlined),
    (label: 'Philosophy', icon: Icons.psychology_outlined),
    (label: 'History', icon: Icons.hourglass_bottom_outlined),
    (label: 'Biography', icon: Icons.person_outline),
    (label: 'Self Help', icon: Icons.eco_outlined),
    (label: 'Poetry', icon: Icons.auto_stories_outlined),
    (label: 'Business', icon: Icons.business_center_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _authorController = TextEditingController(text: widget.initialAuthor);
    _isbnController = TextEditingController(text: widget.initialIsbn);
    _selectedSubject = widget.initialSubject;
    _freeOnly = widget.initialFreeOnly;

    _titleController.addListener(() => setState(() {}));
    _authorController.addListener(() => setState(() {}));
    _isbnController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  int get _count {
    var c = 0;
    if (_titleController.text.trim().isNotEmpty) c++;
    if (_authorController.text.trim().isNotEmpty) c++;
    if (_selectedSubject.trim().isNotEmpty) c++;
    if (_isbnController.text.trim().isNotEmpty) c++;
    if (_freeOnly) c++;
    return c;
  }

  void _reset() {
    setState(() {
      _titleController.clear();
      _authorController.clear();
      _isbnController.clear();
      _selectedSubject = '';
      _freeOnly = false;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      AdvancedFilterValues(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        subject: _selectedSubject.trim(),
        isbn: _isbnController.text.trim(),
        freeOnly: _freeOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
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
                      top: AppSpacing.sm,
                      bottom: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: AppRadii.brFull,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Advanced Filters',
                      style: AppTypography.title2(colors.text),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colors.text3, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'GENRE & SUBJECT',
                  style: AppTypography.overline(colors.text3),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _categories.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        _CategoryTagChip(
                          label: _categories[i].label,
                          icon: _categories[i].icon,
                          selected: _selectedSubject.toLowerCase() ==
                              _categories[i].label.toLowerCase(),
                          onTap: () {
                            setState(() {
                              if (_selectedSubject.toLowerCase() ==
                                  _categories[i].label.toLowerCase()) {
                                _selectedSubject = '';
                              } else {
                                _selectedSubject = _categories[i].label;
                              }
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'SPECIFIC SEARCH',
                  style: AppTypography.overline(colors.text3),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _titleController,
                  hint: 'Title',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _authorController,
                  hint: 'Author',
                  suffix: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: colors.text3,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _isbnController,
                  hint: 'ISBN',
                  keyboardType: TextInputType.number,
                  suffix: Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 18,
                    color: colors.text3,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _apply(),
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: () => setState(() => _freeOnly = !_freeOnly),
                  borderRadius: AppRadii.brMd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Free to read in Marginalia only',
                          style: AppTypography.label(colors.text),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          alignment: Alignment.centerRight,
                          child: Switch.adaptive(
                            value: _freeOnly,
                            onChanged: (val) => setState(() => _freeOnly = val),
                            activeTrackColor: colors.accent,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.brFull,
                          ),
                          side: BorderSide(color: colors.border),
                        ),
                        child: Text(
                          'Reset All',
                          style: AppTypography.label(colors.text2),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: FilledButton(
                        onPressed: _apply,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.accent,
                          foregroundColor: colors.bg,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.brFull,
                          ),
                        ),
                        child: Text(
                          _count > 0 ? 'Apply Filters ($_count)' : 'Apply Filters',
                          style: AppTypography.label(colors.bg).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

class _CategoryTagChip extends StatelessWidget {
  const _CategoryTagChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.text : colors.surface,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brMd,
            border: Border.all(
              color: selected ? colors.text : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? colors.bg : colors.text2,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption(
                  selected ? colors.bg : colors.text,
                ).copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
