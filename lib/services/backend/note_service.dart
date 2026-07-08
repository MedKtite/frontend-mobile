import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/note.dart';
import '../../models/note_create_request.dart';

/// Raw HTTP layer for /me/notes.
class NoteService {
  final Dio _dio;
  NoteService(this._dio);

  /// GET /me/notes — the user's most-recent notes, newest first.
  Future<List<Note>> listRecent({int limit = 100}) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/notes',
      queryParameters: {'limit': limit},
    );
    return (res.data ?? const [])
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /me/notes/saved — notes bookmarked into Saved.
  Future<List<Note>> listSaved() async {
    final res = await _dio.get<List<dynamic>>('/me/notes/saved');
    return (res.data ?? const [])
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /me/notes — create a note, optionally anchored to a highlight.
  Future<void> create(NoteCreateRequest req) async {
    final body = req.toJson()..removeWhere((_, v) => v == null);
    await _dio.post<void>('/me/notes', data: body);
  }

  /// PATCH /me/notes/{id} — toggle the Saved bookmark.
  Future<Note> setSaved(String id, bool saved) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/me/notes/$id',
      data: {'isSaved': saved},
    );
    return Note.fromJson(res.data!);
  }
}

final noteServiceProvider =
    Provider<NoteService>((ref) => NoteService(ref.watch(dioProvider)));
