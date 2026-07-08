import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web half of the networking shim (selected via conditional import in
/// dio_client.dart). The browser owns cookies — they ride along automatically
/// when the web build is served FROM the backend (same origin), which is the
/// supported way to run the web preview.

HttpClientAdapter createHttpClientAdapter() =>
    BrowserHttpClientAdapter(withCredentials: true);

/// Same-origin relative — the web build is served by the Spring backend.
/// --dart-define=API_BASE_URL still overrides (see DioFactory).
String platformDefaultBaseUrl() => '';

/// No-op: browsers manage cookie storage themselves.
Future<void> attachCookieManager(Dio dio) async {}
