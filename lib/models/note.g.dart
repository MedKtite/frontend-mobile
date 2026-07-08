// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: json['id'] as String,
  bookId: json['bookId'] as String,
  highlightId: json['highlightId'] as String?,
  bodyMd: json['bodyMd'] as String,
  isSaved: json['isSaved'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'highlightId': instance.highlightId,
      'bodyMd': instance.bodyMd,
      'isSaved': instance.isSaved,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
