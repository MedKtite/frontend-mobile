import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_hit.freezed.dart';
part 'search_hit.g.dart';

/// A single search result (mirrors dto/search/SearchHit.java). Discriminated by
/// [type] (`book` | `highlight` | `note`); only the fields for that type are set.
@freezed
class SearchHit with _$SearchHit {
  const factory SearchHit({
    required String type,
    required String id,
    String? bookId,
    String? highlightId,
    String? bookTitle,
    String? bookAuthor,
    String? title, // book title (type=book)
    String? chapterRef, // §47, p. 142 … (type=highlight)
    String? colorTag, // type=highlight
    String? snippet, // <mark>…</mark> matched text (highlight / note)
    double? rank,
    String? coverUrl,
    String? coverDominantColor,
    String? format,
    String? status,
  }) = _SearchHit;

  factory SearchHit.fromJson(Map<String, dynamic> json) =>
      _$SearchHitFromJson(json);
}
