// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// Web-only file — selected by routes.dart's conditional import. dart:html is
// deprecated in favor of package:web, but is stable and avoids a new dep for
// the handful of DOM touches here (iframe + postMessage + localStorage).

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/book.dart';
import '../../models/book_update_request.dart';
import '../../models/highlight_create_request.dart';
import '../../models/note_create_request.dart';
import '../../providers/book_highlights_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/reading_settings_provider.dart';
import '../../services/backend/book_service.dart';
import '../../services/backend/highlight_service.dart';
import '../../services/backend/note_service.dart';
import '../../widgets/note_sheet.dart';
import '../../widgets/tag_picker_sheet.dart';
import 'reader_shared.dart';

/// Web reader: the SAME reader.html + epub.js bundle the mobile app uses, but
/// hosted in an iframe (postMessage bridge) instead of a native WebView, with
/// book bytes fetched through the backend (same origin — no CORS) instead of
/// cached on disk. EPUB only; PDFs stay mobile.
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
  late final html.IFrameElement _iframe;
  late final String _viewType;
  StreamSubscription<html.MessageEvent>? _msgSub;
  final _iframeLoaded = Completer<void>();

  late final BookService _books;
  Timer? _saveTimer;
  Timer? _watchdog;

  bool _ready = false;
  bool _bootStarted = false;
  bool _takingLong = false;
  Brightness? _lastAppBrightness;
  int _page = 0;
  int _total = 0;
  int _chapter = 0;
  int _chapters = 0;
  double _pct = 0;
  double _chapterPct = 0;
  String? _cfi;
  String? _loadError;
  Book? _bookForSave; // the book the reader booted with (cursor saves)

  String? _selCfi;
  String? _selText;

  @override
  void initState() {
    super.initState();
    _books = ref.read(bookServiceProvider);
    _viewType = 'marginalia-reader-$hashCode';
    _iframe = html.IFrameElement()
      // Flutter web serves bundled assets under assets/ — hence the double.
      ..src = widget.sampleIdentifier != null
          ? 'assets/assets/reader/google_sample.html'
          : 'assets/assets/reader/reader.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    _iframe.onLoad.first.then((_) {
      if (!_iframeLoaded.isCompleted) _iframeLoaded.complete();
    });
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) => _iframe);
    _msgSub = html.window.onMessage.listen(_onWindowMessage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastAppBrightness != null &&
        _lastAppBrightness != brightness &&
        _ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyTheme();
      });
    }
    _lastAppBrightness = brightness;
  }

  // ── Bridge ────────────────────────────────────────────────────────────

  void _send(String cmd, [List<Object?> args = const []]) {
    _iframe.contentWindow
        ?.postMessage(jsonEncode({'cmd': cmd, 'args': args}), '*');
  }

  void _onWindowMessage(html.MessageEvent e) {
    final raw = e.data;
    if (raw is! String) return;
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return;
    }
    if (decoded is! Map) return;
    final data = decoded;

    switch (data['type']) {
      case 'ready':
        _watchdog?.cancel();
        if (mounted) {
          setState(() {
            _ready = true;
            _takingLong = false;
            _loadError = null;
          });
        }
        unawaited(_applySavedMarks());
      case 'total':
        final t = (data['total'] as num?)?.toInt() ?? 0;
        if (t > 0 && mounted) setState(() => _total = t);
      case 'location':
        _cfi = data['cfi'] as String?;
        final pct = (data['percent'] as num?)?.toDouble() ?? (_pct / 100);
        final page = (data['page'] as num?)?.toInt() ?? 0;
        final total = (data['total'] as num?)?.toInt() ?? 0;
        final chapter = (data['chapter'] as num?)?.toInt() ?? 0;
        final chapters = (data['chapters'] as num?)?.toInt() ?? 0;
        final chapterPct =
            (data['chapterPercent'] as num?)?.toDouble() ?? 0;
        if (mounted) {
          setState(() {
            _pct = (pct * 100).clamp(0, 100).toDouble();
            _chapterPct = (chapterPct * 100).clamp(0, 100).toDouble();
            if (page > 0) _page = page;
            if (total > 0) _total = total;
            if (chapter > 0) _chapter = chapter;
            if (chapters > 0) _chapters = chapters;
            _selCfi = null;
            _selText = null;
          });
        }
        _scheduleSave();
      case 'selected':
        final selCfi = data['cfiRange'] as String?;
        final selText = (data['text'] as String?)?.trim();
        if (selCfi != null && selText != null && selText.isNotEmpty && mounted) {
          setState(() {
            _selCfi = selCfi;
            _selText = selText;
          });
        }
      case 'selcleared':
        if (mounted) {
          setState(() {
            _selCfi = null;
            _selText = null;
          });
        }
      case 'paletteAction':
        switch (data['action']) {
          case 'quickTag':
            final tag = data['tag'] as String?;
            if (tag != null) unawaited(_quickTag(tag));
          case 'note':
            unawaited(_annotate(asNote: true));
          case 'tag':
            unawaited(_annotate(asNote: false));
          case 'copy':
            _copySelection();
        }
      case 'locations':
        final json = data['json'] as String?;
        final id = _bookForSave?.id;
        if (json != null && json.isNotEmpty && id != null) {
          try {
            html.window.localStorage['marg_locations_$id'] = json;
          } catch (_) {/* storage full — regenerate next time */}
        }
      case 'error':
        _watchdog?.cancel();
        if (mounted) {
          setState(() {
            _takingLong = false;
            _loadError =
                (data['message'] as String?) ?? 'Could not open this book.';
          });
        }
      case 'jserror':
        if (!_ready) {
          _watchdog?.cancel();
          if (mounted) {
            setState(() =>
                _loadError = 'Could not open this book. (${data['message']})');
          }
        }
    }
  }

  // ── Boot: resolve a same-origin EPUB URL → hand it to epub.js ─────────

  Future<void> _boot(Book book) async {
    _bookForSave = book;
    try {
      final epubUrl = await _resolveEpubUrl(book);
      await _iframeLoaded.future;

      final cfi = cursorCfi(book.cursor);
      final loc = html.window.localStorage['marg_locations_${book.id}'];
      _applyTheme();
      _send('loadBookUrl', [epubUrl, cfi, loc]);

      // A slow browser/device may need well over 30 seconds to parse a large
      // EPUB. This is a soft timeout: keep the iframe alive and let a late
      // `ready` recover instead of replacing it with a permanent error page.
      _watchdog = Timer(const Duration(seconds: 20), () {
        if (mounted && !_ready && _loadError == null) {
          setState(() => _takingLong = true);
        }
      });
    } on ApiError catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _loadError =
            'No readable copy found. Upload an EPUB on mobile to read it.');
      }
    }
  }

  Future<void> _bootSample() async {
    final identifier = widget.sampleIdentifier;
    if (identifier == null) return;
    try {
      await _iframeLoaded.future;
      if (!mounted) return;
      final settings = ref.read(readingSettingsProvider);
      final palette = settings.paletteFor(Theme.of(context).brightness);
      _send('loadSample', [
        identifier,
        cssHex(palette.bg),
        cssHex(palette.text),
        cssHex(palette.accent),
      ]);
      _watchdog = Timer(const Duration(seconds: 20), () {
        if (mounted && !_ready && _loadError == null) {
          setState(() => _takingLong = true);
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = 'Could not open this sample.');
      }
    }
  }

  /// epub.js fetches these same-origin URLs itself. This avoids downloading the
  /// whole archive into Dart, Base64-expanding it, and copying it into the
  /// iframe before parsing can even begin (especially expensive in iOS Safari).
  Future<String> _resolveEpubUrl(Book book) async {
    if (book.format == 'epub') {
      return '/me/books/${book.id}/file';
    }

    // Catalog/physical → find the Gutenberg id by title + author.
    final gutendex = Dio();
    try {
      final query = [book.title, book.author]
          .where((s) => s != null && s.trim().isNotEmpty)
          .join(' ');
      final search = await gutendex.get<Map<String, dynamic>>(
        'https://gutendex.com/books/',
        queryParameters: {'search': query},
      );
      final results = (search.data?['results'] as List?) ?? const [];
      int? id;
      for (final r in results) {
        if (r is Map && (r['formats'] as Map?)?['application/epub+zip'] != null) {
          id = (r['id'] as num?)?.toInt();
          if (id != null) break;
        }
      }
      if (id == null) throw Exception('no Gutenberg match');

      return '/me/catalog/gutenberg-epub/$id';
    } finally {
      gutendex.close();
    }
  }

  // ── Theme / progress / cursor (same protocol as mobile) ───────────────

  void _applyTheme() {
    final s = ref.read(readingSettingsProvider);
    final p = s.paletteFor(Theme.of(context).brightness);
    final family =
        s.font == ReaderFont.serif ? 'Georgia, serif' : 'system-ui, sans-serif';
    _send('setTheme', [
      cssHex(p.bg),
      cssHex(p.text),
      family,
      s.fontSize.round(),
      s.lineHeight,
      cssHex(p.accent),
    ]);
  }

  String get _label => _chapters > 0
      ? 'Chapter $_chapter/$_chapters'
      : _total > 0
          ? 'Page $_page of $_total'
          : 'Reading';

  void _next() {
    if (_ready) _send('nextPage');
  }

  void _prev() {
    if (_ready) _send('prevPage');
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveNow);
  }

  void _saveNow() {
    final cfi = _cfi;
    final book = _bookForSave;
    if (cfi == null || book == null) return;
    unawaited(
      _books
          .update(
            book.id,
            BookUpdateRequest(
              progressPct: _pct,
              cursor: jsonEncode({'type': 'epubjs', 'cfi': cfi}),
            ),
          )
          .catchError((Object _) => book), // best-effort
    );
  }

  // ── Selection → Tag / Note (same flows as mobile) ─────────────────────

  void _mark(String cfiRange, String tag) {
    _send('applyMark', [cfiRange, cssHex(AppColors.forTag(tag))]);
  }

  void _clearSelection() {
    _send('clearSelection');
    if (mounted) {
      setState(() {
        _selCfi = null;
        _selText = null;
      });
    }
  }

  Future<void> _applySavedMarks() async {
    final book = _bookForSave;
    if (book == null) return;
    try {
      final hs = await ref.read(bookHighlightsProvider(book.id).future);
      for (final h in hs) {
        final cfi = h.textChapterRef;
        if (cfi != null && cfi.startsWith('epubcfi(')) {
          _mark(cfi, h.colorTag ?? 'revisit');
        }
      }
    } catch (_) {/* marks are decoration — never block reading */}
  }

  Future<void> _quickTag(String tag) async {
    final cfiRange = _selCfi;
    final passage = _selText;
    final book = _bookForSave;
    if (cfiRange == null || passage == null || passage.isEmpty || book == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(highlightServiceProvider).create(HighlightCreateRequest(
            bookId: book.id,
            colorTag: tag,
            passageText: passage,
            textChapterRef: cfiRange,
          ));
      if (!mounted) return;
      _mark(cfiRange, tag);
      ref.invalidate(bookHighlightsProvider(book.id));
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

  Future<void> _annotate({required bool asNote}) async {
    final cfiRange = _selCfi;
    final passage = _selText;
    final book = _bookForSave;
    if (cfiRange == null || passage == null || passage.isEmpty || book == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (!asNote) {
        final tag = await showTagPickerSheet(context, passage: passage);
        if (tag == null || !mounted) return;
        await ref.read(highlightServiceProvider).create(HighlightCreateRequest(
              bookId: book.id,
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
        final reference = 'FROM ${book.title.toUpperCase()}';
        final body =
            await showNoteSheet(context, passage: passage, reference: reference);
        if (body == null || !mounted) return;
        final highlight = await ref
            .read(highlightServiceProvider)
            .create(HighlightCreateRequest(
              bookId: book.id,
              colorTag: 'revisit',
              passageText: passage,
              textChapterRef: cfiRange,
            ));
        await ref.read(noteServiceProvider).create(NoteCreateRequest(
              bookId: book.id,
              highlightId: highlight.id,
              bodyMd: body,
            ));
        if (!mounted) return;
        _mark(cfiRange, 'revisit');
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(appSnackBar('Note saved', SnackType.success));
      }
      ref.invalidate(bookHighlightsProvider(book.id));
      _clearSelection();
    } on ApiError catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(e.message, SnackType.error));
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _watchdog?.cancel();
    _saveTimer?.cancel();
    _saveNow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reader-theme override, same as mobile: recolor the reading surface.
    final settings = ref.watch(readingSettingsProvider);
    final p = settings.paletteFor(Theme.of(context).brightness);
    final base = context.appColors;
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

    ref.listen(readingSettingsProvider, (_, __) {
      if (_ready) _applyTheme();
    });

    return Theme(
      data: theme.copyWith(extensions: extensions),
      child: Builder(
        builder: (context) {
          final colors = context.appColors;
          final isSample = widget.sampleIdentifier != null;
          Book? displayBook;
          Book? readerBook;
          if (!isSample) {
            final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
            displayBook = bookAsync.valueOrNull ?? widget.initialBook;
            readerBook = bookAsync.valueOrNull ??
                (bookAsync.hasError ? widget.initialBook : null);
          }

          // Boot ONCE with the fresh book (latest saved cursor — resume).
          if (isSample && !_bootStarted) {
            _bootStarted = true;
            unawaited(_bootSample());
          } else if (readerBook != null && !_bootStarted) {
            final fmt = readerBook.format;
            if (fmt == 'epub' || fmt != 'pdf' && fmt != 'm4b' && fmt != 'mp3') {
              _bootStarted = true;
              unawaited(_boot(readerBook));
            }
          }

          final unsupported = displayBook != null &&
              (displayBook.format == 'pdf' ||
                  displayBook.format == 'm4b' ||
                  displayBook.format == 'mp3');

          return Scaffold(
            backgroundColor: colors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  ReaderTopBar(
                    title: isSample
                        ? widget.sampleTitle ?? 'Free sample'
                        : displayBook?.title ?? 'Reading',
                  ),
                  Expanded(
                    child: unsupported
                        ? const ReaderMessage(
                            icon: Icons.menu_book_outlined,
                            text:
                                'This format isn’t readable on web yet — open '
                                'it in the mobile app.',
                          )
                        : _loadError != null
                            ? ReaderMessage(
                                icon: Icons.menu_book_outlined,
                                text: _loadError!,
                              )
                            : LayoutBuilder(
                                builder: (context, box) => Stack(
                                  children: [
                                    Positioned.fill(
                                        child: ColoredBox(color: colors.bg)),
                                    HtmlElementView(viewType: _viewType),
                                    if (!_ready)
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                                color: colors.accent),
                                            if (_takingLong) ...[
                                              const SizedBox(
                                                  height: AppSpacing.md),
                                              Text(
                                                'Still opening this book…',
                                                style: AppTypography.subtitle(
                                                    colors.text2),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                  ),
                  if (!unsupported && !isSample)
                    PagedNavBar(
                      pct: _chapters > 0 ? _chapterPct : _pct,
                      label: _label,
                      onPrev: _ready ? _prev : null,
                      onNext: _ready ? _next : null,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
