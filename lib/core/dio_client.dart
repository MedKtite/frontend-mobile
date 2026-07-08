import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Platform-specific pieces (adapter, cookies, default base URL): the web
// build compiles the browser variant, everything else the dart:io variant.
import 'dio_support/dio_support_web.dart'
    if (dart.library.io) 'dio_support/dio_support_io.dart' as platform;

/// The whole client networking layer in one file: the [dioProvider], the
/// [DioFactory] that builds the configured Dio, the request interceptors
/// (auth-refresh + error mapping), and the parsed [ApiError]. A non-2xx
/// surfaces as an [ApiError] thrown from the call site; providers/controllers
/// catch it and map it to an error state.

/// The Dio instance is created asynchronously in main() (cookie jar needs a path)
/// and overridden into this provider at app boot. Reading it before the override
/// is set will throw with a clear message.
final dioProvider = Provider<Dio>((ref) {
  throw UnimplementedError(
      'dioProvider must be overridden in ProviderScope at app startup. '
      'See main.dart.');
});

/// Builds a Dio configured for the Marginalia backend.
///
/// • Cookies persist across app restarts (refresh token survives reboot).
/// • Backend errors are unwrapped to [ApiError] before they reach repos.
/// • Auth interceptor handles silent 401 → /auth/refresh → retry.
class DioFactory {
  DioFactory._();

  /// Backend base URL, overridable at build time for real-device testing:
  ///   flutter run -d `<phone>` --dart-define=API_BASE_URL=http://192.168.1.6:8080
  /// Default: 10.0.2.2 on the Android emulator (its alias for the host
  /// machine — a REAL phone can't reach it), localhost elsewhere.
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get defaultBaseUrl => _envBaseUrl.isNotEmpty
      ? _envBaseUrl
      : platform.platformDefaultBaseUrl();

  static Future<Dio> create({String? baseUrl}) async {
    final dio = _ApiErrorDio(BaseOptions(
      baseUrl: baseUrl ?? defaultBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      contentType: 'application/json',
      // We translate non-2xx to typed errors ourselves below — Dio shouldn't throw.
      validateStatus: (_) => true,
    ));

    // Cookie handling is platform-specific: persistent jar on mobile,
    // browser-managed (no-op) on web.
    await platform.attachCookieManager(dio);
    dio.interceptors
      ..add(AuthInterceptor(dio))
      ..add(_ErrorMappingInterceptor());

    return dio;
  }
}

/// A [Dio] that restores our typed [ApiError] at the call site.
///
/// `_ErrorMappingInterceptor` *throws* an [ApiError] for any non-2xx, but Dio
/// re-wraps every thrown non-[DioException] into a `DioException(error: …)`.
/// Without this, `await service.x()` always throws a [DioException], so every
/// `on ApiError catch` in the app silently misses (errors escape uncaught and
/// leave loading spinners stuck). Every get/post/patch/… funnels through
/// [fetch], so unwrapping here fixes all call sites at once.
class _ApiErrorDio with DioMixin implements Dio {
  _ApiErrorDio(BaseOptions options) {
    this.options = options;
    httpClientAdapter = platform.createHttpClientAdapter();
  }

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    try {
      return await super.fetch<T>(requestOptions);
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiError) throw err;
      rethrow;
    }
  }
}

/// Catches 401 on any non-/auth call, attempts POST /auth/refresh, then
/// retries the original request once. If refresh itself returns 401, the
/// error bubbles up — UI sees a 401 and routes the user back to login.
///
/// Serializes concurrent refreshes: while a refresh is in flight, additional
/// 401s join the same future rather than firing parallel refresh requests.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  Future<void>? _ongoingRefresh;

  AuthInterceptor(this._dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final status = err.response?.statusCode ?? 0;

    final isRefresh = req.path.endsWith('/auth/refresh');
    final isAuthCall = req.path.contains('/auth/');
    final alreadyRetried = req.extra['__retried__'] == true;

    if (status != 401 || isRefresh || isAuthCall || alreadyRetried) {
      return handler.next(err);
    }

    try {
      _ongoingRefresh ??= _refresh();
      await _ongoingRefresh;
      _ongoingRefresh = null;
    } catch (_) {
      _ongoingRefresh = null;
      // Refresh failed — pass the original 401 through.
      return handler.next(err);
    }

    try {
      final retryOptions = Options(
        method:  req.method,
        headers: req.headers,
        extra:   {...req.extra, '__retried__': true},
        responseType: req.responseType,
        contentType:  req.contentType,
      );
      final response = await _dio.request<dynamic>(
        req.path,
        data: req.data,
        queryParameters: req.queryParameters,
        options: retryOptions,
      );
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  Future<void> _refresh() async {
    await _dio.post<void>('/auth/refresh');
  }
}

/// Translates non-2xx responses (and DioException's transport-layer failures)
/// into a single [ApiError] thrown from the repository.
class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final code = response.statusCode ?? 0;
    if (code >= 200 && code < 300) {
      return handler.next(response);
    }
    final body = response.data;
    if (body is Map<String, dynamic>) {
      throw ApiError.fromJson(body);
    }
    throw ApiError(status: code, error: 'http', message: body?.toString() ?? 'HTTP $code');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transport-layer failures (timeouts, no network) — wrap as ApiError.
    if (err.error is ApiError) {
      throw err.error as ApiError;
    }
    throw ApiError.network(err.message ?? 'Network error');
  }
}

/// Parsed shape of the backend's GlobalExceptionHandler error body:
/// { status, error, message, timestamp }
class ApiError implements Exception {
  final int status;
  final String error;
  final String message;

  ApiError({required this.status, required this.error, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        status:  (json['status'] as num?)?.toInt() ?? 0,
        error:   json['error']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
      );

  factory ApiError.network(String message) =>
      ApiError(status: 0, error: 'network', message: message);

  bool get isUnauthorized => status == 401;
  bool get isForbidden    => status == 403;
  bool get isNotFound     => status == 404;
  bool get isConflict     => status == 409;
  bool get isBadRequest   => status == 400;

  @override
  String toString() => 'ApiError($status, $error): $message';
}
