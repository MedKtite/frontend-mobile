// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookCreateRequestImpl _$$BookCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$BookCreateRequestImpl(
  title: json['title'] as String,
  format: json['format'] as String,
  author: json['author'] as String?,
  narrator: json['narrator'] as String?,
  publisher: json['publisher'] as String?,
  publishedYear: (json['publishedYear'] as num?)?.toInt(),
  fileKey: json['fileKey'] as String?,
  googleId: json['googleId'] as String?,
  isbn13: json['isbn13'] as String?,
  pageCount: (json['pageCount'] as num?)?.toInt(),
  durationSec: (json['durationSec'] as num?)?.toInt(),
  language: json['language'] as String?,
  coverUrl: json['coverUrl'] as String?,
  coverDominantColor: json['coverDominantColor'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$$BookCreateRequestImplToJson(
  _$BookCreateRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'format': instance.format,
  'author': instance.author,
  'narrator': instance.narrator,
  'publisher': instance.publisher,
  'publishedYear': instance.publishedYear,
  'fileKey': instance.fileKey,
  'googleId': instance.googleId,
  'isbn13': instance.isbn13,
  'pageCount': instance.pageCount,
  'durationSec': instance.durationSec,
  'language': instance.language,
  'coverUrl': instance.coverUrl,
  'coverDominantColor': instance.coverDominantColor,
  'status': instance.status,
};
