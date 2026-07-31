import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/catalog_book.dart';
import '../../models/librivox_audiobook.dart';

typedef CatalogTopAuthor = ({String name, String? imageUrl, int downloadCount});

/// Raw HTTP for /me/catalog (Gutenberg index + Google Books proxy).
class CatalogService {
  final Dio _dio;
  CatalogService(this._dio);

  Future<List<CatalogBook>> search(String q, {int limit = 20}) async {
    final res = await _dio.get<dynamic>(
      '/me/catalog/search',
      queryParameters: {'q': q, 'limit': limit},
    );
    // Current backend wraps results: { query, partialResults, items: [...] }.
    // Tolerate the older bare-list shape too.
    final data = res.data;
    final items = data is Map<String, dynamic>
        ? (data['items'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
    return items
        .map((e) => CatalogBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Best-matching Google edition for a title/author (server-side key +
  /// cache). Null when nothing matches (backend answers 204).
  Future<CatalogBook?> lookup({required String title, String? author}) async {
    final res = await _dio.get<dynamic>(
      '/me/catalog/lookup',
      queryParameters: {
        'title': title,
        if (author != null && author.isNotEmpty) 'author': author,
      },
    );
    final data = res.data;
    return data is Map<String, dynamic> ? CatalogBook.fromJson(data) : null;
  }

  /// Free LibriVox audiobook for a title/author — chapter MP3s from the
  /// Internet Archive. Null when no recording exists (backend answers 204).
  Future<LibrivoxAudiobook?> librivox({
    required String title,
    String? author,
  }) async {
    final res = await _dio.get<dynamic>(
      '/me/catalog/librivox',
      queryParameters: {
        'title': title,
        if (author != null && author.isNotEmpty) 'author': author,
      },
    );
    final data = res.data;
    return data is Map<String, dynamic>
        ? LibrivoxAudiobook.fromJson(data)
        : null;
  }

  /// Local-only Home feed from the synced Gutenberg catalog.
  Future<List<CatalogBook>> trending({int limit = 24}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/catalog/trending',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .map((e) => CatalogBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Nightly precomputed author ranking and portraits from PostgreSQL.
  Future<List<CatalogTopAuthor>> topAuthors({int limit = 12}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/catalog/top-authors',
      queryParameters: {'limit': limit},
    );
    return [
      for (final raw in res.data ?? const [])
        if (raw is Map<String, dynamic>)
          (
            name: raw['name'] as String,
            imageUrl: raw['imageUrl'] as String?,
            downloadCount: (raw['downloadCount'] as num?)?.toInt() ?? 0,
          ),
    ];
  }

  /// "Recommended for you" — books derived from this user's recent catalog
  /// searches (server re-runs the keywords against the cached Google layer).
  /// Empty when the user hasn't searched yet.
  Future<List<CatalogBook>> recommendations({int limit = 12}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/catalog/recommendations',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .map((e) => CatalogBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// "Request this book" — logs demand for a title we can't serve yet.
  Future<void> requestBook(CatalogBook book) async {
    await _dio.post<void>(
      '/me/catalog/requests',
      data: {
        'title': book.title,
        'author': book.author,
        'isbn13': book.isbn13,
        'googleId': book.googleId,
      },
    );
  }
}

final catalogServiceProvider = Provider<CatalogService>(
  (ref) => CatalogService(ref.watch(dioProvider)),
);
