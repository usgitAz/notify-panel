import 'dart:developer' as dev;

import 'package:dio/dio.dart';

/// Lightweight request/response logger for debug builds.
///
/// Sensitive headers are redacted before logging.
class LogInterceptor extends Interceptor {
  LogInterceptor({this.enabled = true});

  final bool enabled;

  static const _redacted = {'x-api-key', 'idempotency-key'};
  static const _name = 'http';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      dev.log('→ ${options.method} ${options.uri}', name: _name);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (enabled) {
      dev.log(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        name: _name,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      dev.log(
        '✗ ${err.type.name} ${err.requestOptions.uri} — ${err.message}',
        name: _name,
      );
    }
    handler.next(err);
  }

  /// Exposed for potential future use when logging headers.
  static Map<String, dynamic> redact(Map<String, dynamic> headers) => {
    for (final e in headers.entries)
      e.key: _redacted.contains(e.key.toLowerCase()) ? '***' : e.value,
  };
}
