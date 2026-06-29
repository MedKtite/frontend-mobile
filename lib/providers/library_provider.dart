import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../services/backend/book_service.dart';

/// The user's whole library (`GET /me/books`). Surfaces the error as an
/// `AsyncError`; `ref.invalidate(libraryBooksProvider)` retries. Cached across
/// tab switches (not autoDispose).
final libraryBooksProvider = FutureProvider<List<Book>>((ref) async {
  return ref.watch(bookServiceProvider).list();
});
