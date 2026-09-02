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
import '../../widgets/add_to_library_sheet.dart';
import '../../widgets/advanced_filters_sheet.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/shelf_picker.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key, this.initialCategory});

  final String? initialCategory;

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
  bool _advanced = false;
  bool _freeOnly = false;
  final Set<String> _adding = {};
  final Set<String> _added = {};

  @override
  void initState() {
    super.initState();
    _setInitialCategory(widget.initialCategory);
  }

  @override
  void didUpdateWidget(covariant DiscoveryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      _setInitialCategory(widget.initialCategory, notify: true);
    }
  }

  void _setInitialCategory(String? value, {bool notify = false}) {
    final category = value?.trim() ?? '';
    if (category.isEmpty) return;

    void update() {
      _searchController.text = category;
      _subjectController.text = category;
      _advanced = true;
      _query = category;
      _catalogQuery = 'subject:"$category"';
    }

    if (notify) {
      setState(update);
    } else {
      update();
    }
  }

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

  int get _activeFiltersCount {
    var count = 0;
    if (_titleController.text.trim().isNotEmpty) count++;
    if (_authorController.text.trim().isNotEmpty) count++;
    if (_subjectController.text.trim().isNotEmpty) count++;
    if (_isbnController.text.trim().isNotEmpty) count++;
    if (_freeOnly) count++;
    return count;
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
    _titleController.clear();
    _authorController.clear();
    _subjectController.clear();
    _isbnController.clear();
    setState(() {
      _query = '';
      _catalogQuery = '';
      _advanced = false;
      _freeOnly = false;
    });
  }

  void _syncActiveFilters() {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final subject = _subjectController.text.trim();
    final isbn = _isbnController.text.trim();

    final parts = <String>[
      if (title.isNotEmpty) 'intitle:"$title"',
      if (author.isNotEmpty) 'inauthor:"$author"',
      if (subject.isNotEmpty) 'subject:"$subject"',
      if (isbn.isNotEmpty) 'isbn:$isbn',
    ];

    if (parts.isEmpty) {
      setState(() {
        _advanced = false;
        if (_query == _searchController.text &&
            (_catalogQuery.startsWith('subject:') ||
                _catalogQuery.startsWith('intitle:') ||
                _catalogQuery.startsWith('inauthor:') ||
                _catalogQuery.startsWith('isbn:'))) {
          _catalogQuery = '';
          _query = '';
          _searchController.clear();
        }
      });
    } else {
      final label = [
        title,
        author,
        subject,
        isbn,
      ].where((value) => value.isNotEmpty).join(' ');

      _debounce?.cancel();
      _searchController.text = label;
      _searchFocus.unfocus();
      setState(() {
        _advanced = true;
        _query = label;
        _catalogQuery = parts.join(' ');
      });
    }
  }

  Future<void> _openFiltersSheet() async {
    final result = await showAdvancedFiltersSheet(
      context,
      initialTitle: _titleController.text.trim(),
      initialAuthor: _authorController.text.trim(),
      initialSubject: _subjectController.text.trim(),
      initialIsbn: _isbnController.text.trim(),
      initialFreeOnly: _freeOnly,
    );
    if (result == null || !mounted) return;

    _titleController.text = result.title;
    _authorController.text = result.author;
    _subjectController.text = result.subject;
    _isbnController.text = result.isbn;
    _freeOnly = result.freeOnly;

    _syncActiveFilters();
  }

  String _key(CatalogBook book) => book.googleId ?? book.title;

  Future<void> _add(CatalogBook book) async {
    final shelf = await showShelfPicker(context);
    if (shelf == null || !mounted) return;

    final key = _key(book);
    setState(() => _adding.add(key));
    String? error;
    try {
      await ref
          .read(bookServiceProvider)
          .create(
            BookCreateRequest(
              title: book.title,
              format: 'physical',
              status: shelf,
              author: book.author,
              googleId: book.googleId,
              gutenbergId: book.gutenbergId,
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
                activeCount: _activeFiltersCount,
                onChanged: _onQueryChanged,
                onSubmitted: _submitQuery,
                onClear: _clearSearch,
                onOpenFilters: _openFiltersSheet,
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickFilterChips(
                freeOnly: _freeOnly,
                activeSubject: _subjectController.text.trim(),
                activeAuthor: _authorController.text.trim(),
                activeIsbn: _isbnController.text.trim(),
                onToggleFreeOnly: (val) {
                  setState(() => _freeOnly = val);
                  _syncActiveFilters();
                },
                onSelectSubject: (subject) {
                  _subjectController.text = subject;
                  _syncActiveFilters();
                },
                onOpenFilters: _openFiltersSheet,
              ),
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
                _addToLibraryPrompt(colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isOwned(CatalogBook catalogBook, List<Book>? libraryBooks) {
    if (libraryBooks == null) return false;
    String normalize(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

    return libraryBooks.any((book) {
      if (catalogBook.googleId != null &&
          catalogBook.googleId == book.googleId) {
        return true;
      }
      return normalize(catalogBook.title) == normalize(book.title);
    });
  }

  Widget _addToLibraryPrompt(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ADD TO YOUR LIBRARY',
          style: AppTypography.overline(colors.text3),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.brMd,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  color: colors.accent,
                  size: AppSpacing.xl,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bring a book with you.',
                      style: AppTypography.title3(colors.text),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Upload an EPUB or PDF and make it part of your reading life.',
                      style: AppTypography.label(colors.text2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: () => showAddToLibrarySheet(context),
                      icon: const Icon(
                        Icons.file_upload_outlined,
                        size: AppSpacing.lg,
                      ),
                      label: const Text('Upload a book'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.text,
                        foregroundColor: colors.bg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.brFull,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _results(AppColorsExtension colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'CATALOG RESULTS',
              style: AppTypography.overline(colors.text3),
            ),
            const Spacer(),
            if (_freeOnly)
              Text(
                'FREE TO READ',
                style: AppTypography.overline(colors.accent),
              ),
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
      error: (error, _) =>
          _message(colors, error is ApiError ? error.message : 'Search failed'),
      data: (raw) {
        final books = _freeOnly
            ? raw.where((book) => book.isReadable).toList()
            : raw;
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

  Widget _busy(AppColorsExtension colors) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
    child: AppProgressLoading(),
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
                      if (book.author != null && book.author!.isNotEmpty) ...[
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
                          disabledBackgroundColor: colors.bg.withValues(
                            alpha: 0.72,
                          ),
                          disabledForegroundColor: colors.text.withValues(
                            alpha: 0.58,
                          ),
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
                          style: AppTypography.caption(
                            colors.text,
                          ).copyWith(fontWeight: FontWeight.w600),
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
      child: const AppProgressLoading(width: 140),
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
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
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
  const _RecommendationCell({required this.book, required this.onOpen});

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
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
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
    required this.activeCount,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onOpenFilters,
  });

  final TextEditingController searchController;
  final FocusNode searchFocus;
  final int activeCount;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;

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
            prefixIcon: Icons.search,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onClear: onClear,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: AppSpacing.inputHeight,
              width: AppSpacing.inputHeight,
              decoration: BoxDecoration(
                color: activeCount > 0 ? colors.accent : colors.surface,
                borderRadius: AppRadii.brMd,
                border: Border.all(
                  color: activeCount > 0 ? colors.accent : colors.border,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenFilters,
                  borderRadius: AppRadii.brMd,
                  child: Center(
                    child: Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: activeCount > 0 ? colors.bg : colors.text2,
                    ),
                  ),
                ),
              ),
            ),
            if (activeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.text,
                    borderRadius: AppRadii.brFull,
                    border: Border.all(color: colors.surface, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        color: colors.bg,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickFilterChips extends StatelessWidget {
  const _QuickFilterChips({
    required this.freeOnly,
    required this.activeSubject,
    required this.activeAuthor,
    required this.activeIsbn,
    required this.onToggleFreeOnly,
    required this.onSelectSubject,
    required this.onOpenFilters,
  });

  final bool freeOnly;
  final String activeSubject;
  final String activeAuthor;
  final String activeIsbn;
  final ValueChanged<bool> onToggleFreeOnly;
  final ValueChanged<String> onSelectSubject;
  final VoidCallback onOpenFilters;

  static const _categories = [
    'Classics',
    'Fiction',
    'Philosophy',
    'History',
    'Biography',
    'Self Help',
    'Poetry',
    'Business',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Free to read',
            icon: Icons.check_circle_outline_rounded,
            active: freeOnly,
            onTap: () => onToggleFreeOnly(!freeOnly),
          ),
          if (activeAuthor.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Author: $activeAuthor',
              icon: Icons.person_outline,
              active: true,
              onTap: onOpenFilters,
            ),
          ],
          if (activeIsbn.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'ISBN: $activeIsbn',
              icon: Icons.qr_code_scanner_outlined,
              active: true,
              onTap: onOpenFilters,
            ),
          ],
          for (final cat in _categories) ...[
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: cat,
              active: activeSubject.toLowerCase() == cat.toLowerCase(),
              onTap: () {
                if (activeSubject.toLowerCase() == cat.toLowerCase()) {
                  onSelectSubject('');
                } else {
                  onSelectSubject(cat);
                }
              },
            ),
          ],
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'More filters ▾',
            active: false,
            onTap: onOpenFilters,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: active ? colors.text : colors.surface,
      borderRadius: AppRadii.brFull,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brFull,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brFull,
            border: Border.all(color: active ? colors.text : colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: active ? colors.bg : colors.text2),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTypography.caption(active ? colors.bg : colors.text2)
                    .copyWith(
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
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
  const _CatalogGrid({required this.books, required this.onOpen});

  final List<CatalogBook> books;
  final ValueChanged<CatalogBook> onOpen;

  @override
  Widget build(BuildContext context) {
    const gap = AppSpacing.md;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 4 : 3;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.xl,
          children: [
            for (final book in books)
              _CatalogCell(
                book: book,
                width: width,
                onOpen: () => onOpen(book),
              ),
          ],
        );
      },
    );
  }
}

class _CatalogCell extends StatelessWidget {
  const _CatalogCell({
    required this.book,
    required this.width,
    required this.onOpen,
  });

  final CatalogBook book;
  final double width;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: book.title,
      author: book.author,
      coverUrl: proxiedCoverUrl(book.thumbnailUrl),
      width: width,
      onTap: onOpen,
    );
  }
}
