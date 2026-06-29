import 'package:freezed_annotation/freezed_annotation.dart';

part 'presign_upload_request.freezed.dart';
part 'presign_upload_request.g.dart';

/// Mirrors backend dto/uploads/PresignUploadRequest.java.
///
/// [format] is one of epub|pdf|m4b|mp3 (physical books don't upload).
/// [contentType] must match the MIME the client sets on the S3 PUT, and
/// [contentLength] the exact byte count — both are baked into the S3 signature.
@freezed
class PresignUploadRequest with _$PresignUploadRequest {
  const factory PresignUploadRequest({
    required String format,
    required String contentType,
    required int contentLength,
  }) = _PresignUploadRequest;

  factory PresignUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$PresignUploadRequestFromJson(json);
}
