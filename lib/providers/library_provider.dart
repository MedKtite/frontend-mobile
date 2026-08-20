import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../services/backend/book_service.dart';

/// The user's whole library (`GET /me/books`). Surfaces the error as an
/// `AsyncError`; `ref.invalidate(libraryBooksProvider)` retries. Cached across
/// tab switches. Automatically polls every 4 seconds if any book is currently
/// in pending/processing ingestion state.
final libraryBooksProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(bookServiceProvider).list();

  final hasActiveProcessing = books.any(
    (b) =>
        b.processingStatus == 'pending' || b.processingStatus == 'processing',
  );

  if (hasActiveProcessing) {
    final timer = Timer(const Duration(seconds: 4), () {
      ref.invalidateSelf();
    });
    ref.onDispose(timer.cancel);
  }

  return books;
});
