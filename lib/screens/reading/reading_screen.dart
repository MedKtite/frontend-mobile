import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/book.dart';
import '../../models/book_update_request.dart';
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
                  // EPUB has its own paginated footer (_PagedNavBar); only the
                  // PDF reader uses the shared progress bar.
                  if (displayBook?.format == 'pdf')
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
            // Inset past the side controls so a long title ellipsizes between
            // them instead of running underneath the back arrow / "Aa".
            Align(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(colors.text2),
                ),
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

/// Paginated EPUB reader (epub.js in a WebView). Real book-style page turns —
/// footer prev/next + left/right edge taps — resuming from a
/// `{"type":"epubjs","cfi":"…"}` cursor, reporting page X of Y and a 0–100%.
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
  late final WebViewController _web;
  late final BookService _books;
  Timer? _saveTimer;
  Timer? _watchdog; // caps how long the spinner may run before failing loudly

  bool _ready = false; // epub.js finished its first paginated render
  bool _booted = false; // loadBook() was injected once
  int _page = 0;
  int _total = 0;
  double _pct = 0;
  String? _cfi;
  String? _loadError; // set if epub.js can't load/parse the book

  // Active in-book text selection (epub.js `selected` event) → the floating
  // highlight palette (Figma 237:17), anchored to the selection's rect.
  String? _selCfi;
  String? _selText;
  Rect? _selRect;

  @override
  void initState() {
    super.initState();
    _books = ref.read(bookServiceProvider);
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('ReaderChannel', onMessageReceived: _onMessage)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => _boot()),
      );
    // Load separately from the cascade so a missing-asset failure (hot restart
    // after adding assets/) becomes a visible message, not an unhandled
    // exception + endless spinner.
    unawaited(
      _web.loadFlutterAsset('assets/reader/reader.html').catchError((Object _) {
        if (mounted) {
          setState(() => _loadError =
              'Reader assets aren’t in this build. Stop the app fully and '
              'run flutter run again — hot restart can’t bundle new assets.');
        }
      }),
    );
  }

  /// epub.js "locations" (page-count index) cached beside the EPUB — generating
  /// it parses the whole book, so it should only ever happen once per file.
  File get _locationsCache => File('${widget.file.path}.locations.json');

  /// Once the shell page loads, hand epub.js the EPUB bytes plus the saved CFI
  /// to resume from. Guarded — onPageFinished can fire more than once.
  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;
    final bytes = await widget.file.readAsBytes();
    // Encoding a multi-MB file is UI-thread jank (skipped frames on open) —
    // do it in a background isolate.
    final b64 = await compute(base64Encode, bytes);
    // One giant runJavaScript string is slow and can silently truncate on
    // Android — hand the book over in chunks instead. (base64 is quote-safe.)
    const chunk = 512 * 1024;
    for (var i = 0; i < b64.length; i += chunk) {
      final end = (i + chunk < b64.length) ? i + chunk : b64.length;
      await _web.runJavaScript("window.appendChunk('${b64.substring(i, end)}')");
    }
    final cfi = _cursorCfi(widget.book.cursor);
    final cfiArg = cfi == null ? 'null' : jsonEncode(cfi);
    var locArg = 'null';
    try {
      if (await _locationsCache.exists()) {
        locArg = jsonEncode(await _locationsCache.readAsString());
      }
    } catch (_) {/* no cache — epub.js regenerates */}
    _applyTheme();
    await _web.runJavaScript('window.loadBook($cfiArg, $locArg)');
    // If neither 'ready' nor an error ever arrives, don't spin forever.
    _watchdog = Timer(const Duration(seconds: 30), () {
      if (mounted && !_ready && _loadError == null) {
        setState(() => _loadError = 'This book took too long to open.');
      }
    });
  }

  /// Push current typography + palette into epub.js (bg, ink, family, size,
  /// line-height). Called on boot and whenever the "Aa" settings change. Real
  /// font files aren't in the WebView, so the family maps to a CSS generic.
  void _applyTheme() {
    final s = ref.read(readingSettingsProvider);
    final p = s.palette;
    final family =
        s.font == ReaderFont.serif ? 'Georgia, serif' : 'system-ui, sans-serif';
    _web.runJavaScript(
      'window.setTheme("${_cssHex(p.bg)}","${_cssHex(p.text)}",'
      '"$family",${s.fontSize.round()},${s.lineHeight},'
      '"${_cssHex(p.accent)}")',
    );
  }

  void _onMessage(JavaScriptMessage m) {
    final data = jsonDecode(m.message);
    if (data is! Map) return;
    switch (data['type']) {
      case 'ready':
        _watchdog?.cancel();
        if (mounted) setState(() => _ready = true);
        unawaited(_applySavedMarks());
      case 'total':
        final t = (data['total'] as num?)?.toInt() ?? 0;
        if (t > 0 && mounted) setState(() => _total = t);
      case 'location':
        _cfi = data['cfi'] as String?;
        final pct = (data['percent'] as num?)?.toDouble() ?? (_pct / 100);
        final page = (data['page'] as num?)?.toInt() ?? 0;
        final total = (data['total'] as num?)?.toInt() ?? 0;
        if (mounted) {
          setState(() {
            _pct = (pct * 100).clamp(0, 100).toDouble();
            if (page > 0) _page = page;
            if (total > 0) _total = total;
            // A page turn destroys any in-book selection.
            _selCfi = null;
            _selText = null;
            _selRect = null;
          });
        }
        widget.progress.value = _ReaderProgress(_pct, _label);
        _scheduleSave();
      case 'selected':
        final selCfi = data['cfiRange'] as String?;
        final selText = (data['text'] as String?)?.trim();
        if (selCfi != null &&
            selText != null &&
            selText.isNotEmpty &&
            mounted) {
          final rm = data['rect'];
          setState(() {
            _selCfi = selCfi;
            _selText = selText;
            _selRect = rm is Map
                ? Rect.fromLTWH(
                    (rm['x'] as num?)?.toDouble() ?? 0,
                    (rm['y'] as num?)?.toDouble() ?? 0,
                    (rm['w'] as num?)?.toDouble() ?? 0,
                    (rm['h'] as num?)?.toDouble() ?? 0,
                  )
                : null;
          });
        }
      case 'selcleared':
        if (mounted) {
          setState(() {
            _selCfi = null;
            _selText = null;
            _selRect = null;
          });
        }
      case 'locations':
        // Freshly generated page index — cache it so the next open skips the
        // full-book parse. Best-effort; a failed write just means regenerating.
        final json = data['json'] as String?;
        if (json != null && json.isNotEmpty) {
          unawaited(() async {
            try {
              await _locationsCache.writeAsString(json);
            } catch (_) {}
          }());
        }
      case 'error':
        // Surface a load/parse failure instead of spinning forever.
        _watchdog?.cancel();
        if (mounted) {
          setState(() => _loadError =
              (data['message'] as String?) ?? 'Could not open this book.');
        }
      case 'jserror':
        // Uncaught JS inside epub.js: fatal if the book never rendered,
        // harmless noise once it has.
        if (!_ready) {
          _watchdog?.cancel();
          if (mounted) {
            setState(() =>
                _loadError = 'Could not open this book. (${data['message']})');
          }
        }
    }
  }

  String get _label => _total > 0 ? 'Page $_page of $_total' : 'Reading';

  void _next() {
    if (_ready) _web.runJavaScript('window.nextPage()');
  }

  void _prev() {
    if (_ready) _web.runJavaScript('window.prevPage()');
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveNow);
  }

  void _saveNow() {
    final cfi = _cfi;
    if (cfi == null) return;
    unawaited(
      _books
          .update(
            widget.book.id,
            BookUpdateRequest(
              progressPct: _pct,
              cursor: jsonEncode({'type': 'epubjs', 'cfi': cfi}),
            ),
          )
          .catchError((Object _) => widget.book), // best-effort
    );
  }

  // ── Selection → Tag / Note ────────────────────────────────────────────

  /// Paint one highlight into the book text, tag-colored.
  void _mark(String cfiRange, String tag) {
    _web.runJavaScript('window.applyMark(${jsonEncode(cfiRange)}, '
        '"${_cssHex(AppColors.forTag(tag))}")');
  }

  void _clearSelection() {
    _web.runJavaScript('window.clearSelection()');
    if (mounted) {
      setState(() {
        _selCfi = null;
        _selText = null;
        _selRect = null;
      });
    }
  }

  /// Palette color dot: one tap = highlight with that tag, no sheet.
  Future<void> _quickTag(String tag) async {
    final cfiRange = _selCfi;
    final passage = _selText;
    if (cfiRange == null || passage == null || passage.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(highlightServiceProvider).create(HighlightCreateRequest(
            bookId: widget.book.id,
            colorTag: tag,
            passageText: passage,
            textChapterRef: cfiRange,
          ));
      if (!mounted) return;
      _mark(cfiRange, tag);
      ref.invalidate(bookHighlightsProvider(widget.book.id));
      _clearSelection();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar('Tagged “$tag”', SnackType.success));
    } on ApiError catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(e.message, SnackType.error));
    }
  }

  void _copySelection() {
    final text = _selText;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _clearSelection();
    showAppSnack(context, 'Copied', type: SnackType.success);
  }

  /// Re-paint saved highlights: any whose textChapterRef is an epub.js CFI
  /// range (that's where we store the anchor) renders inline on open.
  Future<void> _applySavedMarks() async {
    try {
      final hs = await ref.read(bookHighlightsProvider(widget.book.id).future);
      for (final h in hs) {
        final cfi = h.textChapterRef;
        if (cfi != null && cfi.startsWith('epubcfi(')) {
          _mark(cfi, h.colorTag ?? 'revisit');
        }
      }
    } catch (_) {/* marks are decoration — never block reading */}
  }

  /// Selection → highlight (Tag) or highlight + note (Note). The CFI range is
  /// stored in textChapterRef so the inline mark survives reopen + devices.
  Future<void> _annotate({required bool asNote}) async {
    final cfiRange = _selCfi;
    final passage = _selText;
    if (cfiRange == null || passage == null || passage.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (!asNote) {
        final tag = await showTagPickerSheet(context, passage: passage);
        if (tag == null || !mounted) return;
        await ref.read(highlightServiceProvider).create(HighlightCreateRequest(
              bookId: widget.book.id,
              colorTag: tag,
              passageText: passage,
              textChapterRef: cfiRange,
            ));
        if (!mounted) return;
        _mark(cfiRange, tag);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(appSnackBar('Tagged “$tag”', SnackType.success));
      } else {
        final reference = 'FROM ${widget.book.title.toUpperCase()}';
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
              textChapterRef: cfiRange,
            ));
        await ref.read(noteServiceProvider).create(NoteCreateRequest(
              bookId: widget.book.id,
              highlightId: highlight.id,
              bodyMd: body,
            ));
        if (!mounted) return;
        _mark(cfiRange, 'revisit');
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(appSnackBar('Note saved', SnackType.success));
      }
      ref.invalidate(bookHighlightsProvider(widget.book.id));
      _clearSelection();
    } on ApiError catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(e.message, SnackType.error));
    }
  }

  /// Palette anchor: 12px above the selection, flipped below it when there's
  /// no room, and always clamped inside the reader area. No rect → bottom.
  double _paletteTop(double maxHeight) {
    const palH = _HighlightPalette.height;
    final r = _selRect;
    if (r == null) return maxHeight - palH - AppSpacing.md;
    var top = r.top - palH - AppSpacing.md;
    if (top < AppSpacing.sm) top = r.bottom + AppSpacing.md;
    return top.clamp(AppSpacing.sm, maxHeight - palH - AppSpacing.sm);
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _saveTimer?.cancel();
    _saveNow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_loadError != null) {
      return _ReaderMessage(
        icon: Icons.menu_book_outlined,
        text: _loadError!,
      );
    }
    // Re-theme epub.js live when the "Aa" sheet changes font/size/theme.
    ref.listen(readingSettingsProvider, (_, __) {
      if (_ready) _applyTheme();
    });

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: colors.bg)),
                WebViewWidget(controller: _web),
                if (!_ready)
                  Center(
                    child: CircularProgressIndicator(color: colors.accent),
                  ),
                // Floating highlight palette (Figma 237:17), anchored just
                // above the selection; flips below it near the screen top.
                if (_selText != null)
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: _paletteTop(box.maxHeight),
                    child: Center(
                      child: _HighlightPalette(
                        onQuickTag: _quickTag,
                        onNote: () => _annotate(asNote: true),
                        onTag: () => _annotate(asNote: false),
                        onCopy: _copySelection,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _PagedNavBar(
          pct: _pct,
          label: _label,
          onPrev: _ready ? _prev : null,
          onNext: _ready ? _next : null,
        ),
      ],
    );
  }
}


