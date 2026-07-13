import 'dart:ui';

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
                _AmbientBookHeader(
                  book: book,
                  onBack: () => context.pop(),
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
              child: Builder(builder: (context) {
                // Audio intent = an audio file OR the Listening shelf —
                // catalog adds have format 'physical' (no file yet), so the
                // shelf is the only signal of how the user wants this book.
                final isAudio = book.status == 'listening' ||
                    book.format == 'm4b' ||
                    book.format == 'mp3';
                final verb = isAudio ? 'listening' : 'reading';
                return FilledButton(
                  onPressed: () => context.push(
                    isAudio
                        ? Routes.listeningPath(book.id)
                        : Routes.readingPath(book.id),
                    extra: book,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.bg,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                    shape:
                        RoundedRectangleBorder(borderRadius: AppRadii.brMd),
                  ),
                  child: Text(
                    progress > 0
                        ? 'Continue $verb — ${progress.round()}%'
                        : 'Start $verb',
                    style: AppTypography.label(colors.bg)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBookHeader extends StatelessWidget {
  const _AmbientBookHeader({required this.book, required this.onBack});

  final Book book;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final coverTone = coverColorFromHex(book.coverDominantColor);
    final fadedTone = Color.lerp(
      coverTone,
      colors.bg,
      isLight ? 0.68 : 0.58,
    )!;
    final coverUrl = proxiedCoverUrl(book.coverUrl);
    final radius = const BorderRadius.vertical(
      bottom: Radius.circular(AppRadii.xl),
    );

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: fadedTone)),
          if (coverUrl != null)
            Positioned.fill(
              child: Opacity(
                opacity: isLight ? 0.18 : 0.24,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Transform.scale(
                    scale: 1.35,
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fadedTone.withValues(alpha: isLight ? 0.56 : 0.46),
                    colors.bg.withValues(alpha: isLight ? 0.90 : 0.86),
                  ],
                ),
              ),
            ),
          ),
          Padding(
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
                      onTap: onBack,
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
                              style: AppTypography.subtitle(colors.text2),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    BookCover(
                      title: book.title,
                      author: book.author ?? '',
                      bg: coverTone,
                      fg: coverFgFor(book.coverDominantColor),
                      coverUrl: coverUrl,
                      width: 110,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
