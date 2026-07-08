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
import '../../models/book_update_request.dart';
import '../../models/catalog_book.dart';
import '../../providers/catalog_search_provider.dart';
import '../../providers/library_provider.dart';
import '../../services/backend/book_service.dart';
import '../../widgets/add_to_library_sheet.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/shelf_picker.dart';

enum _Filter {
  all('All', 'RECENTLY ADDED'),
  reading('Reading', 'IN PROGRESS'),
  listening('Listening', 'LISTENING'),
  finished('Finished', 'RECENTLY FINISHED');

  const _Filter(this.label, this.section);
  final String label;
  final String section;

  bool matches(Book b) => switch (this) {
        _Filter.all => true,
        _Filter.reading => b.status == 'reading',
        _Filter.listening => b.status == 'listening',
        _Filter.finished => b.status == 'finished',
      };
}


class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key, this.autofocusSearch = false});

  final bool autofocusSearch;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _Filter _filter = _Filter.all;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  String _query = '';
  String _catalogQuery = ''; // debounced text → catalog (Google Books) search

  // Advanced search: composes Google operators (intitle:/inauthor:/subject:/
  // isbn:) into _catalogQuery, while _query keeps a human string for the
  // local-library filter. No backend change — Google parses the operators.
  bool _filtersOpen = false;
  bool _advanced = false; // true while _catalogQuery is operator-composed
  bool _freeOnly = false; // show only readable-in-app results
  final _fTitle = TextEditingController();
  final _fAuthor = TextEditingController();
  final _fSubject = TextEditingController();
  final _fIsbn = TextEditingController();

  // Per-result add state, keyed by [_key] (catalog rows).
  final Set<String> _adding = {};
  final Set<String> _added = {};

  @override
  void initState() {
    super.initState();
    if (widget.autofocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _fTitle.dispose();
    _fAuthor.dispose();
    _fSubject.dispose();
    _fIsbn.dispose();
    super.dispose();
  }

  void _applyAdvanced() {
    String t(TextEditingController c) => c.text.trim();
    final parts = <String>[
      if (t(_fTitle).isNotEmpty) 'intitle:"${t(_fTitle)}"',
      if (t(_fAuthor).isNotEmpty) 'inauthor:"${t(_fAuthor)}"',
      if (t(_fSubject).isNotEmpty) 'subject:"${t(_fSubject)}"',
      if (t(_fIsbn).isNotEmpty) 'isbn:${t(_fIsbn)}',
    ];
    if (parts.isEmpty) {
      showAppSnack(context, 'Fill at least one filter to search.',
          type: SnackType.warning);
      return;
    }
    final human = [t(_fTitle), t(_fAuthor), t(_fSubject), t(_fIsbn)]
        .where((s) => s.isNotEmpty)
        .join(' ');
    _debounce?.cancel();
    _searchController.text = human;
    _searchFocus.unfocus();
    setState(() {
      _advanced = true;
      _query = human;
      _catalogQuery = parts.join(' ');
      _filtersOpen = false;
    });
  }

  void _resetAdvanced() {
    _fTitle.clear();
    _fAuthor.clear();
    _fSubject.clear();
    _fIsbn.clear();
    setState(() {
      _advanced = false;
      _freeOnly = false;
    });
  }

  // The local filter reacts to every keystroke; the catalog round-trip is
  // debounced so we don't hit Google Books on each character.
  void _onQueryChanged(String v) {
    _debounce?.cancel();
    final q = v.trim();
    setState(() {
      _advanced = false; // manual typing overrides operator composition
      _query = v;
      if (q.isEmpty) _catalogQuery = '';
    });
    if (q.isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _catalogQuery = q);
      });
    }
  }

  void _onQuerySubmitted(String v) {
    _debounce?.cancel();
    setState(() => _catalogQuery = v.trim());
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _query = '';
      _catalogQuery = '';
    });
  }

  bool _matches(Book b, String q) =>
      b.title.toLowerCase().contains(q) ||
      (b.author?.toLowerCase().contains(q) ?? false);

  String _key(CatalogBook c) => c.googleId ?? c.title;


  Future<void> _reshelf(Book book) async {
    final shelf = await showShelfPicker(context);
    if (shelf == null || !mounted) return;
    String? error;
    try {
      await ref
          .read(bookServiceProvider)
          .update(book.id, BookUpdateRequest(status: shelf));
    } on ApiError catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (error == null) {
      ref.invalidate(libraryBooksProvider);
      messenger.showSnackBar(
          appSnackBar('Moved “${book.title}” to $shelf', SnackType.success));
    } else {
      messenger.showSnackBar(appSnackBar(error, SnackType.error));
    }
  }

  Future<void> _delete(Book book) async {
    final confirmed = await _confirmRemove(book);
    if (confirmed != true || !mounted) return;
    String? error;
    try {
      await ref.read(bookServiceProvider).delete(book.id);
    } on ApiError catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (error == null) {
      ref.invalidate(libraryBooksProvider);
      messenger.showSnackBar(
          appSnackBar('Removed “${book.title}”', SnackType.success));
    } else {
      messenger.showSnackBar(appSnackBar(error, SnackType.error));
    }
  }

  Future<bool?> _confirmRemove(Book book) {
    final colors = context.appColors;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Remove book?', style: AppTypography.title3(colors.text)),
        content: Text(
          '“${book.title}” will be removed from your library.',
          style: AppTypography.subtitle(colors.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTypography.label(colors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: AppTypography.label(colors.accent)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(CatalogBook c) async {
    final shelf = await showShelfPicker(context);
    if (shelf == null || !mounted) return;
    final key = _key(c);
    setState(() => _adding.add(key));
    String? error;
    try {
      await ref.read(bookServiceProvider).create(
            BookCreateRequest(
              title: c.title,
              format: 'physical',
              status: shelf,
              author: c.author,
              googleId: c.googleId, // lets the reader fetch the free PD PDF
              isbn13: c.isbn13,
              pageCount: c.pageCount,
              publishedYear: c.publishedYear,
              publisher: c.publisher,
              coverUrl: c.thumbnailUrl,
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
          appSnackBar('Added “${c.title}” to $shelf', SnackType.success));
    } else {
      messenger.showSnackBar(appSnackBar(error, SnackType.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final booksAsync = ref.watch(libraryBooksProvider);

    // Nav bar lives in AppShell (persistent across tabs) — not here.
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddToLibrarySheet(context),
        backgroundColor: colors.text,
        foregroundColor: colors.bg,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: booksAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => _ErrorRetry(
            message: e is ApiError ? e.message : 'Something went wrong',
            onRetry: () => ref.invalidate(libraryBooksProvider),
          ),
          data: _content,
        ),
      ),
    );
  }

  Widget _content(List<Book> books) {
    final colors = context.appColors;
    final searching = _query.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        96, // clear the glass nav bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MARGINALIA', style: AppTypography.overline(colors.text3)),
              _AddButton(onTap: () => showAddToLibrarySheet(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Discovery', style: AppTypography.display(colors.text)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${books.length} ${books.length == 1 ? 'volume' : 'volumes'}',
            style: AppTypography.label(colors.text2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Search your library or the catalog…',
                  search: true,
                  prefixIcon: Icons.search,
                  focusNode: _searchFocus,
                  textInputAction: TextInputAction.search,
                  onChanged: _onQueryChanged,
                  onSubmitted: _onQuerySubmitted,
                  onClear: _clearSearch,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterToggle(
                active: _filtersOpen || _advanced || _freeOnly,
                onTap: () => setState(() => _filtersOpen = !_filtersOpen),
              ),
            ],
          ),
          if (_filtersOpen) ...[
            const SizedBox(height: AppSpacing.md),
            _AdvancedPanel(
              title: _fTitle,
              author: _fAuthor,
              subject: _fSubject,
              isbn: _fIsbn,
              freeOnly: _freeOnly,
              onFreeOnly: (v) => setState(() => _freeOnly = v),
              onApply: _applyAdvanced,
              onReset: _resetAdvanced,
            ),
          ],
          if (searching)
            ..._searchResults(books)
          else if (books.isEmpty)
            const _EmptyLibrary()
          else
            ..._libraryBody(books),
        ],
      ),
    );
  }

  /// Normal (not-searching) body: status chips + the cover grid.
  List<Widget> _libraryBody(List<Book> books) {
    final colors = context.appColors;
    final sorted = [...books]
      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    final visible = sorted.where(_filter.matches).toList();

    return [
      const SizedBox(height: AppSpacing.lg),
      _FilterChips(
        books: books,
        selected: _filter,
        onSelect: (f) => setState(() => _filter = f),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(_filter.section, style: AppTypography.overline(colors.text3)),
      const SizedBox(height: AppSpacing.md),
      if (visible.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Center(
            child: Text('Nothing here yet.',
                style: AppTypography.subtitle(colors.text2)),
          ),
        )
      else
        _BookGrid(books: visible, onShelf: _reshelf, onDelete: _delete),
    ];
  }

  /// Searching body: your matching shelves first, then the catalog to add from.
  List<Widget> _searchResults(List<Book> books) {
    final colors = context.appColors;
    final q = _query.trim().toLowerCase();
    final local = ([...books]
          ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? '')))
        .where((b) => _matches(b, q))
        .toList();

    return [
      const SizedBox(height: AppSpacing.xl),
      if (local.isNotEmpty) ...[
        Text('IN YOUR LIBRARY', style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.md),
        _BookGrid(books: local, onShelf: _reshelf, onDelete: _delete),
        const SizedBox(height: AppSpacing.xl),
      ],
      Text('FROM THE CATALOG', style: AppTypography.overline(colors.text3)),
      const SizedBox(height: AppSpacing.md),
      _catalogSection(),
    ];
  }

  Widget _catalogSection() {
    final colors = context.appColors;
    // Debounce still settling (or query just cleared) → spinner, not "no
    // matches". Advanced queries set both fields atomically — no debounce.
    if (_catalogQuery.isEmpty ||
        (!_advanced && _catalogQuery != _query.trim())) {
      return _catalogBusy();
    }
    final results = ref.watch(catalogSearchProvider(_catalogQuery));
    return results.when(
      loading: _catalogBusy,
      error: (e, _) =>
          _catalogMessage(colors, e is ApiError ? e.message : 'Search failed'),
      data: (raw) {
        final list =
            _freeOnly ? raw.where((c) => c.isReadable).toList() : raw;
        return list.isEmpty
          ? _catalogMessage(
              colors,
              _freeOnly && raw.isNotEmpty
                  ? 'No free-to-read matches — turn off the filter to see '
                      '${raw.length} more.'
                  : 'No matches in the catalog.')
          : _CatalogGrid(
              books: list,
              adding: _adding,
              added: _added,
              keyOf: _key,
              onAdd: _add,
              onOpen: (c) => context.push(Routes.catalogBook, extra: c),
            );
      },
    );
  }

  Widget _catalogBusy() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _catalogMessage(AppColorsExtension colors, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(text, style: AppTypography.subtitle(colors.text2)),
        ),
      );
}

