import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
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
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
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
      if (_query.isEmpty) return true;
      final title = entry.value.title.toLowerCase();
      final indexStr = '${entry.key + 1}';
      final q = _query.toLowerCase();
      return title.contains(q) || indexStr == q;
    }).toList();

    return Container(
      height: size.height * 0.80,
      decoration: BoxDecoration(
        color: colors.surface,
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
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      '${widget.chapters.length} chapters',
                      style: AppTypography.caption(colors.text2).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val.trim()),
                  style: AppTypography.body(colors.text),
                  decoration: InputDecoration(
                    hintText: 'Search chapters…',
                    prefixIcon: Icon(Icons.search, size: 20, color: colors.text3),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: colors.text3),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: colors.surface2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: colors.border),
                    ),
                  ),
                ),
              ),
            ],

            const Divider(height: 1),

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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: filteredChapters.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: AppSpacing.pageHorizontal,
                        endIndent: AppSpacing.pageHorizontal,
                        color: colors.border.withValues(alpha: 0.5),
                      ),
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

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelectChapter(originalIndex);
                          },
                          child: Container(
                            color: isCurrent
                                ? colors.accent.withValues(alpha: 0.08)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                              vertical: AppSpacing.md,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Chapter Number
                                Container(
                                  width: 32,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    (originalIndex + 1).toString().padLeft(2, '0'),
                                    style: AppTypography.caption(
                                      isCurrent ? colors.accent : colors.text3,
                                    ).copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),

                                // Title & stats
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayTitle,
                                        style: AppTypography.bodySerif(
                                          isCurrent ? colors.accent : colors.text,
                                        ).copyWith(
                                          fontWeight: isCurrent
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (totalChars > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '$estMin min read · ${chapter.blocks.length} paragraphs',
                                          style: AppTypography.caption(
                                            colors.text3,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: colors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: colors.text3,
                                  ),
                              ],
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
