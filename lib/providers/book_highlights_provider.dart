import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/highlight.dart';
import '../services/backend/highlight_service.dart';

/// Every highlight for a book — read by the reader to re-mark saved passages
/// inline. Invalidate after creating a highlight to refresh the marks.
final bookHighlightsProvider =
    FutureProvider.autoDispose.family<List<Highlight>, String>((ref, bookId) {
  return ref.watch(highlightServiceProvider).listForBook(bookId);
});
