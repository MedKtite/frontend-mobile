import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// `hide Image`: epub_view re-exports the `image` package, whose `Image` clashes
// with Flutter's Image widget (used in the EPUB img extension below).
import 'package:epub_view/epub_view.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// epub_view and pdfx both export `DefaultBuilderOptions`; hide pdfx's so the
// EPUB reader can reference epub_view's for the typography text style.
import 'package:pdfx/pdfx.dart' hide DefaultBuilderOptions;

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../models/book.dart';
import '../../models/book_update_request.dart';
import '../../models/highlight.dart';
import '../../models/highlight_create_request.dart';
import '../../models/note_create_request.dart';
import '../../providers/book_file_provider.dart';
import '../../providers/book_highlights_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/gutenberg_provider.dart';
import '../../providers/reading_settings_provider.dart';
import '../../services/backend/book_service.dart';
import '../../services/backend/highlight_service.dart';
import '../../services/backend/note_service.dart';
import '../../widgets/note_sheet.dart';
import '../../widgets/tag_picker_sheet.dart';
import '../../widgets/typography_sheet.dart';

/// Reader. Keeps the designed chrome (back · title · Aa, and the bottom progress
/// bar) and drops the real uploaded file into the body: a [_PdfReader] or
/// [_EpubReader] depending on `book.format`. Catalog/physical books have no file
/// to read, so they get a [_NoReadableFile] state instead of fake passage text.
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key, required this.bookId, this.initialBook});

  final String bookId;
  final Book? initialBook;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  /// The active reader pushes its position here; only the bottom bar listens, so
  /// the page/EPUB view itself never rebuilds on a progress tick.
  late final ValueNotifier<_ReaderProgress> _progress = ValueNotifier(
    _ReaderProgress(widget.initialBook?.progressPct ?? 0, ''),
  );

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readingSettingsProvider);
    final p = settings.palette;
    final base = context.appColors;
    // Recolor the whole reading surface to the chosen reader theme by overriding
    // AppColorsExtension — the chrome + states already read `context.appColors`.
    final readerColors = base.copyWith(
      bg: p.bg,
      surface2: p.surface2,
      border: p.border,
      text: p.text,
      text2: p.text2,
      text3: p.text3,
      accent: p.accent,
    );
    final theme = Theme.of(context);
    final extensions = theme.extensions.values
        .where((e) => e is! AppColorsExtension)
        .toList()
      ..add(readerColors);

    return Theme(
      data: theme.copyWith(extensions: extensions),
      child: Builder(
        builder: (context) {
          final colors = context.appColors;
          // Chrome shows instantly from initialBook; the reader body waits for
          // the fresh fetch so it's built ONCE with the latest saved cursor
          // (resume). initialBook from the library can carry a stale position,
          // and re-building the reader mid-life would let a stale instance's
          // dispose clobber the good cursor.
          final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
          final displayBook = bookAsync.valueOrNull ?? widget.initialBook;
          final readerBook = bookAsync.valueOrNull ??
              (bookAsync.hasError ? widget.initialBook : null);

          return Scaffold(
            backgroundColor: colors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(title: displayBook?.title ?? 'Reading'),
                  Expanded(
                    child: readerBook != null
                        ? _body(context, readerBook)
                        : Center(
                            child: CircularProgressIndicator(
                                color: colors.accent)),
                  ),
                  if (displayBook != null)
                    ValueListenableBuilder<_ReaderProgress>(
                      valueListenable: _progress,
                      builder: (_, pr, __) =>
                          _BottomBar(progressPct: pr.pct, label: pr.label),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, Book? book) {
    final colors = context.appColors;
    if (book == null) {
      return Center(child: CircularProgressIndicator(color: colors.accent));
    }

    final fmt = book.format;
    if (fmt != 'epub' && fmt != 'pdf') {
      // Catalog/physical book → fetch the clean full text from Project Gutenberg
      // (public-domain) and render it exactly like an uploaded EPUB.
      final gref = (id: book.id, title: book.title, author: book.author);
      return ref.watch(gutenbergEpubProvider(gref)).when(
            loading: () => _GutenbergLoading(bookId: book.id),
            error: (e, _) => e is GutenbergNotFound
                ? _NoReadableFile(book: book)
                : _ReaderError(
                    message: 'Could not load this book.',
                    onRetry: () => ref.invalidate(gutenbergEpubProvider(gref)),
                  ),
            data: (file) =>
                _EpubReader(file: file, book: book, progress: _progress),
          );
    }

    final fileRef = (id: book.id, format: fmt!);
    return ref.watch(bookFileProvider(fileRef)).when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: colors.accent)),
          error: (e, _) => _ReaderError(
            message: e is ApiError ? e.message : 'Could not load this book.',
            onRetry: () => ref.invalidate(bookFileProvider(fileRef)),
          ),
          data: (file) => fmt == 'pdf'
              ? _PdfReader(file: file, book: book, progress: _progress)
              : _EpubReader(file: file, book: book, progress: _progress),
        );
  }
}

