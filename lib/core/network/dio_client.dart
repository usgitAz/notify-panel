import 'package:dio/dio.dart' hide LogInterceptor;

import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/idempotency_interceptor.dart';
import 'interceptors/log_interceptor.dart';

/// Builds the shared [Dio] instance used across the app.
///
/// - All responses (including 4xx/5xx) are returned to the caller
///   instead of throwing, so [EnvelopeParser] can unwrap them.
/// - Only transport-level failures (timeouts, connection errors)
///   surface as [DioException].
abstract final class DioClient {
  static Dio create({
    required String? Function() getApiKey,
    required void Function() onUnauthorized,
    LogInterceptor? logInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        sendTimeout: Env.sendTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (_) => true,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(getApiKey: getApiKey, onUnauthorized: onUnauthorized),
      IdempotencyInterceptor(),
      logInterceptor ?? LogInterceptor(enabled: !Env.isProduction),
    ]);

    return dio;
  }
}
