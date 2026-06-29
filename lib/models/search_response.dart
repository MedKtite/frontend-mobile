import 'package:freezed_annotation/freezed_annotation.dart';

import 'search_hit.dart';

part 'search_response.freezed.dart';
part 'search_response.g.dart';

/// Mirrors dto/search/SearchResponse.java — the wrapper for a `/me/search` query.
@freezed
class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    String? query,
    String? scope,
    @Default(0) int totalHits,
    @Default(SearchCounts()) SearchCounts counts,
    @Default(<SearchHit>[]) List<SearchHit> results,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}

@freezed
class SearchCounts with _$SearchCounts {
  const factory SearchCounts({
    @Default(0) int books,
    @Default(0) int highlights,
    @Default(0) int notes,
  }) = _SearchCounts;

  factory SearchCounts.fromJson(Map<String, dynamic> json) =>
      _$SearchCountsFromJson(json);
}
