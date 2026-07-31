import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
import '../../models/reader_package.dart';
import '../../providers/book_file_provider.dart';
import '../../providers/book_highlights_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/reading_mini_provider.dart';
import '../../providers/reading_settings_provider.dart';
import '../../providers/state/reading_mini_state.dart';
import '../../services/backend/book_service.dart';
import '../../services/backend/highlight_service.dart';
import '../../services/backend/note_service.dart';
import '../../widgets/note_sheet.dart';
import '../../widgets/tag_picker_sheet.dart';
import 'reader_shared.dart';

/// Reader screen. Keeps the chrome (back · title · Aa, and the bottom progress
/// bar) and routes the book body to the right reader widget:
/// • reader-v1 package (uploaded EPUB/PDF or Gutenberg pipeline) → [_NativeReader]
/// • PDF original → [_PdfReader]
/// • Google Books free sample → [_GoogleBooksSampleReader]
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({
    super.key,
    required this.bookId,
    this.initialBook,
    this.sampleIdentifier,
    this.sampleTitle,
  });

  final String bookId;
  final Book? initialBook;
  final String? sampleIdentifier;
  final String? sampleTitle;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  /// The active reader pushes its position here; only the bottom bar listens, so
  /// the page/EPUB view itself never rebuilds on a progress tick.
  late final ValueNotifier<ReaderProgress> _progress = ValueNotifier(
    ReaderProgress(widget.initialBook?.progressPct ?? 0, ''),
  );
  late final HomeController _homeController;
  late final StateController<ReadingMiniSession?> _miniController;

  /// Last book we showed — the "continue reading" mini bar needs it at dispose.
  Book? _lastBook;

  @override
  void initState() {
    super.initState();
    _homeController = ref.read(homeProvider.notifier);
    _miniController = ref.read(readingMiniProvider.notifier);
    // Entering the reader retires its own mini bar (deferred: provider state
    // can't change while the first frame is building).
    Future.microtask(() => _miniController.state = null);
  }

  @override
  void dispose() {
    // Leaving mid-book docks the "continue reading" bar above the nav. Only
    // when a reader actually reported a position — an unreadable catalog
    // entry (empty label) gets no bar.
    final book = _lastBook;
    final pr = _progress.value;
    if (book != null && pr.label.isNotEmpty) {
      _homeController.updateReadingProgress(book.id, pr.pct);
      Future.microtask(
        () => _miniController.state = ReadingMiniSession(
          book: book.copyWith(progressPct: pr.pct),
          pct: pr.pct,
          label: pr.label,
        ),
      );
    }
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readingSettingsProvider);
    final p = settings.paletteFor(Theme.of(context).brightness);
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
    final extensions =
        theme.extensions.values.where((e) => e is! AppColorsExtension).toList()
          ..add(readerColors);

    return Theme(
      data: theme.copyWith(extensions: extensions),
      child: Builder(
        builder: (context) {
          final colors = context.appColors;
          final sampleIdentifier = widget.sampleIdentifier;
          if (sampleIdentifier != null) {
            return Scaffold(
              backgroundColor: colors.bg,
              body: SafeArea(
                child: Column(
                  children: [
                    ReaderTopBar(title: widget.sampleTitle ?? 'Free sample'),
                    Expanded(
                      child: _GoogleBooksSampleReader(
                        identifier: sampleIdentifier,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Chrome shows instantly from initialBook; the reader body waits for
          // the fresh fetch so it's built ONCE with the latest saved cursor
          // (resume). initialBook from the library can carry a stale position,
          // and re-building the reader mid-life would let a stale instance's
          // dispose clobber the good cursor.
          final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
          final displayBook = bookAsync.valueOrNull ?? widget.initialBook;
          final readerBook =
              bookAsync.valueOrNull ??
              (bookAsync.hasError ? widget.initialBook : null);
          _lastBook = displayBook ?? _lastBook;

          return Scaffold(
            backgroundColor: colors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  ReaderTopBar(title: displayBook?.title ?? 'Reading'),
                  Expanded(
                    child: readerBook != null
                        ? _body(context, readerBook)
                        : const _TextLoading(),
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
    if (book == null) {
      return const _TextLoading();
    }

    // Show preparing screen whenever processing is in flight or failed,
    // regardless of format (covers both uploaded EPUB/PDF and Gutenberg
    // catalog books that the Python pipeline is still working on).
    final status = book.processingStatus;
    if (status != null && status != 'ready') {
      return ReaderError(
        message: status == 'failed'
            ? (book.processingError ?? 'Book processing failed.')
            : 'Preparing this book for reading…',
        onRetry: () => ref.invalidate(bookByIdProvider(book.id)),
      );
    }

    // All readable formats — uploaded EPUB/PDF and Gutenberg catalog books
    // that have been processed into a reader-v1 package — go through the
    // backend reading-download-url endpoint, which returns the best available
    // format (reader-v1 > epub > pdf).
    final fileRef = (id: book.id, format: book.format ?? 'reader-v1');
    return ref
        .watch(bookFileProvider(fileRef))
        .when(
          loading: () => const _TextLoading(),
          error: (e, _) => ReaderError(
            message: e is ApiError ? e.message : 'Could not load this book.',
            onRetry: () => ref.invalidate(bookFileProvider(fileRef)),
          ),
          data: (readable) => switch (readable.format) {
            'pdf' => _PdfReader(
              file: readable.file,
              book: book,
              progress: _progress,
            ),
            'reader-v1' => _NativeReader(
              file: readable.file,
              book: book,
              progress: _progress,
            ),
            _ => ReaderError(
              message: 'This book is still being prepared for reading.',
              onRetry: () => ref.invalidate(bookFileProvider(fileRef)),
            ),
          },
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
  final ValueNotifier<ReaderProgress> progress;

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
    _page = cursorPage(widget.book.cursor);
    _controller = PdfController(
      document: PdfDocument.openFile(widget.file.path),
      initialPage: _page,
    );
  }

  void _report() {
    final pct = _total > 0
        ? (_page / _total * 100).clamp(0, 100).toDouble()
        : 0.0;
    widget.progress.value = ReaderProgress(
      pct,
      'Page $_page of ${_total == 0 ? '—' : _total}',
    );
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
          .then((_) {
            if (mounted) ref.invalidate(libraryBooksProvider);
          })
          .catchError((Object _) {}), // best-effort
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
      return const ReaderMessage(
        icon: Icons.broken_image_outlined,
        text: 'Could not open this PDF.',
      );
    }
    return Column(
      children: [
        Expanded(
          child: PdfView(
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
          ),
        ),
        ValueListenableBuilder<ReaderProgress>(
          valueListenable: widget.progress,
          builder: (_, progress, __) =>
              _BottomBar(progressPct: progress.pct, label: progress.label),
        ),
      ],
    );
  }
}

/// Native semantic reader for reader-v1 packages. No WebView or book HTML is
/// rendered: the package contains only normalized blocks and local assets.
class _NativeReader extends ConsumerStatefulWidget {
  const _NativeReader({
    required this.file,
    required this.book,
    required this.progress,
  });

  final File file;
  final Book book;
  final ValueNotifier<ReaderProgress> progress;

  @override
  ConsumerState<_NativeReader> createState() => _NativeReaderState();
}

class _NativeReaderState extends ConsumerState<_NativeReader> {
  ReaderPackage? _package;
  String? _error;
  String? _selectedChapter;
  ReaderBlock? _selectedBlock;
  TextSelection? _selection;
  String? _selectedText;
  Timer? _saveTimer;
  late final BookService _books;

  @override
  void initState() {
    super.initState();
    _books = ref.read(bookServiceProvider);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final package = ReaderPackage.fromBytes(await widget.file.readAsBytes());
      if (mounted) setState(() => _package = package);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open this book right now.');
      }
    }
  }

  void _onScroll(ScrollNotification notification) {
    if (notification.metrics.maxScrollExtent <= 0 || _package == null) return;
    final pct =
        (notification.metrics.pixels /
                notification.metrics.maxScrollExtent *
                100)
            .clamp(0, 100)
            .toDouble();
    widget.progress.value = ReaderProgress(pct, 'Reading');
    _scheduleSave(pct);
  }

  void _scheduleSave(double pct) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      unawaited(
        _books
            .update(
              widget.book.id,
              BookUpdateRequest(
                progressPct: pct,
                cursor: jsonEncode({'type': 'reader-v1', 'progressPct': pct}),
              ),
            )
            .then<void>(
              (_) {},
              onError: (Object error, StackTrace stack) {
                debugPrint('[Reader] Cursor sync failed: $error');
              },
            ),
      );
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _quickTag(String tag) async {
    final chapter = _selectedChapter;
    final block = _selectedBlock;
    final selection = _selection;
    final passage = _selectedText;
    if (chapter == null ||
        block == null ||
        selection == null ||
        passage == null) {
      return;
    }
    final start = selection.start;
    final end = selection.end;
    try {
      await ref
          .read(highlightServiceProvider)
          .create(
            HighlightCreateRequest(
              bookId: widget.book.id,
              colorTag: tag,
              textChapterRef: '$chapter:${block.id}',
              textStartOffset: start,
              textEndOffset: end,
              passageText: passage,
            ),
          );
      if (!mounted) return;
      ref.invalidate(bookHighlightsProvider(widget.book.id));
      _clearSelection();
      showAppSnack(context, 'Tagged “$tag”', type: SnackType.success);
    } on ApiError catch (e) {
      if (mounted) showAppSnack(context, e.message, type: SnackType.error);
    }
  }

  Future<void> _annotate({required bool asNote}) async {
    final chapter = _selectedChapter;
    final block = _selectedBlock;
    final selection = _selection;
    final passage = _selectedText;
    if (chapter == null ||
        block == null ||
        selection == null ||
        passage == null) {
      return;
    }
    try {
      final tag = asNote
          ? 'revisit'
          : await showTagPickerSheet(context, passage: passage);
      if (tag == null || !mounted) return;
      final highlight = await ref
          .read(highlightServiceProvider)
          .create(
            HighlightCreateRequest(
              bookId: widget.book.id,
              colorTag: tag,
              textChapterRef: '$chapter:${block.id}',
              textStartOffset: selection.start,
              textEndOffset: selection.end,
              passageText: passage,
            ),
          );
      if (asNote) {
        final body = await showNoteSheet(
          context,
          passage: passage,
          reference: 'FROM ${widget.book.title.toUpperCase()}',
        );
        if (body != null && mounted) {
          await ref
              .read(noteServiceProvider)
              .create(
                NoteCreateRequest(
                  bookId: widget.book.id,
                  highlightId: highlight.id,
                  bodyMd: body,
                ),
              );
        }
      }
      if (!mounted) return;
      ref.invalidate(bookHighlightsProvider(widget.book.id));
      _clearSelection();
      showAppSnack(
        context,
        asNote ? 'Note saved' : 'Tagged “$tag”',
        type: SnackType.success,
      );
    } on ApiError catch (e) {
      if (mounted) showAppSnack(context, e.message, type: SnackType.error);
    }
  }

  void _copySelection() {
    final text = _selectedText;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    _clearSelection();
    showAppSnack(context, 'Copied', type: SnackType.success);
  }

  void _clearSelection() {
    if (mounted) {
      setState(() {
        _selection = null;
        _selectedChapter = null;
        _selectedBlock = null;
        _selectedText = null;
      });
    }
  }

  void _onSelection(
    String chapterId,
    ReaderBlock block,
    TextSelection selection,
  ) {
    if (selection.isCollapsed ||
        selection.start < 0 ||
        selection.end > block.text.length) {
      _clearSelection();
      return;
    }
    setState(() {
      _selectedChapter = chapterId;
      _selectedBlock = block;
      _selection = selection;
      _selectedText = block.text.substring(selection.start, selection.end);
    });
  }

  TextStyle _styleFor(BuildContext context, ReaderBlock block) {
    final colors = context.appColors;
    return switch (block.type) {
      'heading' => AppTypography.title3(colors.text),
      'quote' => AppTypography.subtitle(colors.text2),
      'listItem' => AppTypography.bodySerif(colors.text),
      _ => AppTypography.bodySerif(colors.text),
    };
  }

  Widget _block(BuildContext context, String chapterId, ReaderBlock block) {
    if (block.type == 'divider') {
      return const Divider(height: AppSpacing.xl);
    }
    if (block.type == 'image' && block.asset != null) {
      final bytes = _package?.assets[block.asset!];
      return bytes == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Image.memory(bytes, fit: BoxFit.contain),
            );
    }
    if (block.type == 'table') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: DataTable(
          columns: [
            for (
              var i = 0;
              i < (block.rows.isEmpty ? 0 : block.rows.first.length);
              i++
            )
              DataColumn(label: Text('')),
          ],
          rows: [
            for (final row in block.rows)
              DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
          ],
        ),
      );
    }
    final text = block.type == 'listItem' ? '• ${block.text}' : block.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SelectableText.rich(
        TextSpan(text: text, style: _styleFor(context, block)),
        onSelectionChanged: (selection, _) =>
            _onSelection(chapterId, block, selection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final package = _package;
    if (_error != null) {
      return ReaderMessage(icon: Icons.menu_book_outlined, text: _error!);
    }
    if (package == null) return const ReaderTextLoading();
    final blocks = <({String chapterId, ReaderBlock block})>[];
    for (final chapter in package.chapters) {
      blocks.add((
        chapterId: chapter.id,
        block: ReaderBlock(
          id: '${chapter.id}-title',
          type: 'heading',
          text: chapter.title,
        ),
      ));
      for (final block in chapter.blocks) {
        blocks.add((chapterId: chapter.id, block: block));
      }
    }
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _onScroll(notification);
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.readingHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    final item = blocks[index];
                    return _block(context, item.chapterId, item.block);
                  },
                ),
              ),
            ),
            ValueListenableBuilder<ReaderProgress>(
              valueListenable: widget.progress,
              builder: (_, progress, __) => ReaderProgressBar(
                pct: progress.pct,
                label: progress.label.isEmpty ? 'Reading' : progress.label,
              ),
            ),
          ],
        ),
        if (_selectedText != null)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.xxl,
            child: Center(
              child: HighlightPalette(
                onQuickTag: _quickTag,
                onNote: () => _annotate(asNote: true),
                onTag: () => _annotate(asNote: false),
                onCopy: _copySelection,
              ),
            ),
          ),
      ],
    );
  }
}


