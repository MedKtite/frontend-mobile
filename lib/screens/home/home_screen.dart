import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/book.dart';
import '../../models/catalog_book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/author_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/state/home_state.dart';
import '../../providers/trending_provider.dart';
import '../../widgets/add_to_library_sheet.dart';
import '../../widgets/author_avatar.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/glass_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _comingSoon(BuildContext context, String what) =>
      showAppSnack(context, '$what — coming soon');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(homeProvider);

    // Identity comes from the authenticated user (fetched from the backend by
    // the auth flow); fall back gracefully when not signed in.
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final name =
        user?.shortName ?? user?.displayName.split(' ').first ?? 'reader';
    final initial =
        user?.avatarInitial ?? (name.isEmpty ? '?' : name[0].toUpperCase());

    // Nav bar lives in AppShell (persistent across tabs) — not here.
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (state) {
          HomeLoading() =>
            Center(child: CircularProgressIndicator(color: colors.accent)),
          HomeEmpty() => _EmptyHome(
              onAdd: () => showAddToLibrarySheet(context),
            ),
          HomeLoaded(
            :final continueReading,
            :final passage,
            :final listening,
          ) =>
            _PopulatedHome(
              greetingName: name,
              avatarInitial: initial,
              continueReading: continueReading,
              passage: passage,
              listening: listening,
              onResume: () {
                final cr = continueReading;
                if (cr != null) context.push(Routes.readingPath(cr.id));
              },
              onPlay: () => _comingSoon(context, 'Audio player'),
            ),
          HomeError(:final message) => _ErrorState(
              message: message,
              onRetry: () => ref.read(homeProvider.notifier).load(),
            ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Empty state ──

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onAdd});

  final VoidCallback onAdd;

  static const _formats = ['EPUB', 'PDF', 'M4B', 'MP3'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(104, 70),
              painter: _OpenBookPainter(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Your library begins here.',
              textAlign: TextAlign.center,
              style: AppTypography.title1(colors.text),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a book, ebook, or audiobook\nto get started',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add your first book'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: [for (final f in _formats) _FormatChip(label: f)],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadii.brFull,
      ),
      child: Text(
        label,
        style: AppTypography.caption(colors.text3).copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// Two-page open-book line drawing for the empty state.
class _OpenBookPainter extends CustomPainter {
  const _OpenBookPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color;

    const gap = 8.0;
    final pageW = (size.width - gap) / 2;
    for (final left in [0.0, pageW + gap]) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          left, 0, left + pageW, size.height, const Radius.circular(3),
        ),
        paint,
      );
      const inset = 9.0;
      for (var i = 1; i <= 4; i++) {
        final y = size.height * i / 5;
        canvas.drawLine(
          Offset(left + inset, y), Offset(left + pageW - inset, y), paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_OpenBookPainter old) => old.color != color;
}

// ──────────────────────────────────────────────────────────── Error state ──

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colors.text3),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Couldn't load your library.",
              textAlign: TextAlign.center,
              style: AppTypography.title3(colors.text),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.caption(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Populated state ──

const double _navClearance = 96; // scroll past the glass nav bar

class _PopulatedHome extends StatelessWidget {
  const _PopulatedHome({
    required this.greetingName,
    required this.avatarInitial,
    required this.continueReading,
    required this.passage,
    required this.listening,
    required this.onResume,
    required this.onPlay,
  });

  final String greetingName;
  final String avatarInitial;
  final ContinueReading? continueReading;
  final HomePassage? passage;
  final ListeningItem? listening;
  final VoidCallback onResume;
  final VoidCallback onPlay;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        _navClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(avatarInitial: avatarInitial),
          const SizedBox(height: AppSpacing.xl),
          Text.rich(
            TextSpan(
              style: AppTypography.display(colors.text),
              children: [
                TextSpan(text: '$_greeting\n'),
                TextSpan(
                  text: '$greetingName.',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Settle in. The page is still warm.',
            style: AppTypography.subtitle(colors.text2),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _TrendingSection(),
          if (continueReading != null) ...[
            _ContinueReadingCard(book: continueReading!, onResume: onResume),
            const SizedBox(height: AppSpacing.xxl),
          ],
          _ContinueRow(excludeId: continueReading?.id),
          const _TopAuthorsSection(),
          const _RecommendedSection(),
          if (passage != null) ...[
            _SectionLabel('PASSAGE OF THE DAY'),
            const SizedBox(height: AppSpacing.lg), // Figma 266:2: 16 to quote
            _PassageBlock(passage: passage!),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (listening != null) ...[
            _SectionLabel('STILL LISTENING TO'),
            const SizedBox(height: AppSpacing.md),
            _ListeningCard(item: listening!, onPlay: onPlay),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.avatarInitial});

  final String avatarInitial;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final now = DateTime.now();
    final date =
        '${DateFormat('EEE').format(now)} · ${DateFormat('MMM d').format(now)}'
            .toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('MARGINALIA', style: AppTypography.overline(colors.text3)),
        Row(
          children: [
            Text(date, style: AppTypography.label(colors.text2)),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Text(
                avatarInitial,
                style: AppTypography.serif(TextStyle(
                  color: colors.text2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.overline(context.appColors.text3));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = AppSpacing.lg});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ────────────────────────────────────────────────── Continue-reading row ──

/// Horizontal carousel of the OTHER in-progress books (the hero card above
/// already features the most recent one): small cover · title · author ·
/// progress bar + %. Hidden while loading, on error, or when there's nothing
/// beyond the hero — never a broken block.
class _ContinueRow extends ConsumerWidget {
  const _ContinueRow({this.excludeId});

  final String? excludeId;

  static const double _cardW = 272;
  static const double _rowH = 92;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(libraryBooksProvider).valueOrNull;
    if (books == null) return const SizedBox.shrink();

    final reading = [
      for (final b in books)
        if (b.status == 'reading' && b.id != excludeId) b,
    ]..sort((a, b) => (b.lastOpenedAt ?? b.updatedAt ?? '')
        .compareTo(a.lastOpenedAt ?? a.updatedAt ?? ''));
    if (reading.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('CONTINUE READING'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: _rowH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reading.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => _ContinueRowCard(book: reading[i]),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ContinueRowCard extends StatelessWidget {
  const _ContinueRowCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pct = (book.progressPct ?? 0).clamp(0.0, 100.0);

    return GestureDetector(
      onTap: () => context.push(Routes.readingPath(book.id), extra: book),
      child: SizedBox(
        width: _ContinueRow._cardW,
        child: GlassPanel(
          radius: AppRadii.lg,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              BookCover(
                title: book.title,
                author: book.author ?? '',
                bg: coverColorFromHex(book.coverDominantColor),
                fg: coverFgFor(book.coverDominantColor),
                coverUrl: proxiedCoverUrl(book.coverUrl),
                width: 40,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title3(colors.text),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      book.author ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(colors.text2),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: AppRadii.brFull,
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              minHeight: 4,
                              backgroundColor: colors.border,
                              color: colors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${pct.round()}%',
                            style: AppTypography.caption(colors.text3)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────── Trending section ──

/// "Trending now" — Gutenberg's most-downloaded titles, every one readable
/// free in-app. Tap → the catalog book page (Add to library — read free).
/// Loading shows cover-shaped placeholders; an error hides the section
/// entirely (trending is a bonus, never a blocker).
class _TrendingSection extends ConsumerWidget {
  const _TrendingSection();

  static const double _coverW = 96;
  static const double _rowH = 196; // cover 144 + gaps + two text lines

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingBooksProvider);

    final row = trending.when(
      error: (_, __) => null,
      loading: () => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, _) => _CoverPlaceholder(width: _coverW),
      ),
      data: (books) => books.isEmpty
          ? null
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) => _TrendingCell(book: books[i]),
            ),
    );
    if (row == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('TRENDING NOW'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(height: _rowH, child: row),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// "Top authors" — the most-downloaded Gutenberg authors, with Wikipedia
/// portraits. Tap → the author profile (bio + their books). Hidden while
/// loading / on error — a bonus row, never a broken block.
class _TopAuthorsSection extends ConsumerWidget {
  const _TopAuthorsSection();

  static const double _avatar = 64;
  static const double _cellW = 76;
  static const double _rowH = 104; // avatar + gap + one name line

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authors = ref.watch(topAuthorsProvider).valueOrNull;
    if (authors == null || authors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('TOP AUTHORS'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: _rowH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: authors.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) {
              final a = authors[i];
              return GestureDetector(
                onTap: () => context.push(Routes.author, extra: a.name),
                child: SizedBox(
                  width: _cellW,
                  child: Column(
                    children: [
                      AuthorAvatar(
                          name: a.name, imageUrl: a.imageUrl, size: _avatar),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(
                            context.appColors.text2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// "Recommended for you" — driven by the user's own catalog searches (the
/// backend re-runs recent keywords against Google Books). Same cells as
/// Trending; hidden until there's history to recommend from.
class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(recommendedBooksProvider).valueOrNull;
    if (books == null || books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('RECOMMENDED FOR YOU'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: _TrendingSection._rowH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => _TrendingCell(book: books[i]),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _TrendingCell extends StatelessWidget {
  const _TrendingCell({required this.book});

  final CatalogBook book;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => context.push(Routes.catalogBook, extra: book),
      child: SizedBox(
        width: _TrendingSection._coverW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              title: book.title,
              author: book.author ?? '',
              bg: colors.surface2,
              fg: colors.text2,
              coverUrl: proxiedCoverUrl(book.thumbnailUrl),
              width: _TrendingSection._coverW,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(colors.text),
            ),
            if (book.author != null && book.author!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                book.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(colors.text2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Cover-shaped shimmerless placeholder while trending loads.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: width,
      height: width * 1.5,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadii.brSm,
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.book, required this.onResume});

  final ContinueReading book;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GlassPanel(
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            title: book.title,
            author: book.author,
            bg: book.coverBg,
            fg: book.coverFg,
            width: 84,
            bookmarked: true,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('CONTINUE READING',
                    style: AppTypography.overline(colors.text3)),
                const SizedBox(height: AppSpacing.xs),
                Text(book.title, style: AppTypography.title2(colors.text)),
                Text(book.author, style: AppTypography.subtitle(colors.text2)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadii.brFull,
                        child: LinearProgressIndicator(
                          value: (book.progress / 100).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: colors.border,
                          color: colors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('${book.progress.round()}%',
                        style: AppTypography.label(colors.text2)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: onResume,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Resume'),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(Icons.arrow_forward, size: 16, color: colors.bg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Passage of the day (Figma 266:2 · nodes 273:137-139): tag-colored marginal
/// dot hanging into the page margin, the quote in Source Serif 4 italic 17/1.4
/// with a wavy gilt highlight underline, and an italic-serif source line.
class _PassageBlock extends StatelessWidget {
  const _PassageBlock({required this.passage});

  final HomePassage passage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marginal dot — Figma hangs it 8px INTO the left margin (dot x=24 vs
        // text margin x=32): annotations live in the margins, per the brand.
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Transform.translate(
            offset: const Offset(-8, 0),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.forTag(passage.colorTag),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Figma 273:138 — serif italic 17/1.4; the wavy underline marks
              // the highlight (whole quote here: the passage IS the highlight,
              // there's no sub-fragment in the data to scope it to).
              Text(
                passage.text,
                style: AppTypography.serif(TextStyle(
                  color: colors.text,
                  fontSize: 17,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.wavy,
                  decorationColor: colors.gilt,
                  decorationThickness: 1,
                )),
              ),
              if (passage.source.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md), // Figma: 12 to source
                // Figma 273:139 — serif italic 12, muted ink.
                Text(
                  passage.source,
                  style: AppTypography.serif(TextStyle(
                    color: colors.text3,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  )),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ListeningCard extends StatelessWidget {
  const _ListeningCard({required this.item, required this.onPlay});

  final ListeningItem item;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _Card(
      padding: AppSpacing.md,
      child: Row(
        children: [
          BookCover(
            title: item.title,
            author: item.author,
            bg: item.coverBg,
            fg: item.coverFg,
            width: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title3(colors.text),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(colors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Material(
            color: colors.text,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPlay,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.play_arrow, size: 24, color: colors.bg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