/// Round "tune" button beside the search bar — accent-filled while any
/// advanced filter is active so the narrowing is never invisible.
class _FilterToggle extends StatelessWidget {
  const _FilterToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: active ? colors.accent : colors.surface,
      shape: CircleBorder(
          side: BorderSide(color: active ? colors.accent : colors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Icon(
            Icons.tune_rounded,
            size: 20,
            color: active ? colors.bg : colors.text2,
          ),
        ),
      ),
    );
  }
}

/// Advanced search: field-scoped terms composed into Google Books operators.
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
  });

  final TextEditingController title;
  final TextEditingController author;
  final TextEditingController subject;
  final TextEditingController isbn;
  final bool freeOnly;
  final ValueChanged<bool> onFreeOnly;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget field(String hint, TextEditingController c,
        {TextInputType? type}) {
      return AppTextField(
        controller: c,
        hint: hint,
        keyboardType: type,
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
          Text('ADVANCED SEARCH',
              style: AppTypography.overline(colors.text3)),
          const SizedBox(height: AppSpacing.md),
          field('Title', title),
          const SizedBox(height: AppSpacing.sm),
          field('Author', author),
          const SizedBox(height: AppSpacing.sm),
          field('Genre or subject', subject),
          const SizedBox(height: AppSpacing.sm),
          field('ISBN', isbn, type: TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => onFreeOnly(!freeOnly),
            child: Row(
              children: [
                Checkbox(
                  value: freeOnly,
                  onChanged: (v) => onFreeOnly(v ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Text('Free to read in Marginalia only',
                      style: AppTypography.caption(colors.text2)),
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
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.brMd,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: AppRadii.brMd,
          border: Border.all(color: colors.border),
        ),
        child: Icon(Icons.add, size: 20, color: colors.text),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined, size: 40, color: colors.text3),
          const SizedBox(height: AppSpacing.lg),
          Text('Your library is empty.',
              textAlign: TextAlign.center,
              style: AppTypography.title3(colors.text)),
          const SizedBox(height: AppSpacing.sm),
          Text('Search above or tap + to add a book from the catalog.',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2)),
        ],
      ),
    );
  }
}

