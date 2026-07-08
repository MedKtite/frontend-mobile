import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Mobile/desktop half of the networking shim (selected via conditional
/// import in dio_client.dart): native adapter, persistent cookie jar, and an
/// emulator-aware default base URL.

HttpClientAdapter createHttpClientAdapter() => IOHttpClientAdapter();

/// 10.0.2.2 is the Android emulator's alias for the host machine; a real
/// device needs --dart-define=API_BASE_URL (see DioFactory).
String platformDefaultBaseUrl() =>
    Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';

/// Cookies persist across app restarts so the refresh token survives reboot.
Future<void> attachCookieManager(Dio dio) async {
  final docs = await getApplicationDocumentsDirectory();
  final jar = PersistCookieJar(
    ignoreExpires: false,
    storage: FileStorage('${docs.path}/.marginalia/cookies/'),
  );
  dio.interceptors.add(CookieManager(jar));
}
