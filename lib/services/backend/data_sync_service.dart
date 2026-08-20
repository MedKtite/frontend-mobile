import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/dio_client.dart';

class DataSyncService {
  final Dio _dio;

  DataSyncService(this._dio);

  Future<String> getCurrentDeviceName() async {
    if (kIsWeb) return 'Web Browser';
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        final brand = info.brand.isNotEmpty ? info.brand[0].toUpperCase() + info.brand.substring(1) : '';
        return '$brand ${info.model}'.trim();
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return info.name;
      } else if (Platform.isWindows) {
        final info = await plugin.windowsInfo;
        return info.computerName.isNotEmpty ? info.computerName : 'Windows PC';
      } else if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        return info.computerName.isNotEmpty ? info.computerName : 'Mac';
      } else if (Platform.isLinux) {
        final info = await plugin.linuxInfo;
        return info.name;
      }
    } catch (_) {}
    return '${Platform.operatingSystem} Device';
  }

  Future<Map<String, dynamic>> triggerSync() async {
    final res = await _dio.post<Map<String, dynamic>>('/me/sync');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> getExportSummary() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/export/summary');
    return res.data ?? {};
  }

  Future<List<int>> downloadExportBytes({
    required String format, // 'pdf' | 'csv'
    String? bookId,
  }) async {
    final res = await _dio.get<List<int>>(
      '/me/export',
      queryParameters: {
        'format': format,
        if (bookId != null) 'book_id': bookId,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? [];
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final res = await _dio.get<List<dynamic>>('/me/devices');
    final data = res.data ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> removeDevice(String deviceId) async {
    await _dio.delete<void>('/me/devices/$deviceId');
  }

  Future<int> estimateCacheSizeBytes() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;
      if (tempDir.existsSync()) {
        await for (final file in tempDir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      return totalSize;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearLocalCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await for (final file in tempDir.list(recursive: false)) {
          try {
            await file.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}

final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  return DataSyncService(ref.watch(dioProvider));
});
