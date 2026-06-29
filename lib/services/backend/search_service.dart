import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/search_response.dart';

/// Raw HTTP for /me/search — full-text search across the user's own books,
/// highlights and notes.
class SearchService {
  final Dio _dio;
  SearchService(this._dio);

  Future<SearchResponse> search(
    String q, {
    String scope = 'all',
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/me/search',
      queryParameters: {'q': q, 'scope': scope, 'limit': limit},
    );
    return SearchResponse.fromJson(res.data ?? const {});
  }
}

final searchServiceProvider =
    Provider<SearchService>((ref) => SearchService(ref.watch(dioProvider)));
