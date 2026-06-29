// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HighlightImpl _$$HighlightImplFromJson(Map<String, dynamic> json) =>
    _$HighlightImpl(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      textChapterRef: json['textChapterRef'] as String?,
      textStartOffset: (json['textStartOffset'] as num?)?.toInt(),
      textEndOffset: (json['textEndOffset'] as num?)?.toInt(),
      passageText: json['passageText'] as String?,
      audioStartSec: (json['audioStartSec'] as num?)?.toDouble(),
      audioEndSec: (json['audioEndSec'] as num?)?.toDouble(),
      colorTag: json['colorTag'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$HighlightImplToJson(_$HighlightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'textChapterRef': instance.textChapterRef,
      'textStartOffset': instance.textStartOffset,
      'textEndOffset': instance.textEndOffset,
      'passageText': instance.passageText,
      'audioStartSec': instance.audioStartSec,
      'audioEndSec': instance.audioEndSec,
      'colorTag': instance.colorTag,
      'createdAt': instance.createdAt,
    };
