// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presign_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresignUploadRequestImpl _$$PresignUploadRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PresignUploadRequestImpl(
  format: json['format'] as String,
  contentType: json['contentType'] as String,
  contentLength: (json['contentLength'] as num).toInt(),
);

Map<String, dynamic> _$$PresignUploadRequestImplToJson(
  _$PresignUploadRequestImpl instance,
) => <String, dynamic>{
  'format': instance.format,
  'contentType': instance.contentType,
  'contentLength': instance.contentLength,
};
