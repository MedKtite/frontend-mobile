import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_response.dart';
import '../services/backend/search_service.dart';

/// Search results for [query] (scope=all so the chips can filter client-side and
/// show counts). Empty query → empty response. Surfaces the error as an
/// `AsyncError`. autoDispose so each transient query doesn't linger in the cache.
final searchResultsProvider =
    FutureProvider.autoDispose.family<SearchResponse, String>((ref, query) async {
  final q = query.trim();
  if (q.isEmpty) return const SearchResponse();
  return ref.watch(searchServiceProvider).search(q);
});
