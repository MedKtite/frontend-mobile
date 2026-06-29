import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_create_request.freezed.dart';
part 'book_create_request.g.dart';

/// Body of POST /me/books (mirrors dto/book/BookCreateRequest.java). [title] and
/// [format] are required; for non-physical uploads the backend also needs a
/// [fileKey]. A catalog add uses `format: 'physical'`.
@freezed
class BookCreateRequest with _$BookCreateRequest {
  const factory BookCreateRequest({
    required String title,
    required String format, // epub | pdf | m4b | mp3 | physical
    String? author,
    String? narrator,
    String? publisher,
    int? publishedYear,
    String? fileKey,
    String? googleId,
    String? isbn13,
    int? pageCount,
    int? durationSec,
    String? language,
    String? coverUrl,
    String? coverDominantColor,
    String? status,
  }) = _BookCreateRequest;

  factory BookCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$BookCreateRequestFromJson(json);
}