/// What the bottom bar shows: a fraction (0–100) and a left-hand label.
class _ReaderProgress {
  const _ReaderProgress(this.pct, this.label);
  final double pct;
  final String label;
}

/// Back · centered book title · "Aa" type control. Title is centered with a
/// Stack so the asymmetric side controls don't push it off-axis.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: 36,
        child: Stack(
          children: [
            Align(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(colors.text2),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.library),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: colors.text,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showTypographySheet(context),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Text('Aa', style: AppTypography.title3(colors.text)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PDF reader (pdfx). Horizontal page swipe; exact `page / total` progress read
/// from the document. Resumes from a `{"type":"pdf","page":N}` cursor.
class _PdfReader extends ConsumerStatefulWidget {
  const _PdfReader({
    required this.file,
    required this.book,
    required this.progress,
  });

  final File file;
  final Book book;
  final ValueNotifier<_ReaderProgress> progress;

  @override
  ConsumerState<_PdfReader> createState() => _PdfReaderState();
}

class _PdfReaderState extends ConsumerState<_PdfReader> {
  late final PdfController _controller;
  late final BookService _books;
  Timer? _saveTimer;
  int _page = 1;
  int _total = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _books = ref.read(bookServiceProvider);
    _page = _cursorPage(widget.book.cursor);
    _controller = PdfController(
      document: PdfDocument.openFile(widget.file.path),
      initialPage: _page,
    );
  }

  void _report() {
    final pct =
        _total > 0 ? (_page / _total * 100).clamp(0, 100).toDouble() : 0.0;
    widget.progress.value =
        _ReaderProgress(pct, 'Page $_page of ${_total == 0 ? '—' : _total}');
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveNow);
  }

  void _saveNow() {
    if (_total <= 0) return;
    final pct = (_page / _total * 100).clamp(0, 100).toDouble();
    unawaited(
      _books
          .update(
            widget.book.id,
            BookUpdateRequest(
              progressPct: pct,
              cursor: jsonEncode({'type': 'pdf', 'page': _page}),
            ),
          )
          .catchError((Object _) => widget.book), // best-effort
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveNow();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const _ReaderMessage(
        icon: Icons.broken_image_outlined,
        text: 'Could not open this PDF.',
      );
    }
    return PdfView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      onDocumentLoaded: (doc) {
        _total = doc.pagesCount;
        _report();
      },
      onPageChanged: (page) {
        _page = page;
        _report();
        _scheduleSave();
      },
      onDocumentError: (e) {
        if (mounted) setState(() => _error = '$e');
      },
    );
  }
}

enum _Annotate { tag, note }

/// EPUB reader (epub_view). Reflowable text; progress is chapter-based (coarse
/// but monotonic) and position resumes from a `{"type":"epub","cfi":"…"}` cursor.
class _EpubReader extends ConsumerStatefulWidget {
  const _EpubReader({
    required this.file,
    required this.book,
    required this.progress,
  });

  final File file;
  final Book book;
  final ValueNotifier<_ReaderProgress> progress;

  @override
  ConsumerState<_EpubReader> createState() => _EpubReaderState();
}

class _EpubReaderState extends ConsumerState<_EpubReader> {
  late final EpubController _controller;
  late final BookService _books;
  Timer? _saveTimer;
  int _total = 0;
  double _pct = 0;

  /// Latest selection plain text (epub_view gives no offsets, so the passage
  /// text + chapter title is the whole anchor we can capture).
  String? _selectedText;

  @override
  void initState() {
    super.initState();
    _books = ref.read(bookServiceProvider);
    _controller = EpubController(
      document: EpubDocument.openFile(widget.file),
      epubCfi: _cursorCfi(widget.book.cursor),
    );
    _controller.currentValueListenable.addListener(_onValue);
  }

