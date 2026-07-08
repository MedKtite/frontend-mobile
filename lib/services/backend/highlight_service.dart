import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/highlight.dart';
import '../../models/highlight_create_request.dart';

/// Raw HTTP layer for /me/highlights.
class HighlightService {
  final Dio _dio;
  HighlightService(this._dio);

  /// GET /me/highlights — the user's most-recent highlights (newest first).
  Future<List<Highlight>> listRecent({int limit = 20}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/highlights',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /me/highlights/by-book/{bookId} — every highlight for one book.
  Future<List<Highlight>> listForBook(String bookId) async {
    final res =
        await _dio.get<List<dynamic>>('/me/highlights/by-book/$bookId');
    return (res.data ?? const [])
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /me/highlights/saved — highlights bookmarked into Saved.
  Future<List<Highlight>> listSaved() async {
    final res = await _dio.get<List<dynamic>>('/me/highlights/saved');
    return (res.data ?? const [])
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /me/highlights/by-tag/{tagId} — every highlight carrying this tag.
  Future<List<Highlight>> listByTag(String tagId) async {
    final res = await _dio.get<List<dynamic>>('/me/highlights/by-tag/$tagId');
    return (res.data ?? const [])
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /me/highlights — create a highlight (passage + chapter + colorTag).
  /// Null fields are stripped so optional offsets are simply omitted.
  Future<Highlight> create(HighlightCreateRequest req) async {
    final body = req.toJson()..removeWhere((_, v) => v == null);
    final res = await _dio.post<Map<String, dynamic>>(
      '/me/highlights',
      data: body,
    );
    return Highlight.fromJson(res.data!);
  }

  /// PATCH /me/highlights/{id} — toggle the Saved bookmark.
  Future<Highlight> setSaved(String id, bool saved) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/me/highlights/$id',
      data: {'isSaved': saved},
    );
    return Highlight.fromJson(res.data!);
  }
}

final highlightServiceProvider =
    Provider<HighlightService>((ref) => HighlightService(ref.watch(dioProvider)));
