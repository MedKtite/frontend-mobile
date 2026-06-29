import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';

/// Catalog (Google Books) search for [query]. Empty query → empty list.
/// Surfaces the error as an `AsyncError`. autoDispose so each transient query
/// doesn't linger in the cache.
final catalogSearchProvider =
    FutureProvider.autoDispose.family<List<CatalogBook>, String>((ref, query) async {
  final q = query.trim();
  if (q.isEmpty) return const [];
  return ref.watch(catalogServiceProvider).search(q);
});
