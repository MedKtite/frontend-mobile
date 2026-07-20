import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/presign_upload_request.dart';
import '../../models/presign_upload_response.dart';

/// Direct-to-S3 upload flow (see backend UploadController):
///   1) [presign] → {fileKey, uploadUrl}
///   2) [putToStorage] PUTs the bytes straight to S3/MinIO
///   3) caller does `POST /me/books` with the metadata + fileKey
class UploadService {
  /// Authenticated backend Dio (cookies + base URL + interceptors).
  final Dio _api;

  UploadService(this._api);

  /// POST /me/uploads/presign — reserve an S3 key and get the upload URL.
  /// 503 (→ ApiError) means the server has no storage configured.
  Future<PresignUploadResponse> presign(PresignUploadRequest req) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/me/uploads/presign',
      data: req.toJson(),
    );
    return PresignUploadResponse.fromJson(res.data!);
  }

  /// PUT the file body to the presigned [uploadUrl]. Uses a *bare* Dio — no
  /// auth cookies, no interceptors, no base URL — because the target is S3, not
  /// our API. [contentType] and the byte length must exactly match what was
  /// sent to [presign]; the S3 signature covers both.
  Future<void> putToStorage({
    required String uploadUrl,
    required Stream<List<int>> body,
    required int contentLength,
    required String contentType,
    ProgressCallback? onSendProgress,
  }) async {
    debugPrint(
      '[UploadService] PUT starting, length=$contentLength, '
      'contentType=$contentType',
    );
    final raw = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    try {
      await raw.put<void>(
        uploadUrl,
        data: body,
        options: Options(
          contentType: contentType,
          headers: {Headers.contentLengthHeader: contentLength},
        ),
        onSendProgress: onSendProgress,
      );
      debugPrint('[UploadService] PUT completed');
    } on DioException catch (e) {
      debugPrint(
        '[UploadService] PUT failed: type=${e.type}, '
        'status=${e.response?.statusCode}, message=${e.message}',
      );
      rethrow;
    } finally {
      raw.close();
    }
  }
}

final uploadServiceProvider = Provider<UploadService>(
  (ref) => UploadService(ref.watch(dioProvider)),
);