  void _onValue() {
    final v = _controller.currentValueListenable.value;
    if (v == null) return;

    if (_total <= 0) {
      _total = _controller.tableOfContentsListenable.value.length;
    }
    final total = _total > 0 ? _total : 1;
    final within = v.progress.isFinite ? v.progress.clamp(0, 100) / 100 : 0.0;
    _pct = (((v.chapterNumber - 1) + within) / total * 100)
        .clamp(0, 100)
        .toDouble();

    final title = v.chapter?.Title?.trim();
    final label = (title != null && title.isNotEmpty)
        ? title
        : 'Chapter ${v.chapterNumber}';

    widget.progress.value = _ReaderProgress(_pct, label);
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveNow);
  }

  void _saveNow() {
    final cfi = _controller.generateEpubCfi();
    unawaited(
      _books
          .update(
            widget.book.id,
            BookUpdateRequest(
              progressPct: _pct,
              cursor:
                  cfi == null ? null : jsonEncode({'type': 'epub', 'cfi': cfi}),
            ),
          )
          .catchError((Object _) => widget.book), // best-effort
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _controller.currentValueListenable.removeListener(_onValue);
    _saveNow();
    _controller.dispose();
    super.dispose();
  }

  /// Selection → highlight (Tag) or highlight + note (Note). epub_view exposes no
  /// offsets, so a highlight is anchored by passage text + chapter title only.
  Future<void> _annotate(_Annotate action) async {
    final passage = _selectedText?.trim();
    if (passage == null || passage.isEmpty) return;
    final chapter =
        _controller.currentValueListenable.value?.chapter?.Title?.trim();
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (action == _Annotate.tag) {
        final tag = await showTagPickerSheet(context, passage: passage);
        if (tag == null || !mounted) return;
        await ref.read(highlightServiceProvider).create(HighlightCreateRequest(
              bookId: widget.book.id,
              colorTag: tag,
              passageText: passage,
              textChapterRef: chapter,
            ));
        if (!mounted) return;
        ref.invalidate(bookHighlightsProvider(widget.book.id));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Tagged “$tag”')));
      } else {
        final chapterPart = (chapter != null && chapter.isNotEmpty)
            ? ' · ${chapter.toUpperCase()}'
            : '';
        final reference = 'FROM ${widget.book.title.toUpperCase()}$chapterPart';
        final body =
            await showNoteSheet(context, passage: passage, reference: reference);
        if (body == null || !mounted) return;
        // A note anchors to a highlight; mint a neutral 'revisit' one for it.
        final highlight = await ref
            .read(highlightServiceProvider)
            .create(HighlightCreateRequest(
              bookId: widget.book.id,
              colorTag: 'revisit',
              passageText: passage,
              textChapterRef: chapter,
            ));
        await ref.read(noteServiceProvider).create(NoteCreateRequest(
              bookId: widget.book.id,
              highlightId: highlight.id,
              bodyMd: body,
            ));
        if (!mounted) return;
        ref.invalidate(bookHighlightsProvider(widget.book.id));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Note saved')));
      }
    } on ApiError catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readingSettingsProvider);
    final textStyle = settings.bodyTextStyle();
    final highlights =
        ref.watch(bookHighlightsProvider(widget.book.id)).valueOrNull ??
            const <Highlight>[];
    return SelectionArea(
      onSelectionChanged: (content) => _selectedText = content?.plainText,
      contextMenuBuilder: (context, state) =>
          AdaptiveTextSelectionToolbar.buttonItems(
        anchors: state.contextMenuAnchors,
        buttonItems: <ContextMenuButtonItem>[
          ContextMenuButtonItem(
            label: 'Tag',
            onPressed: () {
              state.hideToolbar();
              _annotate(_Annotate.tag);
            },
          ),
          ContextMenuButtonItem(
            label: 'Note',
            onPressed: () {
              state.hideToolbar();
              _annotate(_Annotate.note);
            },
          ),
          ...state.contextMenuButtonItems, // Copy / Select all
        ],
      ),
      child: EpubView(
        controller: _controller,
        onDocumentError: (_) {},
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: DefaultBuilderOptions(
            textStyle: textStyle,
            paragraphPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.readingHorizontal),
          ),
          chapterBuilder: (ctx, builders, document, chapters, paragraphs, index,
              chapterIndex, paragraphIndex, onExternalLinkPressed) {
            if (paragraphs.isEmpty) return const SizedBox.shrink();

            // Approximate inline marks: wrap the first plain-text occurrence of
            // each saved passage in a tag-colored <mark>. Misses when the quote
            // spans HTML tags or differs by entities/whitespace.
            var data = paragraphs[index].element.outerHtml;
            for (final h in highlights) {
              final passage = h.passageText;
              if (passage == null || passage.trim().isEmpty) continue;
              if (data.contains(passage)) {
                data = data.replaceFirst(passage,
                    '<mark class="hl-${h.colorTag ?? 'revisit'}">$passage</mark>');
              }
            }

            return Column(
              children: [
                if (chapterIndex >= 0 && paragraphIndex == 0)
                  builders.chapterDividerBuilder(chapters[chapterIndex]),
                Html(
                  data: data,
                  onLinkTap: (href, _, __) => onExternalLinkPressed(href ?? ''),
                  style: {
                    'html': Style(
                      padding: HtmlPaddings.only(
                        left: AppSpacing.readingHorizontal,
                        right: AppSpacing.readingHorizontal,
                      ),
                    ).merge(Style.fromTextStyle(textStyle)),
                    for (final tag in kTagNames)
                      '.hl-$tag': Style(
                        backgroundColor:
                            AppColors.forTag(tag).withValues(alpha: 0.35),
                      ),
                  },
                  extensions: [
                    TagExtension(
                      tagsToExtend: const {'img'},
                      builder: (imageContext) {
                        final url = imageContext.attributes['src']
                            ?.replaceAll('../', '');
                        final bytes = url == null
                            ? null
                            : document.Content?.Images?[url]?.Content;
                        if (bytes == null) return const SizedBox.shrink();
                        return Image(
                            image: MemoryImage(Uint8List.fromList(bytes)));
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Determinate download bar for the first fetch of a catalog book's text:
/// indeterminate while searching Gutendex, then "Downloading… N%".
class _GutenbergLoading extends ConsumerWidget {
  const _GutenbergLoading({required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final p = ref.watch(gutenbergProgressProvider(bookId));
    final downloading = p > 0;
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              child: ClipRRect(
                borderRadius: AppRadii.brFull,
                child: LinearProgressIndicator(
                  value: downloading ? p : null,
                  minHeight: 4,
                  color: colors.accent,
                  backgroundColor: colors.border,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              downloading
                  ? 'Downloading the text… ${(p * 100).round()}%'
                  : 'Finding a free copy…',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a book has no readable text (not on Gutenberg, no uploaded file).
class _NoReadableFile extends StatelessWidget {
  const _NoReadableFile({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 40, color: colors.text3),
            const SizedBox(height: AppSpacing.lg),
            Text('Nothing to read yet',
                textAlign: TextAlign.center,
                style: AppTypography.title3(colors.text)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This is a catalog entry. Upload an EPUB or PDF of '
              '“${book.title}” to read it here.',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(colors.text2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.message, required this.onRetry});
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
            Text("Couldn't open this book.",
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

class _ReaderMessage extends StatelessWidget {
  const _ReaderMessage({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colors.text3),
          const SizedBox(height: AppSpacing.lg),
          Text(text, style: AppTypography.subtitle(colors.text2)),
        ],
      ),
    );
  }
}

/// 2px progress bar (§9) over the page / chapter label and percent read.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.progressPct, required this.label});

  final double progressPct;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.readingHorizontal,
        AppSpacing.sm,
        AppSpacing.readingHorizontal,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadii.brFull,
            child: SizedBox(
              height: 2,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: colors.border)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (progressPct / 100).clamp(0, 1).toDouble(),
                    child: ColoredBox(color: colors.accent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(colors.text3),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('${progressPct.round()}%',
                  style: AppTypography.caption(colors.text3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Cursor (reading position) helpers ───────────────────────────────────────
// The backend stores `cursor` as opaque JSONB; we own the shape per format.

Map<String, dynamic>? _decodeCursor(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final v = jsonDecode(raw);
    return v is Map<String, dynamic> ? v : null;
  } catch (_) {
    return null;
  }
}

int _cursorPage(String? cursor) {
  final p = _decodeCursor(cursor)?['page'];
  if (p is num && p >= 1) return p.toInt();
  return 1;
}

String? _cursorCfi(String? cursor) {
  final c = _decodeCursor(cursor)?['cfi'];
  return (c is String && c.isNotEmpty) ? c : null;
}
