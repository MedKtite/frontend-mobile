import 'package:freezed_annotation/freezed_annotation.dart';

part 'presign_upload_response.freezed.dart';
part 'presign_upload_response.g.dart';

/// Mirrors backend dto/uploads/PresignUploadResponse.java.
///
/// [uploadUrl] is the one-shot, time-limited URL to PUT the file body to;
/// [fileKey] is passed back to `POST /me/books` once the upload lands.
@freezed
class PresignUploadResponse with _$PresignUploadResponse {
  const factory PresignUploadResponse({
    required String fileKey,
    required String uploadUrl,
    required String method,
    String? expiresAt,
  }) = _PresignUploadResponse;

  factory PresignUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$PresignUploadResponseFromJson(json);
}
