import 'dart:async';

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
import '../../core/widgets/app_text_field.dart';
import '../../models/book.dart';
import '../../models/book_create_request.dart';
import '../../models/catalog_book.dart';
import '../../providers/catalog_search_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/trending_provider.dart';
import '../../services/backend/book_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/shelf_picker.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _subjectController = TextEditingController();
  final _isbnController = TextEditingController();

  Timer? _debounce;
  String _query = '';
  String _catalogQuery = '';
  bool _filtersOpen = false;
  bool _advanced = false;
  bool _freeOnly = false;
  final Set<String> _adding = {};
  final Set<String> _added = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _subjectController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    setState(() {
      _advanced = false;
      _query = value;
      if (trimmed.isEmpty) _catalogQuery = '';
    });
    if (trimmed.isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _catalogQuery = trimmed);
      });
    }
  }

  void _submitQuery(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    setState(() {
      _query = trimmed;
      _catalogQuery = trimmed;
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _query = '';
      _catalogQuery = '';
      _advanced = false;
    });
  }

  void _applyAdvanced() {
    String text(TextEditingController controller) => controller.text.trim();

    final parts = <String>[
      if (text(_titleController).isNotEmpty)
        'intitle:"${text(_titleController)}"',
      if (text(_authorController).isNotEmpty)
        'inauthor:"${text(_authorController)}"',
      if (text(_subjectController).isNotEmpty)
        'subject:"${text(_subjectController)}"',
      if (text(_isbnController).isNotEmpty)
        'isbn:${text(_isbnController)}',
    ];
    if (parts.isEmpty) {
      showAppSnack(
        context,
        'Fill at least one filter to search.',
        type: SnackType.warning,
      );
      return;
    }

    final label = [
      text(_titleController),
      text(_authorController),
      text(_subjectController),
      text(_isbnController),
    ].where((value) => value.isNotEmpty).join(' ');

    _debounce?.cancel();
    _searchController.text = label;
    _searchFocus.unfocus();
    setState(() {
      _advanced = true;
      _query = label;
      _catalogQuery = parts.join(' ');
      _filtersOpen = false;
    });
  }

  void _resetAdvanced() {
    _titleController.clear();
    _authorController.clear();
    _subjectController.clear();
    _isbnController.clear();
    setState(() {
      _advanced = false;
      _freeOnly = false;
    });
  }

  void _searchGenre(String genre) {
    _debounce?.cancel();
    _searchController.text = genre;
    _searchFocus.unfocus();
    setState(() {
      _advanced = true;
      _query = genre;
      _catalogQuery = 'subject:"$genre"';
    });
  }

  String _key(CatalogBook book) => book.googleId ?? book.title;

  Future<void> _add(CatalogBook book) async {
    final shelf = await showShelfPicker(context);
    if (shelf == null || !mounted) return;

    final key = _key(book);
    setState(() => _adding.add(key));
    String? error;
    try {
      await ref.read(bookServiceProvider).create(
            BookCreateRequest(
              title: book.title,
              format: 'physical',
              status: shelf,
              author: book.author,
              googleId: book.googleId,
              isbn13: book.isbn13,
              pageCount: book.pageCount,
              publishedYear: book.publishedYear,
              publisher: book.publisher,
              coverUrl: book.thumbnailUrl,
            ),
          );
    } on ApiError catch (e) {
      error = e.message;
    }
    if (!mounted) return;

    setState(() {
      _adding.remove(key);
      if (error == null) _added.add(key);
    });
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (error == null) {
      ref.invalidate(libraryBooksProvider);
      messenger.showSnackBar(
        appSnackBar('Added “${book.title}” to $shelf', SnackType.success),
      );
    } else {
      messenger.showSnackBar(appSnackBar(error, SnackType.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final searching = _query.trim().isNotEmpty;
    final featured = ref.watch(trendingBooksProvider);
    final recommended = ref.watch(recommendedBooksProvider);
    final libraryBooks = ref.watch(libraryBooksProvider).valueOrNull;
    final personalized = recommended.valueOrNull;
    final recommendationBooks = personalized != null && personalized.isNotEmpty
        ? personalized
        : (featured.valueOrNull?.skip(1).take(8).toList() ??
            const <CatalogBook>[]);
    final recommendationLabel = personalized != null && personalized.isNotEmpty
        ? 'BECAUSE OF YOUR RECENT SEARCHES'
        : 'POPULAR WITH READERS';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.xxxl * 2 + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('DISCOVER', style: AppTypography.overline(colors.text3)),
              const SizedBox(height: AppSpacing.sm),
              Text('Discovery', style: AppTypography.display(colors.text)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Find a book worth bringing into your library.',
                style: AppTypography.subtitle(colors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SearchDesk(
                searchController: _searchController,
                searchFocus: _searchFocus,
                filtersActive: _filtersOpen || _advanced || _freeOnly,
                onChanged: _onQueryChanged,
                onSubmitted: _submitQuery,
                onClear: _clearSearch,
                onToggleFilters: () =>
                    setState(() => _filtersOpen = !_filtersOpen),
              ),
              if (_filtersOpen) ...[
                const SizedBox(height: AppSpacing.md),
                _AdvancedPanel(
                  title: _titleController,
                  author: _authorController,
                  subject: _subjectController,
                  isbn: _isbnController,
                  freeOnly: _freeOnly,
                  onFreeOnly: (value) => setState(() => _freeOnly = value),
                  onApply: _applyAdvanced,
                  onReset: _resetAdvanced,
                  onClose: () => setState(() => _filtersOpen = false),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              if (searching)
                _results(colors)
              else ...[
                featured.when(
                  loading: () => const _FeaturedLoading(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (books) {
                    if (books.isEmpty) return const SizedBox.shrink();
                    final book = books.first;
                    final key = _key(book);
                    final owned = _isOwned(book, libraryBooks);
                    return _FeaturedCard(
                      book: book,
                      adding: _adding.contains(key),
                      added: owned || _added.contains(key),
                      onAdd: () => _add(book),
                      onOpen: () =>
                          context.push(Routes.catalogBook, extra: book),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (recommendationBooks.isNotEmpty)
                  _RecommendationShelf(
                    label: recommendationLabel,
                    books: recommendationBooks,
                    onOpen: (book) =>
                        context.push(Routes.catalogBook, extra: book),
                  )
                else if (featured.isLoading || recommended.isLoading)
                  const _RecommendationLoading(),
                _genrePrompt(colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isOwned(CatalogBook catalogBook, List<Book>? libraryBooks) {
    if (libraryBooks == null) return false;
    String normalize(String value) => value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();

    return libraryBooks.any((book) {
      if (catalogBook.googleId != null &&
          catalogBook.googleId == book.googleId) {
        return true;
      }
      return normalize(catalogBook.title) == normalize(book.title);
    });
  }

  Widget _genrePrompt(AppColorsExtension colors) {
    const genres = <(String, Color, Color)>[
      ('Essays', AppColors.genreEssays, AppColors.lightBg),
      ('Fiction', AppColors.genreFiction, AppColors.lightBg),
      ('Poetry', AppColors.genrePoetry, AppColors.lightText),
      ('Philosophy', AppColors.genrePhilosophy, AppColors.lightBg),
      ('Nature', AppColors.genreNature, AppColors.lightBg),
      ('Biography', AppColors.genreBiography, AppColors.lightText),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('BROWSE BY GENRE', style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = AppSpacing.md;
            final itemWidth = (constraints.maxWidth - gap * 2) / 3;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final (genre, background, foreground) in genres)
                  SizedBox(
                    width: itemWidth,
                    child: _GenreCard(
                      label: genre,
                      background: background,
                      foreground: foreground,
                      onTap: () => _searchGenre(genre),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _results(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('CATALOG RESULTS',
                style: AppTypography.overline(colors.text3)),
            const Spacer(),
            if (_freeOnly)
              Text('FREE TO READ',
                  style: AppTypography.overline(colors.accent)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _catalogSection(colors),
      ],
    );
  }

  Widget _catalogSection(AppColorsExtension colors) {
    if (_catalogQuery.isEmpty ||
        (!_advanced && _catalogQuery != _query.trim())) {
      return _busy(colors);
    }

    final results = ref.watch(catalogSearchProvider(_catalogQuery));
    return results.when(
      loading: () => _busy(colors),
      error: (error, _) => _message(
        colors,
        error is ApiError ? error.message : 'Search failed',
      ),
      data: (raw) {
        final books =
            _freeOnly ? raw.where((book) => book.isReadable).toList() : raw;
        if (books.isEmpty) {
          return _message(
            colors,
            _freeOnly && raw.isNotEmpty
                ? 'No free-to-read matches. Turn off the filter to see more.'
                : 'No catalog matches. Try fewer words or another filter.',
          );
        }
        return _CatalogGrid(
          books: books,
          onOpen: (book) => context.push(Routes.catalogBook, extra: book),
        );
      },
    );
  }

  Widget _busy(AppColorsExtension colors) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: CircularProgressIndicator(color: colors.accent),
        ),
      );

  Widget _message(AppColorsExtension colors, String message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.subtitle(colors.text2),
        ),
      );
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.book,
    required this.adding,
    required this.added,
    required this.onAdd,
    required this.onOpen,
  });

  final CatalogBook book;
  final bool adding;
  final bool added;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inverseMuted = colors.bg.withValues(alpha: 0.68);

    return Material(
      color: colors.text,
      borderRadius: AppRadii.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          height: AppSpacing.xxxl * 5,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FEATURED THIS WEEK',
                        style: AppTypography.overline(inverseMuted),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: Text(
                          book.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title2(colors.bg),
                        ),
                      ),
                      if (book.author != null &&
                          book.author!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          book.author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle(inverseMuted),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: adding || added ? null : onAdd,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.bg,
                          foregroundColor: colors.text,
                          disabledBackgroundColor:
                              colors.bg.withValues(alpha: 0.72),
                          disabledForegroundColor:
                              colors.text.withValues(alpha: 0.58),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.brFull,
                          ),
                        ),
                        child: Text(
                          added
                              ? 'In your library'
                              : adding
                                  ? 'Adding…'
                                  : 'Add to library',
                          style: AppTypography.caption(colors.text)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ColoredBox(
                  color: colors.bg.withValues(alpha: 0.08),
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.05,
                      child: BookCover(
                        title: book.title,
                        author: book.author ?? '',
                        bg: colors.bg.withValues(alpha: 0.12),
                        fg: colors.bg,
                        coverUrl: proxiedCoverUrl(book.thumbnailUrl),
                        width: AppSpacing.xxl * 3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedLoading extends StatelessWidget {
  const _FeaturedLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: AppSpacing.xxxl * 5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: AppRadii.brLg,
      ),
      child: CircularProgressIndicator(color: colors.accent),
    );
  }
}

class _RecommendationShelf extends StatelessWidget {
  const _RecommendationShelf({
    required this.label,
    required this.books,
    required this.onOpen,
  });

  final String label;
  final List<CatalogBook> books;
  final ValueChanged<CatalogBook> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSpacing.xxxl * 5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final book = books[index];
              return _RecommendationCell(
                book: book,
                onOpen: () => onOpen(book),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _RecommendationCell extends StatelessWidget {
  const _RecommendationCell({
    required this.book,
    required this.onOpen,
  });

  final CatalogBook book;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: book.title,
      author: book.author,
      coverUrl: proxiedCoverUrl(book.thumbnailUrl),
      onTap: onOpen,
    );
  }
}

class _RecommendationLoading extends StatelessWidget {
  const _RecommendationLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('CURATING FOR YOU', style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: BookCard.cardWidth * 1.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, __) => Container(
              width: BookCard.cardWidth,
              height: BookCard.cardWidth * 1.5,
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: AppRadii.brSm,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _SearchDesk extends StatelessWidget {
  const _SearchDesk({
    required this.searchController,
    required this.searchFocus,
    required this.filtersActive,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onToggleFilters,
  });

  final TextEditingController searchController;
  final FocusNode searchFocus;
  final bool filtersActive;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onToggleFilters;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: searchController,
            focusNode: searchFocus,
            hint: 'Title, author, subject, or ISBN…',
            search: true,
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onClear: onClear,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: filtersActive ? colors.accent : colors.surface,
          borderRadius: AppRadii.brMd,
          child: InkWell(
            onTap: onToggleFilters,
            borderRadius: AppRadii.brMd,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Icon(
                Icons.tune_rounded,
                size: AppSpacing.xl,
                color: filtersActive ? colors.bg : colors.text2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdvancedPanel extends StatelessWidget {
  const _AdvancedPanel({
    required this.title,
    required this.author,
    required this.subject,
    required this.isbn,
    required this.freeOnly,
    required this.onFreeOnly,
    required this.onApply,
    required this.onReset,
    required this.onClose,
  });

  final TextEditingController title;
  final TextEditingController author;
  final TextEditingController subject;
  final TextEditingController isbn;
  final bool freeOnly;
  final ValueChanged<bool> onFreeOnly;
  final VoidCallback onApply;
  final VoidCallback onReset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget field(
      String hint,
      TextEditingController controller, {
      TextInputType? keyboardType,
    }) {
      return AppTextField(
        controller: controller,
        hint: hint,
        keyboardType: keyboardType,
        fillColor: colors.surface,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onApply(),
      );
    }

    return GlassPanel(
      radius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('ADVANCED SEARCH',
                  style: AppTypography.overline(colors.text3)),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close,
                    size: AppSpacing.xl, color: colors.text3),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          field('Title', title),
          const SizedBox(height: AppSpacing.sm),
          field('Author', author),
          const SizedBox(height: AppSpacing.sm),
          field('Genre or subject', subject),
          const SizedBox(height: AppSpacing.sm),
          field('ISBN', isbn, keyboardType: TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => onFreeOnly(!freeOnly),
            child: Row(
              children: [
                Checkbox(
                  value: freeOnly,
                  onChanged: (value) => onFreeOnly(value ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Text(
                    'Free to read in Marginalia only',
                    style: AppTypography.caption(colors.text2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  child: Text('Reset',
                      style: AppTypography.label(colors.text2)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.bg,
                  ),
                  child: Text(
                    'Search',
                    style: AppTypography.label(colors.bg)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxl,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title3(foreground)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({
    required this.books,
    required this.onOpen,
  });

  final List<CatalogBook> books;
  final ValueChanged<CatalogBook> onOpen;

  @override
  Widget build(BuildContext context) {
    const gap = AppSpacing.md;
    return Wrap(
      spacing: gap,
      runSpacing: AppSpacing.xl,
      children: [
        for (final book in books)
          _CatalogCell(
            book: book,
            onOpen: () => onOpen(book),
          ),
      ],
    );
  }
}

class _CatalogCell extends StatelessWidget {
  const _CatalogCell({
    required this.book,
    required this.onOpen,
  });

  final CatalogBook book;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: book.title,
      author: book.author,
      coverUrl: proxiedCoverUrl(book.thumbnailUrl),
      onTap: onOpen,
    );
  }
}
