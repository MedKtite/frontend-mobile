import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/tag.dart';

/// Raw HTTP layer for /tags and /me/tags.
class TagService {
  final Dio _dio;
  TagService(this._dio);

  /// GET /tags — the 7 system tags + the caller's custom tags.
  Future<List<Tag>> listVisible() async {
    final res = await _dio.get<List<dynamic>>('/tags');
    return (res.data ?? const [])
        .map((e) => Tag.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /me/tags/counts — highlight count per tag id (absent = zero).
  Future<Map<String, int>> counts() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/tags/counts');
    return (res.data ?? const {})
        .map((k, v) => MapEntry(k, (v as num).toInt()));
  }
}

final tagServiceProvider =
    Provider<TagService>((ref) => TagService(ref.watch(dioProvider)));