/// Floating highlight palette (Figma 237:17): dark inverted-ink pill with five
/// quick-tag color dots (the first five system tags) · hairline divider ·
/// Note / Tag / Copy. One dot tap = highlight saved with that tag, no sheet.
class _HighlightPalette extends StatelessWidget {
  const _HighlightPalette({
    required this.onQuickTag,
    required this.onNote,
    required this.onTag,
    required this.onCopy,
  });

  static const double height = 60; // Figma: 22px dots + 19px top/bottom

  final ValueChanged<String> onQuickTag;
  final VoidCallback onNote;
  final VoidCallback onTag;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.text, // inverted ink, same trick as the primary button
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tag in kTagNames.take(5)) ...[
            GestureDetector(
              onTap: () => onQuickTag(tag),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.forTag(tag),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6), // Figma: 28px pitch on 22px dots
          ],
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1, height: 24, color: colors.bg),
          const SizedBox(width: AppSpacing.xs),
          _PaletteAction(label: 'Note', onTap: onNote),
          _PaletteAction(label: 'Tag', onTap: onTag),
          _PaletteAction(label: 'Copy', onTap: onCopy),
        ],
      ),
    );
  }
}

class _PaletteAction extends StatelessWidget {
  const _PaletteAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        // Figma 237:24-26 — Inter Medium 13 in the page (bg) color.
        child: Text(
          label,
          style: AppTypography.sans(TextStyle(
            color: colors.bg,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          )),
        ),
      ),
    );
  }
}

