import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';

/// "Recommended for you" for the Home screen — the backend re-runs the user's
/// recent catalog-search keywords against its (cached) Google Books layer and
/// marks anything in the Gutenberg index as readable in-app. For first-run
/// users with no search history, the backend returns broad starter picks using
/// locale/region-ish request hints.
///
/// Not autoDispose: one fetch per session is plenty; searching more updates
/// it on the next launch (or via ref.invalidate).
final recommendedBooksProvider = FutureProvider<List<CatalogBook>>(
  (ref) => ref.watch(catalogServiceProvider).recommendations(),
);
