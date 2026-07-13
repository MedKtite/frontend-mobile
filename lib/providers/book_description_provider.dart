import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';

/// On-demand enrichment for catalog books whose search result arrived without
/// a description / rating / readers KPI / pages / year:
/// - Gutendex book detail → `summaries[0]` + `download_count` (readers).
/// - Backend `/me/catalog/lookup` (Google behind the server-side API key +
///   24h cache) → description, rating, ratings count, pages, year. Direct
///   client calls to Google are keyless and get rate-rejected (429), which is
///   why this goes through the backend.
///
/// Fields no source has stay null and the page hides those pieces.
typedef BookExtras = ({
  String? description,
  double? rating,
  int? ratingsCount,
  int? downloads,
  int? pageCount,
  int? year,
});

typedef ExtrasRef = ({int? gutenbergId, String? googleId, String? title, String? author});

final bookExtrasProvider =
    FutureProvider.family<BookExtras, ExtrasRef>((ref, key) async {
  // The two sources are independent. Start both immediately and merge their
  // results when ready instead of making the backend wait for Gutendex.
  final gutenbergFuture = _loadGutenbergExtras(key.gutenbergId);
  final catalogFuture =
      _loadCatalogExtras(ref.read(catalogServiceProvider), key);

  final gutenberg = await gutenbergFuture;
  final match = await catalogFuture;

  return (
    description: gutenberg.description ?? match?.description,
    rating: match?.averageRating,
    ratingsCount: match?.ratingsCount,
    downloads: gutenberg.downloads,
    pageCount: match?.pageCount,
    year: match?.publishedYear,
  );
});

Future<CatalogBook?> _loadCatalogExtras(
  CatalogService catalog,
  ExtrasRef key,
) async {
  if ((key.title ?? '').isEmpty) return null;
  try {
    return await catalog.lookup(
          title: _searchTitle(key.title!),
          author: _primaryAuthor(key.author),
        );
  } catch (_) {
    return null;
  }
}

Future<({String? description, int? downloads})> _loadGutenbergExtras(
  int? gutenbergId,
) async {
  String? description;
  int? downloads;

  // ── Gutendex: summary + download count ────────────────────────────────
  if (gutenbergId != null) {
    final dio = Dio();
    try {
      final res = await dio.get<Map<String, dynamic>>(
        'https://gutendex.com/books/$gutenbergId',
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );
      final s = res.data?['summaries'];
      if (s is List && s.isNotEmpty && s.first is String) {
        description = (s.first as String)
            // Gutendex appends a provenance note — drop it for the page.
            .replaceAll(
                RegExp(r'\(This is an automatically generated summary\.?\)\s*$'),
                '')
            .trim();
      }
      downloads = (res.data?['download_count'] as num?)?.toInt();
    } on DioException {
      // fall through — the backend lookup may still fill gaps
    } finally {
      dio.close();
    }
  }

  return (description: description, downloads: downloads);
}

/// "The City of God, Volume I" → "The City of God"; also drops "; Or, …"
/// subtitle tails ("Moby Dick; Or, The Whale" → "Moby Dick").
String _searchTitle(String raw) {
  var t = raw.split(';').first;
  t = t.replaceAll(
      RegExp(r',?\s*(volume|vol\.?|book|part)\s+[ivxlcdm0-9]+\s*$',
          caseSensitive: false),
      '');
  t = t.trim();
  return t.isEmpty ? raw.trim() : t;
}

/// Gutenberg authors arrive "Last, First, Epithet" — the surname alone
/// ("Augustine", "Melville") is the reliable inauthor: term.
String? _primaryAuthor(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final first = raw.split(',').first.trim();
  return first.isEmpty ? null : first;
}
