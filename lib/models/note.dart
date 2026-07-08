import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

/// Mirrors the backend's NoteResponse DTO (dto/note/NoteResponse.java).
/// A note is anchored to a highlight ([highlightId]) or stands alone
/// against the whole book.
@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String bookId,
    String? highlightId,
    required String bodyMd,
    @Default(false) bool isSaved,
    String? createdAt,
    String? updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
