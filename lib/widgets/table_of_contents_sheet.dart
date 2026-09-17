import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/widgets/app_text_field.dart';
import '../models/reader_package.dart';

/// Shows the Table of Contents modal sheet for in-book navigation.
Future<void> showTableOfContentsSheet({
  required BuildContext context,
  required String bookTitle,
  required List<ReaderChapter> chapters,
  int? currentChapterIndex,
  required ValueChanged<int> onSelectChapter,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (_) => TableOfContentsSheet(
      bookTitle: bookTitle,
      chapters: chapters,
      currentChapterIndex: currentChapterIndex,
      onSelectChapter: onSelectChapter,
    ),
  );
}

class TableOfContentsSheet extends StatefulWidget {
  const TableOfContentsSheet({
    super.key,
    required this.bookTitle,
    required this.chapters,
    this.currentChapterIndex,
    required this.onSelectChapter,
  });

  final String bookTitle;
  final List<ReaderChapter> chapters;
  final int? currentChapterIndex;
  final ValueChanged<int> onSelectChapter;

  @override
  State<TableOfContentsSheet> createState() => _TableOfContentsSheetState();
}

class _TableOfContentsSheetState extends State<TableOfContentsSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _hasSelected = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = MediaQuery.of(context).size;

    final filteredChapters = widget.chapters.asMap().entries.where((entry) {
      if (_query.trim().isEmpty) return true;
      final title = entry.value.title.toLowerCase();
      final indexStr = '${entry.key + 1}';
      final q = _query.toLowerCase().trim();
      final cleanQ = q.replaceAll(
        RegExp(r'^(chapter|ch|cha|sec|section)\s*'),
        '',
      );
      return title.contains(q) ||
          indexStr == q ||
          (cleanQ.isNotEmpty && indexStr == cleanQ);
    }).toList();

    return Container(
      height: size.height * 0.80,
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table of Contents',
                          style: AppTypography.title2(colors.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.bookTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(colors.text2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      '${widget.chapters.length} chapters',
                      style: AppTypography.caption(
                        colors.text2,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Optional Search bar if book has more than 5 chapters
            if (widget.chapters.length > 5) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                ),
                child: SizedBox(
                  height: 42,
                  child: AppTextField(
                    controller: _searchController,
                    hint: 'Search chapters...',
                    fillColor: colors.surface,
                    prefixIcon: Icons.search_rounded,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) => setState(() => _query = val.trim()),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xs),

            // Chapter List
            Expanded(
              child: filteredChapters.isEmpty
                  ? Center(
                      child: Text(
                        'No matching chapters found',
                        style: AppTypography.body(colors.text3),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal,
                        AppSpacing.xs,
                        AppSpacing.pageHorizontal,
                        AppSpacing.xl,
                      ),
                      itemCount: filteredChapters.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, idx) {
                        final entry = filteredChapters[idx];
                        final originalIndex = entry.key;
                        final chapter = entry.value;
                        final isCurrent =
                            widget.currentChapterIndex == originalIndex;

                        // Estimate reading time (~200 words / min, 5 chars / word)
                        final totalChars = chapter.blocks.fold<int>(
                          0,
                          (sum, b) => sum + b.text.length,
                        );
                        final estMin = (totalChars / 1000).ceil().clamp(1, 120);

                        final displayTitle = chapter.title.trim().isNotEmpty
                            ? chapter.title.trim()
                            : 'Chapter ${originalIndex + 1}';

                        return Container(
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? colors.accent.withValues(alpha: 0.08)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(
                              color: isCurrent
                                  ? colors.accent.withValues(alpha: 0.5)
                                  : colors.border,
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              onTap: () {
                                if (_hasSelected) return;
                                _hasSelected = true;
                                Navigator.of(context).pop();
                                widget.onSelectChapter(originalIndex);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Chapter Number
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        (originalIndex + 1).toString().padLeft(
                                          2,
                                          '0',
                                        ),
                                        style: AppTypography.serif(
                                          TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrent
                                                ? colors.accent
                                                : colors.text3,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),

                                    // Title & stats
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayTitle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.serif(
                                              TextStyle(
                                                fontSize: 15.5,
                                                height: 1.25,
                                                fontWeight: isCurrent
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: isCurrent
                                                    ? colors.accent
                                                    : colors.text,
                                              ),
                                            ),
                                          ),
                                          if (totalChars > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '$estMin min read • ${chapter.blocks.length} paragraphs',
                                              style: AppTypography.caption(
                                                colors.text3,
                                              ).copyWith(fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),

                                    if (isCurrent)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colors.accent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20,
                                        color: colors.text3,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
