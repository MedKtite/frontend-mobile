import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web half of the networking shim (selected via conditional import in
/// dio_client.dart). The browser owns cookies — they ride along automatically
/// when the web build is served FROM the backend (same origin), which is the
/// supported way to run the web preview.

HttpClientAdapter createHttpClientAdapter() =>
    BrowserHttpClientAdapter(withCredentials: true);

/// Default base URL on web:
/// - If served on localhost on a dev port (e.g. Flutter Web dev server on port 50417),
///   points to the Spring Boot backend on http://localhost:8080.
/// - Otherwise (production same-origin), uses relative paths ''.
/// - Can be overridden with --dart-define=API_BASE_URL.
String platformDefaultBaseUrl() {
  final uri = Uri.base;
  if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
    if (uri.port != 8080) {
      return 'http://localhost:8080';
    }
  }
  return '';
}

/// No-op: browsers manage cookie storage themselves.
Future<void> attachCookieManager(Dio dio) async {}
