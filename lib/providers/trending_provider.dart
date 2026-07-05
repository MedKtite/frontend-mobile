import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';

/// Trending books for the Home screen — Project Gutenberg's most-downloaded
/// titles (Gutendex `sort=popular` ranks by real download counts). Every result
/// is public-domain, so each one is instantly readable in-app: tapping goes to
/// the catalog book page whose action is "Add to library — read free".
///
/// External host → bare [Dio] (no auth cookies), same as gutenberg_provider.
/// Not autoDispose: trending barely changes — one fetch per app session.
final trendingBooksProvider = FutureProvider<List<CatalogBook>>((ref) async {
  final dio = Dio();
  try {
    final res = await dio.get<Map<String, dynamic>>(
      'https://gutendex.com/books/',
      queryParameters: {'sort': 'popular', 'languages': 'en'},
      options: Options(receiveTimeout: const Duration(seconds: 15)),
    );
    final results = (res.data?['results'] as List?) ?? const [];

    return [
      for (final r in results.take(12))
        if (r is Map<String, dynamic> && (r['title'] as String?) != null)
          CatalogBook(
            title: r['title'] as String,
            author: _displayAuthor(r['authors']),
            gutenbergId: (r['id'] as num?)?.toInt(),
            source: 'GUTENBERG',
            contentAvailability: 'FULL', // on Gutenberg ⇒ readable in-app
            language: 'en',
            thumbnailUrl: _coverUrl(r),
            description: _summary(r),
            downloadCount: (r['download_count'] as num?)?.toInt(),
          ),
    ];
  } finally {
    dio.close();
  }
});

/// Gutendex lists authors as "Last, First" — flip to display order.
String? _displayAuthor(Object? authors) {
  if (authors is! List || authors.isEmpty) return null;
  final name = (authors.first as Map?)?['name'] as String?;
  if (name == null || name.isEmpty) return null;
  final parts = name.split(', ');
  return parts.length == 2 ? '${parts[1]} ${parts[0]}' : name;
}

/// Gutendex ships generated book summaries — use the first as the blurb.
String? _summary(Map<String, dynamic> r) {
  final s = r['summaries'];
  if (s is! List || s.isEmpty || s.first is! String) return null;
  return (s.first as String)
      .replaceAll(
          RegExp(r'\(This is an automatically generated summary\.?\)\s*$'), '')
      .trim();
}

String? _coverUrl(Map<String, dynamic> r) {
  final formats = r['formats'];
  final url = formats is Map ? formats['image/jpeg'] : null;
  return url is String && url.isNotEmpty ? url : null;
}
