import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/note_create_request.dart';

/// Raw HTTP layer for /me/notes.
class NoteService {
  final Dio _dio;
  NoteService(this._dio);

  /// POST /me/notes — create a note, optionally anchored to a highlight.
  Future<void> create(NoteCreateRequest req) async {
    final body = req.toJson()..removeWhere((_, v) => v == null);
    await _dio.post<void>('/me/notes', data: body);
  }
}

final noteServiceProvider =
    Provider<NoteService>((ref) => NoteService(ref.watch(dioProvider)));
