import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/highlight.dart';
import '../models/note.dart';
import '../models/tag.dart';
import '../services/backend/highlight_service.dart';
import '../services/backend/note_service.dart';
import '../services/backend/tag_service.dart';

/// Data for the Search screen's browse tabs (Tags · Notes · Saved).
/// All plain FutureProviders — call [refreshAnnotations] after any mutation
/// (save toggle, new highlight) so every tab agrees again.

/// The 7 system tags + the user's custom tags.
final tagsProvider = FutureProvider<List<Tag>>(
    (ref) => ref.watch(tagServiceProvider).listVisible());

/// Highlight count per tag id (absent = zero).
final tagCountsProvider = FutureProvider<Map<String, int>>(
    (ref) => ref.watch(tagServiceProvider).counts());

/// Every highlight carrying one tag, newest first.
final tagHighlightsProvider = FutureProvider.family<List<Highlight>, String>(
    (ref, tagId) => ref.watch(highlightServiceProvider).listByTag(tagId));

/// The user's most-recent highlights across all books (server caps at 100).
final allHighlightsProvider = FutureProvider<List<Highlight>>(
    (ref) => ref.watch(highlightServiceProvider).listRecent(limit: 100));

/// The user's most-recent notes across all books.
final allNotesProvider = FutureProvider<List<Note>>(
    (ref) => ref.watch(noteServiceProvider).listRecent(limit: 200));

/// Saved collection — bookmarked highlights and notes.
final savedHighlightsProvider = FutureProvider<List<Highlight>>(
    (ref) => ref.watch(highlightServiceProvider).listSaved());

final savedNotesProvider = FutureProvider<List<Note>>(
    (ref) => ref.watch(noteServiceProvider).listSaved());

/// Re-fetches every annotation list (after a save toggle, a new highlight
/// made in the reader, a deleted note, …). Called from widgets.
void refreshAnnotations(WidgetRef ref) {
  ref.invalidate(tagsProvider);
  ref.invalidate(tagCountsProvider);
  ref.invalidate(tagHighlightsProvider);
  ref.invalidate(allHighlightsProvider);
  ref.invalidate(allNotesProvider);
  ref.invalidate(savedHighlightsProvider);
  ref.invalidate(savedNotesProvider);
}
