import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_create_request.freezed.dart';
part 'note_create_request.g.dart';

/// Body of POST /me/notes (mirrors dto/note/NoteCreateRequest.java). A note
/// anchors to a passage via [highlightId]; [bodyMd] is the markdown text.
@freezed
class NoteCreateRequest with _$NoteCreateRequest {
  const factory NoteCreateRequest({
    required String bookId,
    required String bodyMd,
    String? highlightId,
  }) = _NoteCreateRequest;

  factory NoteCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$NoteCreateRequestFromJson(json);
}
