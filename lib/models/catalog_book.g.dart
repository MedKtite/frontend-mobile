// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CatalogBookImpl _$$CatalogBookImplFromJson(Map<String, dynamic> json) =>
    _$CatalogBookImpl(
      title: json['title'] as String,
      source: json['source'] as String?,
      contentAvailability: json['contentAvailability'] as String?,
      gutenbergId: (json['gutenbergId'] as num?)?.toInt(),
      googleId: json['googleId'] as String?,
      author: json['author'] as String?,
      publisher: json['publisher'] as String?,
      publishedYear: (json['publishedYear'] as num?)?.toInt(),
      isbn13: json['isbn13'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      language: json['language'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      description: json['description'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingsCount: (json['ratingsCount'] as num?)?.toInt(),
      downloadCount: (json['downloadCount'] as num?)?.toInt(),
      previewUrl: json['previewUrl'] as String?,
    );

Map<String, dynamic> _$$CatalogBookImplToJson(_$CatalogBookImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'source': instance.source,
      'contentAvailability': instance.contentAvailability,
      'gutenbergId': instance.gutenbergId,
      'googleId': instance.googleId,
      'author': instance.author,
      'publisher': instance.publisher,
      'publishedYear': instance.publishedYear,
      'isbn13': instance.isbn13,
      'pageCount': instance.pageCount,
      'language': instance.language,
      'thumbnailUrl': instance.thumbnailUrl,
      'description': instance.description,
      'averageRating': instance.averageRating,
      'ratingsCount': instance.ratingsCount,
      'downloadCount': instance.downloadCount,
      'previewUrl': instance.previewUrl,
    };
