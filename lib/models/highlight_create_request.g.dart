// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HighlightCreateRequestImpl _$$HighlightCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$HighlightCreateRequestImpl(
  bookId: json['bookId'] as String,
  colorTag: json['colorTag'] as String,
  textChapterRef: json['textChapterRef'] as String?,
  textStartOffset: (json['textStartOffset'] as num?)?.toInt(),
  textEndOffset: (json['textEndOffset'] as num?)?.toInt(),
  passageText: json['passageText'] as String?,
  audioStartSec: (json['audioStartSec'] as num?)?.toDouble(),
  audioEndSec: (json['audioEndSec'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$HighlightCreateRequestImplToJson(
  _$HighlightCreateRequestImpl instance,
) => <String, dynamic>{
  'bookId': instance.bookId,
  'colorTag': instance.colorTag,
  'textChapterRef': instance.textChapterRef,
  'textStartOffset': instance.textStartOffset,
  'textEndOffset': instance.textEndOffset,
  'passageText': instance.passageText,
  'audioStartSec': instance.audioStartSec,
  'audioEndSec': instance.audioEndSec,
};
