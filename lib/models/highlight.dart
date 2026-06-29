import 'package:freezed_annotation/freezed_annotation.dart';

part 'highlight.freezed.dart';
part 'highlight.g.dart';

/// Mirrors the backend's HighlightResponse DTO (dto/highlight/HighlightResponse.java).
/// One shape for both text highlights ([passageText]) and audio bookmarks
/// ([audioStartSec]). [colorTag] is one of the seven seeded tag names.
@freezed
class Highlight with _$Highlight {
  const factory Highlight({
    required String id,
    required String bookId,
    String? textChapterRef,
    int? textStartOffset,
    int? textEndOffset,
    String? passageText,
    double? audioStartSec,
    double? audioEndSec,
    String? colorTag,
    String? createdAt,
  }) = _Highlight;

  factory Highlight.fromJson(Map<String, dynamic> json) =>
      _$HighlightFromJson(json);
}