/// Catalog (Google Books) results as the same 3-column cover grid as the
/// library, but each cell carries an Add badge (＋ → spinner → ✓) instead of
/// the reshelf badge, and shows the author rather than reading progress.
class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({
    required this.books,
    required this.adding,
    required this.added,
    required this.keyOf,
    required this.onAdd,
    required this.onOpen,
  });

  final List<CatalogBook> books;
  final Set<String> adding;
  final Set<String> added;
  final String Function(CatalogBook) keyOf;
  final ValueChanged<CatalogBook> onAdd;
  final ValueChanged<CatalogBook> onOpen;

  @override
  Widget build(BuildContext context) {
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
                child: _CatalogGridCell(
                  book: b,
                  width: cellW,
                  adding: adding.contains(keyOf(b)),
                  added: added.contains(keyOf(b)),
                  onAdd: () => onAdd(b),
                  onOpen: () => onOpen(b),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CatalogGridCell extends StatelessWidget {
  const _CatalogGridCell({
    required this.book,
    required this.width,
    required this.adding,
    required this.added,
    required this.onAdd,
    required this.onOpen,
  });

  final CatalogBook book;
  final double width;
  final bool adding;
  final bool added;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final busy = adding || added;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          height: width * 1.5,
          child: Stack(
            children: [
              // Tap the cover → full book page (buy/request/add); the corner
              // badge stays as the quick-add.
              GestureDetector(
                onTap: onOpen,
                child: BookCover(
                  title: book.title,
                  author: book.author ?? '',
                  bg: colors.surface2,
                  fg: colors.text2,
                  coverUrl: proxiedCoverUrl(book.thumbnailUrl),
                  width: width,
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _CatalogAddBadge(
                  adding: adding,
                  added: added,
                  onTap: busy ? null : onAdd,
                ),
              ),
            ],
          ),
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
    );
  }
}

/// Cover badge for a catalog cell: ＋ to add, spinner while adding, ✓ once added.
class _CatalogAddBadge extends StatelessWidget {
  const _CatalogAddBadge({
    required this.adding,
    required this.added,
    this.onTap,
  });

  final bool adding;
  final bool added;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: adding
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.text2),
              )
            : Icon(added ? Icons.check : Icons.add, size: 16, color: colors.text),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.books,
    required this.selected,
    required this.onSelect,
  });

  final List<Book> books;
  final _Filter selected;
  final ValueChanged<_Filter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _Filter.values) ...[
            _Chip(
              label: f.label,
              count: books.where(f.matches).length,
              active: f == selected,
              onTap: () => onSelect(f),
            ),
            if (f != _Filter.values.last) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active ? colors.text : Colors.transparent,
          borderRadius: AppRadii.brFull,
          border: Border.all(color: active ? colors.text : colors.border),
        ),
        child: Text(
          '$label $count',
          style: AppTypography.label(active ? colors.bg : colors.text2)
              .copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({
    required this.books,
    required this.onShelf,
    required this.onDelete,
  });
  final List<Book> books;
  final ValueChanged<Book> onShelf;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
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
                child: _GridCell(
                  book: b,
                  width: cellW,
                  onShelf: () => onShelf(b),
                  onDelete: () => onDelete(b),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.book,
    required this.width,
    required this.onShelf,
    required this.onDelete,
  });

  final Book book;
  final double width;
  final VoidCallback onShelf;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          height: width * 1.5,
          child: Stack(
            children: [
              // Tap the cover → book detail page (description first, then
              // "Continue reading"); long-press to remove. The + badge above
              // keeps its own taps.
              GestureDetector(
                onTap: () =>
                    context.push(Routes.bookDetail, extra: book),
                onLongPress: onDelete,
                child: BookCover(
                  title: book.title,
                  author: book.author ?? '',
                  bg: coverColorFromHex(book.coverDominantColor),
                  fg: coverFgFor(book.coverDominantColor),
                  coverUrl: proxiedCoverUrl(book.coverUrl),
                  width: width,
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _AddBadge(
                  key: ValueKey('shelf-${book.id}'),
                  onTap: onShelf,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label(colors.text),
        ),
        const SizedBox(height: AppSpacing.xs),
        _ProgressDots(progress: book.progressPct ?? 0),
      ],
    );
  }
}

class _AddBadge extends StatelessWidget {
  const _AddBadge({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(Icons.add, size: 16, color: colors.text),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.progress});
  final double progress; // 0–100

  static const _count = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = (progress / 100 * _count).round().clamp(0, _count);
    return Row(
      children: [
        for (var i = 0; i < _count; i++)
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? colors.text2 : colors.text3.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
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
            Text("Couldn't load your library.",
                textAlign: TextAlign.center,
                style: AppTypography.title3(colors.text)),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTypography.caption(colors.text2)),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
