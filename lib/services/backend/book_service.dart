import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/book.dart';
import '../../models/book_create_request.dart';
import '../../models/book_update_request.dart';
import '../../models/download_url_response.dart';

/// Raw HTTP layer for /me/books. Errors propagate as ApiError (translated by
/// the error interceptor in dio_client.dart) — the controller catches them.
class BookService {
  final Dio _dio;
  BookService(this._dio);

  /// GET /me/books — the user's library, optionally filtered by [status]
  /// (reading | listening | finished | archived).
  Future<List<Book>> list({String? status}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/books',
      queryParameters: status != null ? {'status': status} : null,
    );
    return (res.data ?? const [])
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /me/books/{id} — a single book (title, progress, page count, …).
  Future<Book> getOne(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/me/books/$id');
    return Book.fromJson(res.data!);
  }

  /// POST /me/books — add a book (manual / catalog entry).
  Future<Book> create(BookCreateRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/me/books',
      data: req.toJson(),
    );
    return Book.fromJson(res.data!);
  }

  /// PATCH /me/books/{id} — update fields (e.g. re-shelf via status). Null fields
  /// are stripped so PATCH only touches what's set (backend ignores absent keys).
  Future<Book> update(String id, BookUpdateRequest req) async {
    final body = req.toJson()..removeWhere((_, value) => value == null);
    final res = await _dio.patch<Map<String, dynamic>>(
      '/me/books/$id',
      data: body,
    );
    return Book.fromJson(res.data!);
  }

  /// DELETE /me/books/{id} — remove a book from the library (204 No Content).
  Future<void> delete(String id) async {
    await _dio.delete<void>('/me/books/$id');
  }

  /// GET /me/books/{id}/download-url — a short-lived presigned S3/MinIO URL for
  /// the uploaded file (epub/pdf/m4b/mp3). The URL expires, so callers cache the
  /// downloaded file, not this response.
  Future<DownloadUrlResponse> downloadUrl(String id) async {
    final res =
        await _dio.get<Map<String, dynamic>>('/me/books/$id/download-url');
    return DownloadUrlResponse.fromJson(res.data!);
  }
}

final bookServiceProvider =
    Provider<BookService>((ref) => BookService(ref.watch(dioProvider)));
