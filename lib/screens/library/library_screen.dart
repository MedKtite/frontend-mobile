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
import '../../providers/library_provider.dart';
import '../../services/backend/book_service.dart';
import '../../widgets/add_to_library_sheet.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_cover.dart';

enum _Filter {
  all('All', 'RECENTLY ADDED'),
  saved('Saved', 'SAVED FOR LATER'),
  reading('Reading', 'IN PROGRESS'),
  listening('Listening', 'LISTENING'),
  finished('Finished', 'RECENTLY FINISHED');

  const _Filter(this.label, this.section);
  final String label;
  final String section;

  bool matches(Book b) => switch (this) {
        _Filter.all => true,
        _Filter.saved => b.status == 'archived',
        _Filter.reading => b.status == 'reading',
        _Filter.listening => b.status == 'listening',
        _Filter.finished => b.status == 'finished',
      };
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _Filter _filter = _Filter.all;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xxxl * 2 + AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('MARGINALIA', style: AppTypography.overline(colors.text3)),
          //     _AddButton(onTap: () => showAddToLibrarySheet(context)),
          //   ],
          // ),
          const SizedBox(height: AppSpacing.sm),
          Text('Library', style: AppTypography.display(colors.text)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${books.length} ${books.length == 1 ? 'volume' : 'volumes'}',
            style: AppTypography.label(colors.text2),
          ),
          if (books.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _searchController,
              hint: 'Search your library…',
              search: true,
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              onClear: _clearSearch,
            ),
          ],
          if (books.isEmpty)
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
    final query = _query.trim().toLowerCase();
    final sorted = [...books]
      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    final visible = sorted.where((book) {
      if (!_filter.matches(book)) return false;
      if (query.isEmpty) return true;
      return book.title.toLowerCase().contains(query) ||
          (book.author?.toLowerCase().contains(query) ?? false);
    }).toList();

    return [
      const SizedBox(height: AppSpacing.lg),
      _FilterChips(
        books: books,
        selected: _filter,
        onSelect: (f) => setState(() => _filter = f),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(
        query.isEmpty ? _filter.section : 'SEARCH RESULTS',
        style: AppTypography.overline(colors.text3),
      ),
      const SizedBox(height: AppSpacing.md),
      if (visible.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Center(
            child: Text(
              query.isEmpty
                  ? 'Nothing here yet.'
                  : 'No saved books match your search.',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2),
            ),
          ),
        )
      else
        _BookGrid(books: visible, onDelete: _delete),
    ];
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
          Icon(
            Icons.auto_stories_outlined,
            size: AppSpacing.xxxl,
            color: colors.text3,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Your library is empty.',
              textAlign: TextAlign.center,
              style: AppTypography.title3(colors.text)),
          const SizedBox(height: AppSpacing.sm),
          Text('Tap + to add your first book.',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2)),
        ],
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
    required this.onDelete,
  });
  final List<Book> books;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
    const gap = AppSpacing.md;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            MediaQuery.sizeOf(context).shortestSide >=
                AppSpacing.tabletBreakpoint;
        if (isTablet) {
          return Wrap(
            spacing: gap,
            runSpacing: AppSpacing.lg,
            children: [
              for (final book in books)
                _GridCell(
                  book: book,
                  width: BookCard.cardWidth,
                  onDelete: () => onDelete(book),
                ),
            ],
          );
        }

        final cardWidth = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.lg,
          children: [
            for (final book in books)
              _GridCell(
                book: book,
                width: cardWidth,
                onDelete: () => onDelete(book),
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
    required this.onDelete,
  });

  final Book book;
  final double width;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: book.title,
      author: book.author,
      coverUrl: proxiedCoverUrl(book.coverUrl),
      width: width,
      onTap: () => context.push(Routes.bookDetail, extra: book),
      onLongPress: onDelete,
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
            Icon(
              Icons.cloud_off_outlined,
              size: AppSpacing.xxxl,
              color: colors.text3,
            ),
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
