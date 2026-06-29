// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookUpdateRequestImpl _$$BookUpdateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$BookUpdateRequestImpl(
  status: json['status'] as String?,
  progressPct: (json['progressPct'] as num?)?.toDouble(),
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$$BookUpdateRequestImplToJson(
  _$BookUpdateRequestImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'progressPct': instance.progressPct,
  'cursor': instance.cursor,
};
