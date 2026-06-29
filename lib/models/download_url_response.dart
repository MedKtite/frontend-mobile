import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_url_response.freezed.dart';
part 'download_url_response.g.dart';

/// Mirrors backend dto/uploads/DownloadUrlResponse.java — the presigned URL the
/// client GETs the uploaded book file from (expires; cache the *file*, not this).
@freezed
class DownloadUrlResponse with _$DownloadUrlResponse {
  const factory DownloadUrlResponse({
    required String downloadUrl,
    String? expiresAt,
  }) = _DownloadUrlResponse;

  factory DownloadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$DownloadUrlResponseFromJson(json);
}
