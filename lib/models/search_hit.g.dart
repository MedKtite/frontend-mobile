// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_hit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchHitImpl _$$SearchHitImplFromJson(Map<String, dynamic> json) =>
    _$SearchHitImpl(
      type: json['type'] as String,
      id: json['id'] as String,
      bookId: json['bookId'] as String?,
      highlightId: json['highlightId'] as String?,
      bookTitle: json['bookTitle'] as String?,
      bookAuthor: json['bookAuthor'] as String?,
      title: json['title'] as String?,
      chapterRef: json['chapterRef'] as String?,
      colorTag: json['colorTag'] as String?,
      snippet: json['snippet'] as String?,
      rank: (json['rank'] as num?)?.toDouble(),
      coverUrl: json['coverUrl'] as String?,
      coverDominantColor: json['coverDominantColor'] as String?,
      format: json['format'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$SearchHitImplToJson(_$SearchHitImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'bookId': instance.bookId,
      'highlightId': instance.highlightId,
      'bookTitle': instance.bookTitle,
      'bookAuthor': instance.bookAuthor,
      'title': instance.title,
      'chapterRef': instance.chapterRef,
      'colorTag': instance.colorTag,
      'snippet': instance.snippet,
      'rank': instance.rank,
      'coverUrl': instance.coverUrl,
      'coverDominantColor': instance.coverDominantColor,
      'format': instance.format,
      'status': instance.status,
    };
