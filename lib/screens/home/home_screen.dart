import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../models/book.dart';
import '../../models/catalog_book.dart';
import '../../models/insights_response.dart';
import '../../providers/auth_provider.dart';
import '../../providers/author_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/insights_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/state/home_state.dart';
import '../../providers/trending_provider.dart';
import '../../widgets/author_avatar.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/glass_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(homeProvider);

    // Warm independent sections while the primary Home request is in flight.
    // Their widgets can then render cached/completed values as soon as the
    // populated layout appears instead of starting each request afterward.
    ref.watch(trendingBooksProvider);
    ref.watch(topAuthorsProvider);
    ref.watch(recommendedBooksProvider);

    // Identity comes from the authenticated user (fetched from the backend by
    // the auth flow); fall back gracefully when not signed in.
    final auth = ref.watch(authProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;
    final name =
        user?.shortName ?? user?.displayName.split(' ').first ?? 'reader';
    final initial =
        user?.avatarInitial ?? (name.isEmpty ? '?' : name[0].toUpperCase());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Nav bar lives in AppShell (persistent across tabs) — not here.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: switch (state) {
          HomeLoading() => SafeArea(
            bottom: false,
            child: Center(
              child: CircularProgressIndicator(color: colors.accent),
            ),
          ),
          HomeEmpty() => _PopulatedHome(
            greetingName: name,
            avatarInitial: initial,
            continueReading: null,
            passage: null,
            listening: null,
            onResume: () {},
            onPlay: () {},
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
              onPlay: () {
                final l = listening;
                if (l != null) context.push(Routes.listeningPath(l.id));
              },
            ),
          HomeError(:final message) => SafeArea(
            bottom: false,
            child: _ErrorState(
              message: message,
              onRetry: () => ref.read(homeProvider.notifier).load(),
            ),
          ),
        },
      ),
    );
  }
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: _navClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HomeHero(greetingName: greetingName, avatarInitial: avatarInitial),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                const _TrendingSection(),
                const _CategorySection(),
                if (continueReading != null) ...[
                  _ContinueReadingCard(
                    book: continueReading!,
                    onResume: onResume,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
                _ContinueRow(excludeId: continueReading?.id),
                const _TopAuthorsSection(),
                const _RecommendedSection(),
                if (passage != null) ...[
                  _SectionLabel('PASSAGE OF THE DAY'),
                  const SizedBox(height: AppSpacing.lg),
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
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends ConsumerWidget {
  const _HomeHero({required this.greetingName, required this.avatarInitial});

  final String greetingName;
  final String avatarInitial;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final now = DateTime.now();
    final date =
        '${DateFormat('EEE').format(now)} · ${DateFormat('MMM d').format(now)}'
            .toUpperCase();
    final summary = ref.watch(insightsProvider).valueOrNull?.summary;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'lib/assets/images/header_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topRight,
          ),
        ),
        Positioned.fill(
          child: ColoredBox(
            color: colors.bg.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.52
                  : 0.06,
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  colors.surface,
                  colors.surface.withValues(alpha: 0.94),
                  colors.surface.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: AppSpacing.xxl,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.bg.withValues(alpha: 0), colors.bg],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            MediaQuery.paddingOf(context).top + AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(date, style: AppTypography.overline(colors.text2)),
                  const SizedBox(width: AppSpacing.md),
                  _HeroAction(
                    onTap: () => context.push(Routes.settings),
                    child: Text(
                      avatarInitial,
                      style: AppTypography.label(
                        colors.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeroAction(
                    onTap: () => context.push(Routes.notifications),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: AppSpacing.xl,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _greeting,
                style: AppTypography.title3(
                  colors.text,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              Text.rich(
                TextSpan(
                  style: AppTypography.display(
                    colors.text,
                  ).copyWith(fontStyle: FontStyle.italic),
                  children: [
                    TextSpan(text: greetingName),
                    TextSpan(
                      text: '.',
                      style: AppTypography.display(
                        colors.gilt,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.tabletSidebarExpanded,
                ),
                child: Text(
                  'Welcome to your reading journey.\n'
                  "Let's discover something great today.",
                  style: AppTypography.caption(
                    colors.text2,
                  ).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
              if (summary != null &&
                  (summary.booksReadThisYear > 0 ||
                      summary.minutesReadThisWeek > 0 ||
                      summary.currentStreakDays > 0 ||
                      summary.highlightsCount > 0)) ...[
                const SizedBox(height: AppSpacing.xl),
                _HeroStats(summary: summary),
              ],
              // _pubCard(),
            ],
          ),
        ),
      ],
    );
  }
}



class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface.withValues(alpha: 0.7),
      shape: CircleBorder(side: BorderSide(color: colors.border)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: AppSpacing.xxl + AppSpacing.sm,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.summary});

  final InsightsSummary? summary;

  String get _readingTime {
    final minutes = summary?.minutesReadThisWeek;
    if (minutes == null) return '—';
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stats = [
      (
        icon: Icons.menu_book_outlined,
        value: '${summary?.booksReadThisYear ?? '—'}',
        label: 'Books\nRead',
      ),
      (
        icon: Icons.schedule_outlined,
        value: _readingTime,
        label: 'Reading\nTime',
      ),
      (
        icon: Icons.local_fire_department_outlined,
        value: '${summary?.currentStreakDays ?? '—'}',
        label: 'Day\nStreak',
      ),
      (
        icon: Icons.bookmark_border,
        value: '${summary?.highlightsCount ?? '—'}',
        label: 'Quotes\nSaved',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        borderRadius: AppRadii.brLg,
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.text.withValues(alpha: 0.06),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var index = 0; index < stats.length; index++) ...[
              Expanded(child: _HeroStatCell(stat: stats[index])),
              if (index != stats.length - 1)
                VerticalDivider(color: colors.border, width: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroStatCell extends StatelessWidget {
  const _HeroStatCell({required this.stat});

  final ({IconData icon, String value, String label}) stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stat.icon, size: AppSpacing.xl, color: colors.gilt),
        const SizedBox(height: AppSpacing.sm),
        Text(stat.value, style: AppTypography.title3(colors.text)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: AppTypography.caption(colors.text2),
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

    final reading =
        [
          for (final b in books)
            if (b.status == 'reading' && b.id != excludeId) b,
        ]..sort(
          (a, b) => (b.lastOpenedAt ?? b.updatedAt ?? '').compareTo(
            a.lastOpenedAt ?? a.updatedAt ?? '',
          ),
        );
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
                        Text(
                          '${pct.round()}%',
                          style: AppTypography.caption(colors.text3),
                        ),
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
/// Loading shows cover-shaped placeholders. Empty and error states stay visible
/// so a transient request never makes the section jump out of the page.
class _TrendingSection extends ConsumerWidget {
  const _TrendingSection();

  static const double _coverW = BookCard.cardWidth;
  static const double _rowH = 196; // cover 144 + gaps + two text lines

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingBooksProvider);

    final books = trending.valueOrNull;
    final Widget content;
    if (books != null && books.isNotEmpty) {
      content = SizedBox(
        height: _rowH,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, i) => _TrendingCell(book: books[i]),
        ),
      );
    } else if (trending.isLoading) {
      content = SizedBox(
        height: _rowH,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, _) => _CoverPlaceholder(width: _coverW),
        ),
      );
    } else if (trending.hasError) {
      content = _DiscoveryStatus(
        message: "Trending books couldn't load.",
        onRetry: () => ref.invalidate(popularGutenbergResultsProvider),
      );
    } else {
      content = const _DiscoveryStatus(
        message: 'No trending books are available right now.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('TRENDING NOW'),
        const SizedBox(height: AppSpacing.md),
        content,
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  static const _categories = [
    (label: 'Classics', icon: Icons.account_balance_outlined),
    (label: 'Fiction', icon: Icons.menu_book_outlined),
    (label: 'Self Help', icon: Icons.eco_outlined),
    (label: 'Business', icon: Icons.business_center_outlined),
    (label: 'History', icon: Icons.hourglass_bottom_outlined),
    (label: 'Biography', icon: Icons.person_outline),
  ];

  String _pathFor(String category) => Uri(
    path: Routes.discovery,
    queryParameters: {'category': category},
  ).toString();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel('EXPLORE BY CATEGORY'),
            GestureDetector(
              onTap: () => context.go(Routes.discovery),
              child: Text(
                'See all',
                style: AppTypography.caption(
                  colors.text2,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < _categories.length; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.md),
                Builder(
                  builder: (context) {
                    final category = _categories[index];
                    final warm = index.isEven;
                    return GestureDetector(
                      onTap: () => context.go(_pathFor(category.label)),
                      child: SizedBox(
                        width: AppSpacing.xxxl + AppSpacing.xl,
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: warm
                                    ? colors.accentSoft
                                    : colors.surface2,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                category.icon,
                                size: AppSpacing.xl,
                                color: warm ? colors.gilt : colors.text2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              category.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTypography.caption(colors.text2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// "Top authors" — the most-downloaded Gutenberg authors, with Wikipedia
/// portraits. Tap → the author profile (bio + their books).
class _TopAuthorsSection extends ConsumerWidget {
  const _TopAuthorsSection();

  static const double _avatar = 64;
  static const double _cellW = 76;
  static const double _rowH = 104; // avatar + gap + one name line

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorsAsync = ref.watch(topAuthorsProvider);
    final authors = authorsAsync.valueOrNull;
    final Widget content;
    if (authors != null && authors.isNotEmpty) {
      content = SizedBox(
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
                      name: a.name,
                      imageUrl: a.imageUrl,
                      size: _avatar,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      a.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(context.appColors.text2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else if (authorsAsync.isLoading) {
      content = SizedBox(
        height: _rowH,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, __) => _AuthorPlaceholder(size: _avatar),
        ),
      );
    } else if (authorsAsync.hasError) {
      content = _DiscoveryStatus(
        message: "Top authors couldn't load.",
        onRetry: () => ref.invalidate(popularGutenbergResultsProvider),
      );
    } else {
      content = const _DiscoveryStatus(
        message: 'No authors are available right now.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('TOP AUTHORS'),
        const SizedBox(height: AppSpacing.md),
        content,
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// "Recommended for you" — driven by the user's own catalog searches (the
/// backend re-runs recent keywords against Google Books). Same cells as
/// Trending. An empty state explains how to create recommendation history.
class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = ref.watch(recommendedBooksProvider);
    final books = recommended.valueOrNull;
    final Widget content;
    if (books != null && books.isNotEmpty) {
      content = SizedBox(
        height: _TrendingSection._rowH,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, i) => _TrendingCell(book: books[i]),
        ),
      );
    } else if (recommended.isLoading) {
      content = SizedBox(
        height: _TrendingSection._rowH,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, __) =>
              const _CoverPlaceholder(width: _TrendingSection._coverW),
        ),
      );
    } else if (recommended.hasError) {
      content = _DiscoveryStatus(
        message: "Recommendations couldn't load.",
        onRetry: () => ref.invalidate(recommendedBooksProvider),
      );
    } else {
      content = const _DiscoveryStatus(
        message: 'Recommendations are warming up. Try Discovery meanwhile.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel('RECOMMENDED FOR YOU'),
            GestureDetector(
              onTap: () => context.go(Routes.discovery),
              child: Text(
                'See all',
                style: AppTypography.caption(
                  context.appColors.text2,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        content,
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _DiscoveryStatus extends StatelessWidget {
  const _DiscoveryStatus({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadii.brMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: AppSpacing.xl,
            color: colors.text3,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: AppTypography.label(colors.text2)),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _AuthorPlaceholder extends StatelessWidget {
  const _AuthorPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: _TopAuthorsSection._cellW,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.surface2,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TrendingCell extends StatelessWidget {
  const _TrendingCell({required this.book});

  final CatalogBook book;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: book.title,
      author: book.author,
      coverUrl: proxiedCoverUrl(book.thumbnailUrl),
      onTap: () => context.push(Routes.catalogBook, extra: book),
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
    return _Card(
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
                Text(
                  'CONTINUE READING',
                  style: AppTypography.overline(colors.text3),
                ),
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
                    Text(
                      '${book.progress.round()}%',
                      style: AppTypography.label(colors.text2),
                    ),
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
                style: AppTypography.serif(
                  TextStyle(
                    color: colors.text,
                    fontSize: 17,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationColor: colors.gilt,
                    decorationThickness: 1,
                  ),
                ),
              ),
              if (passage.source.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md), // Figma: 12 to source
                // Figma 273:139 — serif italic 12, muted ink.
                Text(
                  passage.source,
                  style: AppTypography.serif(
                    TextStyle(
                      color: colors.text3,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
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
