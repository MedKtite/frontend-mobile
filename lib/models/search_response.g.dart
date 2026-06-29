// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResponseImpl _$$SearchResponseImplFromJson(Map<String, dynamic> json) =>
    _$SearchResponseImpl(
      query: json['query'] as String?,
      scope: json['scope'] as String?,
      totalHits: (json['totalHits'] as num?)?.toInt() ?? 0,
      counts: json['counts'] == null
          ? const SearchCounts()
          : SearchCounts.fromJson(json['counts'] as Map<String, dynamic>),
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => SearchHit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SearchHit>[],
    );

Map<String, dynamic> _$$SearchResponseImplToJson(
  _$SearchResponseImpl instance,
) => <String, dynamic>{
  'query': instance.query,
  'scope': instance.scope,
  'totalHits': instance.totalHits,
  'counts': instance.counts,
  'results': instance.results,
};

_$SearchCountsImpl _$$SearchCountsImplFromJson(Map<String, dynamic> json) =>
    _$SearchCountsImpl(
      books: (json['books'] as num?)?.toInt() ?? 0,
      highlights: (json['highlights'] as num?)?.toInt() ?? 0,
      notes: (json['notes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SearchCountsImplToJson(_$SearchCountsImpl instance) =>
    <String, dynamic>{
      'books': instance.books,
      'highlights': instance.highlights,
      'notes': instance.notes,
    };