/// Footer page-navigation for the paginated EPUB reader: ‹ prev · progress bar +
/// "Page X of Y" + N% · next ›. Replaces the shared [_BottomBar] for EPUB.
class _PagedNavBar extends StatelessWidget {
  const _PagedNavBar({
    required this.pct,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final double pct;
  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: onPrev),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.brFull,
                    child: SizedBox(
                      height: 2,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: ColoredBox(color: colors.border)),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (pct / 100).clamp(0, 1).toDouble(),
                            child: ColoredBox(color: colors.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(colors.text3),
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
          ),
          _NavArrow(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

/// A round page-turn button; dimmed + inert until the book is ready.
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onTap != null;
    return Material(
      color: colors.surface2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: 24,
            color: enabled ? colors.text : colors.text3,
          ),
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

/// A [Color] as an opaque CSS `#rrggbb` for epub.js theme overrides.
String _cssHex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

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
  final m = _decodeCursor(cursor);
  // Only resume from CFIs we minted with epub.js. Old `{"type":"epub"}`
  // cursors came from epub_view, whose CFI generator differs — feeding one to
  // epub.js can crash its parser mid-display.
  if (m?['type'] != 'epubjs') return null;
  final c = m?['cfi'];
  return (c is String && c.isNotEmpty) ? c : null;
}
