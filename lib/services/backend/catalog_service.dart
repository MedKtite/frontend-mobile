import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/catalog_book.dart';

/// Raw HTTP for /me/catalog (Google Books proxy).
class CatalogService {
  final Dio _dio;
  CatalogService(this._dio);

  Future<List<CatalogBook>> search(String q, {int limit = 20}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/catalog/search',
      queryParameters: {'q': q, 'limit': limit},
    );
    return (res.data ?? const [])
        .map((e) => CatalogBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final catalogServiceProvider =
    Provider<CatalogService>((ref) => CatalogService(ref.watch(dioProvider)));