class _GoogleBooksSampleReader extends StatefulWidget {
  const _GoogleBooksSampleReader({required this.identifier});

  final String identifier;

  @override
  State<_GoogleBooksSampleReader> createState() =>
      _GoogleBooksSampleReaderState();
}

class _GoogleBooksSampleReaderState extends State<_GoogleBooksSampleReader> {
  late final WebViewController _web;
  bool _booted = false;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'SampleChannel',
        onMessageReceived: (message) {
          Object? decoded;
          try {
            decoded = jsonDecode(message.message);
          } catch (_) {
            return;
          }
          if (decoded is! Map || !mounted) return;
          switch (decoded['type']) {
            case 'ready':
              setState(() {
                _ready = true;
                _error = null;
              });
            case 'error':
              final message = decoded['message'] as String?;
              setState(() {
                _ready = false;
                _error =
                    message ?? 'This sample cannot be displayed in the app.';
              });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _boot(),
          onNavigationRequest: (request) {
            if (!request.isMainFrame ||
                request.url.startsWith('file:') ||
                request.url.startsWith('about:')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
    unawaited(
      _web.loadFlutterAsset('assets/reader/google_sample.html').catchError((
        Object _,
      ) {
        if (mounted) {
          setState(
            () => _error =
                'Could not open this sample right now. Please try again.',
          );
        }
      }),
    );
  }

  Future<void> _boot() async {
    if (_booted || !mounted) return;
    _booted = true;
    final settings = ProviderScope.containerOf(
      context,
    ).read(readingSettingsProvider);
    final palette = settings.paletteFor(Theme.of(context).brightness);
    await _web.runJavaScript(
      'window.loadSample(${jsonEncode(widget.identifier)},'
      '${jsonEncode(cssHex(palette.bg))},'
      '${jsonEncode(cssHex(palette.text))},'
      '${jsonEncode(cssHex(palette.accent))})',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_error != null) {
      return ReaderMessage(icon: Icons.menu_book_outlined, text: _error!);
    }
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.bg)),
        WebViewWidget(controller: _web),
        if (!_ready) const Positioned.fill(child: _TextLoading()),
      ],
    );
  }
}

/// One stable loading surface for every text-reader preparation step.
class _TextLoading extends StatelessWidget {
  const _TextLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                child: ClipRRect(
                  borderRadius: AppRadii.brFull,
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    color: colors.accent,
                    backgroundColor: colors.border,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Loading text…',
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(colors.text2),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 40, color: colors.text3),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nothing to read yet',
              textAlign: TextAlign.center,
              style: AppTypography.title3(colors.text),
            ),
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
              Text(
                '${progressPct.round()}%',
                style: AppTypography.caption(colors.text3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
