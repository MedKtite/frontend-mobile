import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_book.freezed.dart';
part 'catalog_book.g.dart';

/// A catalog search result (mirrors CatalogVolumeResponse.java) — from the
/// Gutenberg index ([source] GUTENBERG, readable in-app) or Google Books
/// ([source] GOOGLE). [contentAvailability] FULL means the text is readable /
/// listenable here; METADATA_ONLY means we only show the page + buy links.
/// Not a library book — the user adds it via POST /me/books.
@freezed
class CatalogBook with _$CatalogBook {
  const CatalogBook._();

  const factory CatalogBook({
    required String title,
    String? source, // GUTENBERG | GOOGLE
    String? contentAvailability, // FULL | METADATA_ONLY
    int? gutenbergId,
    String? googleId,
    String? author,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    int? pageCount,
    String? language,
    String? thumbnailUrl,
    String? description,
    double? averageRating, // Google community rating 1–5, if any
    int? ratingsCount, // Google: number of ratings behind averageRating
    int? downloadCount, // Gutenberg: lifetime downloads ("readers" KPI)
    String? previewUrl, // Google web sample, only when pages render
  }) = _CatalogBook;

  factory CatalogBook.fromJson(Map<String, dynamic> json) =>
      _$CatalogBookFromJson(json);

  /// Readable in-app right now (public-domain text we can fetch).
  bool get isReadable => contentAvailability == 'FULL';
}
