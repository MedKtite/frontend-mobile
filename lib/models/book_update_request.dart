import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_update_request.freezed.dart';
part 'book_update_request.g.dart';

/// Body of PATCH /me/books/{id} (mirrors dto/book/BookUpdateRequest.java). PATCH
/// semantics — only present fields update, so nulls are omitted from the JSON.
@freezed
class BookUpdateRequest with _$BookUpdateRequest {
  const factory BookUpdateRequest({
    String? status, // reading | listening | finished | archived
    double? progressPct,
    String? cursor,
  }) = _BookUpdateRequest;

  factory BookUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$BookUpdateRequestFromJson(json);
}
