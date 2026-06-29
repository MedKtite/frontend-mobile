// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookImpl _$$BookImplFromJson(Map<String, dynamic> json) => _$BookImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  author: json['author'] as String?,
  narrator: json['narrator'] as String?,
  publisher: json['publisher'] as String?,
  publishedYear: (json['publishedYear'] as num?)?.toInt(),
  isbn13: json['isbn13'] as String?,
  googleId: json['googleId'] as String?,
  pageCount: (json['pageCount'] as num?)?.toInt(),
  durationSec: (json['durationSec'] as num?)?.toInt(),
  language: json['language'] as String?,
  format: json['format'] as String?,
  coverUrl: json['coverUrl'] as String?,
  coverDominantColor: json['coverDominantColor'] as String?,
  status: json['status'] as String?,
  progressPct: (json['progressPct'] as num?)?.toDouble(),
  cursor: json['cursor'] as String?,
  lastOpenedAt: json['lastOpenedAt'] as String?,
  finishedAt: json['finishedAt'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$BookImplToJson(_$BookImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'narrator': instance.narrator,
      'publisher': instance.publisher,
      'publishedYear': instance.publishedYear,
      'isbn13': instance.isbn13,
      'googleId': instance.googleId,
      'pageCount': instance.pageCount,
      'durationSec': instance.durationSec,
      'language': instance.language,
      'format': instance.format,
      'coverUrl': instance.coverUrl,
      'coverDominantColor': instance.coverDominantColor,
      'status': instance.status,
      'progressPct': instance.progressPct,
      'cursor': instance.cursor,
      'lastOpenedAt': instance.lastOpenedAt,
      'finishedAt': instance.finishedAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
