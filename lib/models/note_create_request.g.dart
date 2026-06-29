// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteCreateRequestImpl _$$NoteCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$NoteCreateRequestImpl(
  bookId: json['bookId'] as String,
  bodyMd: json['bodyMd'] as String,
  highlightId: json['highlightId'] as String?,
);

Map<String, dynamic> _$$NoteCreateRequestImplToJson(
  _$NoteCreateRequestImpl instance,
) => <String, dynamic>{
  'bookId': instance.bookId,
  'bodyMd': instance.bodyMd,
  'highlightId': instance.highlightId,
};
