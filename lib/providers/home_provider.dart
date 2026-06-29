import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import '../widgets/book_cover.dart';
import '../models/book.dart';
import '../models/highlight.dart';
import '../services/backend/book_service.dart';
import '../services/backend/highlight_service.dart';
import 'state/home_state.dart';

/// Loads the Home tab from the backend: the user's library (`/me/books`) and
/// recent highlights (`/me/highlights`), then derives the resume/resurface
/// surfaces. Requires an authenticated session (cookies) — reached after login.
class HomeController extends StateNotifier<HomeState> {
  HomeController(this._books, this._highlights) : super(const HomeState.loading()) {
    load();
  }

  final BookService _books;
  final HighlightService _highlights;

  Future<void> load() async {
    state = const HomeState.loading();

    final List<Book> books;
    try {
      books = await _books.list();
    } on ApiError catch (e) {
      state = HomeState.error(e.message);
      return;
    }

    if (books.isEmpty) {
      state = const HomeState.empty();
      return;
    }

    // Highlights are best-effort — a missing passage shouldn't blank Home.
    List<Highlight> highlights;
    try {
      highlights = await _highlights.listRecent();
    } on ApiError {
      highlights = const <Highlight>[];
    }

    state = HomeState.loaded(
      continueReading: _pickContinueReading(books),
      listening: _pickListening(books),
      passage: _pickPassage(highlights, books),
    );
  }

  ContinueReading? _pickContinueReading(List<Book> books) {
    // Only in-app readable formats — a physical book has no file to resume.
    final b = _mostRecentlyOpened(
      books.where((b) => _isText(b.format) && _inProgress(b.status)),
    );
    if (b == null) return null;
    return ContinueReading(
      id: b.id,
      title: b.title,
      author: b.author ?? '',
      coverBg: coverColorFromHex(b.coverDominantColor),
      coverFg: coverFgFor(b.coverDominantColor),
      progress: b.progressPct ?? 0,
    );
  }

  ListeningItem? _pickListening(List<Book> books) {
    final b = _mostRecentlyOpened(
      books.where((b) => _isAudio(b.format) && _inProgress(b.status)),
    );
    if (b == null) return null;
    return ListeningItem(
      title: b.title,
      author: b.author ?? '',
      coverBg: coverColorFromHex(b.coverDominantColor),
      coverFg: coverFgFor(b.coverDominantColor),
    );
  }

  HomePassage? _pickPassage(List<Highlight> highlights, List<Book> books) {
    for (final h in highlights) {
      final text = h.passageText;
      if (text == null || text.isEmpty) continue;
      final book = _bookById(books, h.bookId);
      final ref = h.textChapterRef;
      final source = [
        if (book != null) book.title,
        if (ref != null && ref.isNotEmpty) ref,
      ].join(' · ');
      return HomePassage(
        text: text,
        source: source,
        colorTag: h.colorTag ?? 'revisit',
      );
    }
    return null;
  }

  static bool _isAudio(String? format) => format == 'm4b' || format == 'mp3';
  static bool _isText(String? format) => format == 'epub' || format == 'pdf';
  static bool _inProgress(String? status) =>
      status != 'finished' && status != 'archived';

  static Book? _bookById(List<Book> books, String id) {
    for (final b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Newest by [Book.lastOpenedAt] (ISO-8601 strings sort chronologically),
  /// falling back to createdAt.
  static Book? _mostRecentlyOpened(Iterable<Book> books) {
    Book? best;
    for (final b in books) {
      if (best == null) {
        best = b;
      } else if (_openedKey(b).compareTo(_openedKey(best)) > 0) {
        best = b;
      }
    }
    return best;
  }

  static String _openedKey(Book b) => b.lastOpenedAt ?? b.createdAt ?? '';
}

final homeProvider =
    StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(
    ref.watch(bookServiceProvider),
    ref.watch(highlightServiceProvider),
  ),
);
