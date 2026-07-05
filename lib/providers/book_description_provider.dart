import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    FutureProvider.autoDispose.family<BookExtras, ExtrasRef>((ref, key) async {
  String? description;
  int? downloads;

  // ── Gutendex: summary + download count ────────────────────────────────
  if (key.gutenbergId != null) {
    final dio = Dio();
    try {
      final res = await dio.get<Map<String, dynamic>>(
        'https://gutendex.com/books/${key.gutenbergId}',
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

  // ── Backend edition lookup: pages/year/rating (+ description fallback) ─
  double? rating;
  int? ratingsCount;
  int? pageCount;
  int? year;
  if ((key.title ?? '').isNotEmpty) {
    try {
      final match = await ref.read(catalogServiceProvider).lookup(
            title: _searchTitle(key.title!),
            author: _primaryAuthor(key.author),
          );
      if (match != null) {
        description ??= match.description;
        rating = match.averageRating;
        ratingsCount = match.ratingsCount;
        pageCount = match.pageCount;
        year = match.publishedYear;
      }
    } catch (_) {
      // best-effort — whatever Gutendex gave stands
    }
  }

  return (
    description: description,
    rating: rating,
    ratingsCount: ratingsCount,
    downloads: downloads,
    pageCount: pageCount,
    year: year,
  );
});

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
