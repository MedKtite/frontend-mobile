import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../models/catalog_book.dart';
import '../../providers/author_provider.dart';
import '../../widgets/author_avatar.dart';
import '../../widgets/book_cover.dart';
import 'detail_shared.dart';

/// Author profile: portrait + name + tagline on the tinted header, Wikipedia
/// bio, and their (readable, public-domain) books. Tapping a book opens the
/// catalog book page — same funnel as Trending.
class AuthorDetailsScreen extends ConsumerWidget {
  const AuthorDetailsScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final details = ref.watch(authorDetailsProvider(name));

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Tinted header — edge-to-edge behind the status bar, scrolls away.
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
                const SizedBox(height: AppSpacing.lg),
                AuthorAvatar(
                  name: name,
                  imageUrl: details.valueOrNull?.imageUrl,
                  size: 96,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: AppTypography.title1(colors.text),
                ),
                if ((details.valueOrNull?.tagline ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    details.valueOrNull!.tagline!,
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitle(colors.text2),
                  ),
                ],
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
            child: details.when(
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Center(
                    child: CircularProgressIndicator(color: colors.accent)),
              ),
              error: (_, __) => Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(Icons.cloud_off_outlined,
                      size: 40, color: colors.text3),
                  const SizedBox(height: AppSpacing.lg),
                  Text("Couldn't load this author.",
                      style: AppTypography.title3(colors.text)),
                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(authorDetailsProvider(name)),
                    child: const Text('Try again'),
                  ),
                ],
              ),
              data: (d) {
                final readable = d.books.where((b) => b.isReadable).length;
                final readers = d.books.fold<int>(
                    0, (sum, b) => sum + (b.downloadCount ?? 0));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // KPI row — same visual language as the book pages.
                    Wrap(
                      spacing: AppSpacing.xxl,
                      runSpacing: AppSpacing.md,
                      children: [
                        if (d.books.isNotEmpty)
                          StatChip(
                            icon: Icons.menu_book_rounded,
                            tone: colors.accent,
                            value: '${d.books.length}',
                            label: 'Books',
                          ),
                        if (readable > 0)
                          StatChip(
                            icon: Icons.lock_open_rounded,
                            tone: colors.gilt,
                            value: '$readable',
                            label: 'Free to read',
                          ),
                        if (readers > 0)
                          StatChip(
                            icon: Icons.auto_stories_rounded,
                            tone: colors.text3,
                            value: compactCount(readers),
                            label: 'Readers',
                          ),
                      ],
                    ),
                    if (d.books.isNotEmpty)
                      const SizedBox(height: AppSpacing.xl),
                    if ((d.bio ?? '').isNotEmpty) ...[
                      Text('About', style: AppTypography.title3(colors.text)),
                      const SizedBox(height: AppSpacing.md),
                      Text(d.bio!,
                          style: AppTypography.bodySerif(colors.text2)),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (d.books.isNotEmpty) ...[
                      Text('Books', style: AppTypography.title3(colors.text)),
                      const SizedBox(height: AppSpacing.md),
                      _AuthorBooksGrid(books: d.books),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl),
                        child: Center(
                          child: Text(
                            (d.bio ?? '').isEmpty
                                ? 'Nothing on file for this author yet.'
                                : 'No books found in the catalog for this author.',
                            textAlign: TextAlign.center,
                            style: AppTypography.subtitle(colors.text2),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 3-column cover grid, same cell language as the library/catalog grids.
class _AuthorBooksGrid extends StatelessWidget {
  const _AuthorBooksGrid({required this.books});

  final List<CatalogBook> books;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const gap = AppSpacing.md;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = (constraints.maxWidth - 2 * gap) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.lg,
          children: [
            for (final b in books)
              SizedBox(
                width: cellW,
                child: GestureDetector(
                  onTap: () => context.push(Routes.catalogBook, extra: b),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookCover(
                        title: b.title,
                        author: b.author ?? '',
                        bg: colors.surface2,
                        fg: colors.text2,
                        coverUrl: proxiedCoverUrl(b.thumbnailUrl),
                        width: cellW,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        b.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(colors.text),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
