import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../models/book.dart';
import '../../providers/book_description_provider.dart';
import '../../widgets/book_cover.dart';
import 'detail_shared.dart';

/// Detail page for a book the user OWNS (library grid tap → here → reader).
/// Same reference layout as the catalog page — tinted scrolling header,
/// title/author left · cover right, KPI stats, Description — but the pinned
/// CTA reads/continues instead of buying. Description/rating/pages arrive
/// via the same on-demand enrichment the catalog page uses.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final extras = ref
        .watch(bookExtrasProvider((
          gutenbergId: null,
          googleId: book.googleId,
          title: book.title,
          author: book.author,
        )))
        .valueOrNull;
    final description = cleanHtml(extras?.description);
    final rating = extras?.rating;
    final pages = book.pageCount ?? extras?.pageCount;
    final year = book.publishedYear ?? extras?.year;
    final progress = (book.progressPct ?? 0).clamp(0.0, 100.0);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Tinted header — edge-to-edge behind the status bar, scrolls
                // away with the page (reference layout).
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadii.xl)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    MediaQuery.paddingOf(context).top + AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.chevron_left,
                            onTap: () => context.pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title1(colors.text),
                                ),
                                if (book.author != null &&
                                    book.author!.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    book.author!,
                                    style:
                                        AppTypography.subtitle(colors.text2),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          BookCover(
                            title: book.title,
                            author: book.author ?? '',
                            bg: coverColorFromHex(book.coverDominantColor),
                            fg: coverFgFor(book.coverDominantColor),
                            coverUrl: proxiedCoverUrl(book.coverUrl),
                            width: 110,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xxl,
                        runSpacing: AppSpacing.md,
                        children: [
                          StatChip(
                            icon: Icons.auto_stories_rounded,
                            tone: colors.accent,
                            value: '${progress.round()}%',
                            label: 'Progress',
                          ),
                          if (rating != null)
                            StatChip(
                              icon: Icons.star_rounded,
                              tone: colors.gilt,
                              value: rating.toStringAsFixed(1),
                              label: 'Rating',
                            ),
                          if (pages != null)
                            StatChip(
                              icon: Icons.menu_book_rounded,
                              tone: colors.text3,
                              value: '$pages',
                              label: 'Pages',
                            ),
                          if (year != null)
                            StatChip(
                              icon: Icons.calendar_month_rounded,
                              tone: colors.text3,
                              value: '$year',
                              label: 'Year',
                            ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Text('Description',
                            style: AppTypography.title3(colors.text)),
                        const SizedBox(height: AppSpacing.md),
                        Text(description,
                            style: AppTypography.bodySerif(colors.text2)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Pinned CTA: into the reader, resuming where they left off.
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.sm,
                AppSpacing.pageHorizontal,
                AppSpacing.md,
              ),
              child: FilledButton(
                onPressed: () =>
                    context.push(Routes.readingPath(book.id), extra: book),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.bg,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
                ),
                child: Text(
                  progress > 0
                      ? 'Continue reading — ${progress.round()}%'
                      : 'Start reading',
                  style: AppTypography.label(colors.bg)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
