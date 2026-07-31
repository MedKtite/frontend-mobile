import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';

/// Local Gutenberg feed for Trending. The mobile app never calls Gutenberg or
/// Gutendex directly; the backend serves the nightly PostgreSQL snapshot.
final popularGutenbergResultsProvider = FutureProvider<List<CatalogBook>>((
  ref,
) async {
  return ref.watch(catalogServiceProvider).trending(limit: 24);
});

final trendingBooksProvider = FutureProvider<List<CatalogBook>>((ref) async {
  final books = await ref.watch(popularGutenbergResultsProvider.future);
  return books.take(12).toList(growable: false);
});
