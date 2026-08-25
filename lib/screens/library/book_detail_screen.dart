import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/book.dart';
import '../../models/book_update_request.dart';
import '../../models/highlight.dart';
import '../../providers/book_description_provider.dart';
import '../../providers/book_file_provider.dart';
import '../../providers/book_highlights_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/library_provider.dart';
import '../../services/backend/book_service.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/delete_book_dialog.dart';
import 'detail_shared.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _toggleMode(BuildContext context, WidgetRef ref, Book book) async {
    final isAudio = book.status == 'listening' ||
        book.format == 'm4b' ||
        book.format == 'mp3';
    final targetStatus = isAudio ? 'reading' : 'listening';
    final targetLabel = isAudio ? 'reading' : 'listening';
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    try {
      await ref.read(bookServiceProvider).update(
            book.id,
            BookUpdateRequest(status: targetStatus),
          );
      ref.invalidate(bookByIdProvider(book.id));
      ref.invalidate(libraryBooksProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        appSnackBar('Switched to $targetLabel mode', SnackType.success),
      );
    } on ApiError catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(appSnackBar(e.message, SnackType.error));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteBookDialog(title: book.title),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    try {
      await ref.read(bookServiceProvider).delete(book.id);
      await deleteCachedBookFiles(book.id);
      ref.invalidate(libraryBooksProvider);
      if (!context.mounted) return;
      context.pop();
      messenger.showSnackBar(
        appSnackBar('Deleted “${book.title}”', SnackType.success),
      );
    } on ApiError catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(appSnackBar(e.message, SnackType.error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final bookAsync = ref.watch(bookByIdProvider(book.id));
    if (bookAsync.isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: AppProgressLoading(),
        ),
      );
    }

    final latestBook = bookAsync.valueOrNull;
    final displayBook = latestBook ?? book;

    if (displayBook.processingStatus == 'pending' ||
        displayBook.processingStatus == 'processing') {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppProgressBar(height: 4),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Preparing your book…',
                      style: AppTypography.title3(colors.text)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We are extracting the text, cover, and available details.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySerif(colors.text2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final extrasKey = (
      gutenbergId: displayBook.gutenbergId,
      googleId: displayBook.googleId,
      title: displayBook.title,
      author: displayBook.author,
    );
    final extrasAsync = ref.watch(bookExtrasProvider(extrasKey));
    if (extrasAsync.isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: AppProgressLoading(),
        ),
      );
    }

    final extras = extrasAsync.valueOrNull;
    final description = cleanHtml(displayBook.description ?? extras?.description);
    final rating = extras?.rating;
    final pages = displayBook.pageCount ?? extras?.pageCount;
    final year = displayBook.publishedYear ?? extras?.year;
    final progress = (displayBook.progressPct ?? 0).clamp(0.0, 100.0);
    final isPhysical = displayBook.format == 'physical';

    final highlightsAsync = ref.watch(bookHighlightsProvider(displayBook.id));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AmbientBookHeader(
                  book: displayBook,
                  onBack: () => context.pop(),
                  onDelete: () => _delete(context, ref),
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
                          if (!isPhysical)
                            StatChip(
                              icon: Icons.auto_stories_rounded,
                              tone: colors.accent,
                              value: '${progress.round()}%',
                              label: 'Progress',
                            )
                          else
                            StatChip(
                              icon: Icons.bookmark_added_rounded,
                              tone: colors.accent,
                              value: 'Paper',
                              label: 'Format',
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

                      // Marginalia & Highlights Section (shown only when highlights exist)
                      highlightsAsync.when(
                        data: (highlights) {
                          if (highlights.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                'Marginalia & Highlights',
                                style: AppTypography.title3(colors.text),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...highlights.map((h) {
                                return _HighlightDetailCard(highlight: h);
                              }),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Pinned CTA — Primary reading/listening action + Mode switch
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
                final isAudio = displayBook.status == 'listening' ||
                    displayBook.format == 'm4b' ||
                    displayBook.format == 'mp3';
                final verb = isAudio ? 'listening' : 'reading';
                return Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.push(
                          isAudio
                              ? Routes.listeningPath(displayBook.id)
                              : Routes.readingPath(displayBook.id),
                          extra: displayBook,
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
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.outlined(
                      onPressed: () => _toggleMode(context, ref, displayBook),
                      tooltip: isAudio ? 'Switch to reading' : 'Switch to listening',
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.text,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
                      ),
                      icon: Icon(
                        isAudio ? Icons.auto_stories_rounded : Icons.headphones_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightDetailCard extends StatelessWidget {
  const _HighlightDetailCard({required this.highlight});

  final Highlight highlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tag = highlight.colorTag ?? 'revisit';
    final tagColor = AppColors.forTag(tag);
    final text = highlight.passageText ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border(
          left: BorderSide(color: tagColor, width: 3.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tag.toUpperCase(),
                style: AppTypography.caption(tagColor).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              if (highlight.textChapterRef != null)
                Text(
                  highlight.textChapterRef!,
                  style: AppTypography.caption(colors.text3),
                ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '“$text”',
              style: AppTypography.bodySerif(colors.text).copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmbientBookHeader extends StatelessWidget {
  const _AmbientBookHeader({
    required this.book,
    required this.onBack,
    required this.onDelete,
  });

  final Book book;
  final VoidCallback onBack;
  final VoidCallback onDelete;

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
                    const Spacer(),
                    CircleIconButton(
                      icon: Icons.delete_outline,
                      onTap: onDelete,
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
                            style: AppTypography.body(colors.text)
                                .copyWith(fontWeight: FontWeight.w700),
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
