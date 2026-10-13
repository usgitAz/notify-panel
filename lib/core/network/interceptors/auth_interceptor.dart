import 'package:dio/dio.dart';

/// Injects the tenant API key into every authenticated request.
///
/// Health endpoints (mounted at the service root, outside `/api/v1`)
/// are skipped — they are public.
///
/// A 401 on any response triggers [onUnauthorized] so the app can log
/// out and redirect to the login screen.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getApiKey, required this.onUnauthorized});

  final String? Function() getApiKey;
  final void Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isPublic(options.uri.path)) {
      return handler.next(options);
    }

    final key = getApiKey();
    if (key != null && key.isNotEmpty) {
      options.headers['X-API-Key'] = key;
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.statusCode == 401) onUnauthorized();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) onUnauthorized();
    handler.next(err);
  }

  static bool _isPublic(String path) => path.startsWith('/health');
}
