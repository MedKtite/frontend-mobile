import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

/// Mirrors the backend's BookResponse DTO (dto/book/BookResponse.java).
/// All fields beyond id/title are nullable — the backend omits null fields
/// (`@JsonInclude(NON_NULL)`).
@freezed
class Book with _$Book {
  const factory Book({
    required String id,
    required String title,
    String? author,
    String? narrator,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    String? googleId,
    int?
    gutenbergId, // Google Books volume id — enables free public-domain reading
    int? pageCount,
    int? durationSec,
    String? language,
    String? format, // epub | pdf | m4b | mp3 | physical
    String? coverUrl,
    String? coverDominantColor, // #RRGGBB
    String? description,
    String? processingStatus, // pending | processing | ready | failed
    String? processingError,
    String? readingFileKey,
    String? processingVersion,
    String? status, // reading | listening | finished | archived
    double? progressPct, // 0–100
    String? cursor, // opaque JSONB reading position
    String? lastOpenedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

extension BookUploadX on Book {
  /// Whether this book was uploaded by the user (EPUB, PDF, audio)
  /// rather than pulled from the Gutenberg catalog or logged as physical.
  bool get isUploaded {
    if (gutenbergId != null) return false;
    final f = format?.toLowerCase();
    if (f == 'physical') return false;
    return f == 'epub' ||
        f == 'pdf' ||
        f == 'm4b' ||
        f == 'mp3' ||
        readingFileKey != null;
  }
}
