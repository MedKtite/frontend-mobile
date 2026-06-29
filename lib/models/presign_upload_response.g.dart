// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presign_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresignUploadResponseImpl _$$PresignUploadResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PresignUploadResponseImpl(
  fileKey: json['fileKey'] as String,
  uploadUrl: json['uploadUrl'] as String,
  method: json['method'] as String,
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$$PresignUploadResponseImplToJson(
  _$PresignUploadResponseImpl instance,
) => <String, dynamic>{
  'fileKey': instance.fileKey,
  'uploadUrl': instance.uploadUrl,
  'method': instance.method,
  'expiresAt': instance.expiresAt,
};
