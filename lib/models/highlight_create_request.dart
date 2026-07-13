import 'package:freezed_annotation/freezed_annotation.dart';

part 'highlight_create_request.freezed.dart';
part 'highlight_create_request.g.dart';

/// Body of POST /me/highlights (mirrors dto/highlight/HighlightCreateRequest.java).
/// [colorTag] is required and must be one of the seven seeded tag names; text
/// offsets are optional (we can't derive them from epub_view, so they're null).
@freezed
class HighlightCreateRequest with _$HighlightCreateRequest {
  const factory HighlightCreateRequest({
    required String bookId,
    required String colorTag, // curious|resonant|beautiful|reference|urgent|disagree|revisit
    String? textChapterRef,
    int? textStartOffset,
    int? textEndOffset,
    String? passageText,
    double? audioStartSec, // audio bookmark timestamp — null for text highlights
    double? audioEndSec,
  }) = _HighlightCreateRequest;

  factory HighlightCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$HighlightCreateRequestFromJson(json);
}
