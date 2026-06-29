import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_book.freezed.dart';
part 'catalog_book.g.dart';

/// A Google Books search result (mirrors CatalogVolumeResponse.java). Not a
/// library book — the user adds it via POST /me/books.
@freezed
class CatalogBook with _$CatalogBook {
  const factory CatalogBook({
    required String title,
    String? googleId,
    String? author,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    int? pageCount,
    String? thumbnailUrl,
    String? description,
  }) = _CatalogBook;

  factory CatalogBook.fromJson(Map<String, dynamic> json) =>
      _$CatalogBookFromJson(json);
}
