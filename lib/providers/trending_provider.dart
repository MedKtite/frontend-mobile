import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_book.dart';

/// One cached Gutendex response shared by Trending and Top Authors. Both Home
/// sections need the same popular-books payload, so issuing independent startup
/// requests only increases the chance of a transient DNS/timeout/rate failure.
final popularGutenbergResultsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      );
      try {
        final res = await _getPopularBooks(dio);
        final results = (res.data?['results'] as List?) ?? const [];
        return [
          for (final result in results)
            if (result is Map<String, dynamic>) result,
        ];
      } finally {
        dio.close();
      }
    });

Future<Response<Map<String, dynamic>>> _getPopularBooks(Dio dio) async {
  const attempts = 3;
  for (var attempt = 1; attempt <= attempts; attempt++) {
    try {
      return await dio.get<Map<String, dynamic>>(
        'https://gutendex.com/books/',
        queryParameters: const {'sort': 'popular', 'languages': 'en'},
      );
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Gutendex popular books attempt $attempt/$attempts failed: '
          '${error.type} ${error.response?.statusCode ?? ''}',
        );
      }
      if (attempt == attempts || !_isTransient(error)) rethrow;
      await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    }
  }
  throw StateError('Gutendex retry loop completed unexpectedly.');
}

bool _isTransient(DioException error) {
  final status = error.response?.statusCode;
  return status == 429 ||
      (status != null && status >= 500) ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown;
}

/// Trending books for the Home screen — Project Gutenberg's most-downloaded
/// titles (Gutendex `sort=popular` ranks by real download counts). Every result
/// is public-domain, so each one is instantly readable in-app.
final trendingBooksProvider = FutureProvider<List<CatalogBook>>((ref) async {
  final results = await ref.watch(popularGutenbergResultsProvider.future);

  return [
    for (final r in results.take(12))
      if ((r['title'] as String?) != null)
        CatalogBook(
          title: r['title'] as String,
          author: _displayAuthor(r['authors']),
          gutenbergId: (r['id'] as num?)?.toInt(),
          source: 'GUTENBERG',
          contentAvailability: 'FULL',
          language: 'en',
          thumbnailUrl: _coverUrl(r),
          description: _summary(r),
          downloadCount: (r['download_count'] as num?)?.toInt(),
        ),
  ];
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
        RegExp(r'\(This is an automatically generated summary\.?\)\s*$'),
        '',
      )
      .trim();
}

String? _coverUrl(Map<String, dynamic> r) {
  final formats = r['formats'];
  final url = formats is Map ? formats['image/jpeg'] : null;
  return url is String && url.isNotEmpty ? url : null;
}
