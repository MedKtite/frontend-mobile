
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects client and device metadata without contacting the backend.
class DeviceInfoService {
  DeviceInfoService({
    DeviceInfoPlugin? deviceInfo,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  Future<Map<String, dynamic>> getAll() async {
    final results = await Future.wait([
      _deviceInfo.deviceInfo,
      PackageInfo.fromPlatform(),
    ]);
    final device = results[0] as BaseDeviceInfo;
    final package = results[1] as PackageInfo;
    final dispatcher = PlatformDispatcher.instance;
    final now = DateTime.now();

    return <String, dynamic>{
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'device': Map<String, dynamic>.from(device.data),
      'app': <String, String>{
        'name': package.appName,
        'packageName': package.packageName,
        'version': package.version,
        'buildNumber': package.buildNumber,
      },
      'environment': <String, dynamic>{
        'locale': dispatcher.locale.toLanguageTag(),
        'locales': dispatcher.locales.map((e) => e.toLanguageTag()).toList(),
        'timezoneName': now.timeZoneName,
        'timezoneOffsetMinutes': now.timeZoneOffset.inMinutes,
      },
    };
  }
}

final deviceInfoServiceProvider =
    Provider<DeviceInfoService>((ref) => DeviceInfoService());

final deviceInfoProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(deviceInfoServiceProvider).getAll(),
);
