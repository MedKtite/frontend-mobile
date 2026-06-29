import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../services/backend/book_service.dart';

/// A single book by id. Used by the reading view when it's opened without the
/// full [Book] in hand — e.g. Home's "Continue reading" passes only the id,
/// whereas Library hands over the whole object via the route's `extra`.
/// Surfaces the error as an `AsyncError`; autoDispose so a closed reader
/// doesn't linger.
final bookByIdProvider =
    FutureProvider.autoDispose.family<Book, String>((ref, id) async {
  return ref.watch(bookServiceProvider).getOne(id);
});
