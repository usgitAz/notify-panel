import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Adds an `Idempotency-Key` header to every POST request.
///
/// Callers may set their own key beforehand; we never override it.
/// This makes retries safe on the backend (Redis-backed).
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  static const _header = 'Idempotency-Key';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'POST' &&
        !options.headers.containsKey(_header)) {
      options.headers[_header] = _uuid.v4();
    }
    handler.next(options);
  }
}
