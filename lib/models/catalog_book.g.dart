// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogBookImpl _$$CatalogBookImplFromJson(Map<String, dynamic> json) =>
    _$CatalogBookImpl(
      title: json['title'] as String,
      googleId: json['googleId'] as String?,
      author: json['author'] as String?,
      publisher: json['publisher'] as String?,
      publishedYear: (json['publishedYear'] as num?)?.toInt(),
      isbn13: json['isbn13'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$CatalogBookImplToJson(_$CatalogBookImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'googleId': instance.googleId,
      'author': instance.author,
      'publisher': instance.publisher,
      'publishedYear': instance.publishedYear,
      'isbn13': instance.isbn13,
      'pageCount': instance.pageCount,
      'thumbnailUrl': instance.thumbnailUrl,
      'description': instance.description,
    };
