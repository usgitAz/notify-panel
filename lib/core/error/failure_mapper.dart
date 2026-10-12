import 'package:dio/dio.dart';

import 'failure.dart';

/// Converts HTTP errors and transport exceptions into domain [Failure]s.
///
/// This is the single place where the wire format (status codes,
/// backend error codes) is translated into the domain error model.
abstract final class FailureMapper {
  /// Maps a [DioException] to a domain [Failure].
  static Failure fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'The server certificate could not be verified.',
        );

      case DioExceptionType.badResponse:
        return fromResponse(e.response);

      case DioExceptionType.unknown:
        return const NetworkFailure();
    }
  }

  /// Maps an HTTP [Response] to a domain [Failure] using status code
  /// and the backend's structured error envelope.
  static Failure fromResponse(Response<dynamic>? response) {
    if (response == null) return const UnknownFailure();

    final status = response.statusCode ?? 0;
    final body = response.data;

    // Extract structured error fields when the envelope matches.
    final error = _extractError(body);
    final code = error?.code;
    final message = error?.message;
    final details = error?.details ?? const [];

    return switch (status) {
      401 || 403 => AuthFailure(code: code, message: message),
      404 => NotFoundFailure(code: code, message: message),
      409 => ConflictFailure(code: code, message: message),
      422 => ValidationFailure(code: code, message: message, details: details),
      429 => RateLimitFailure(
        code: code,
        message: message,
        retryAfter: _retryAfter(response),
      ),
      >= 500 && < 600 => ServerFailure(
        code: code,
        message: message,
        statusCode: status,
      ),
      _ => UnknownFailure(code: code, message: message),
    };
  }

  /// Maps a JSON parsing error to a [ParseFailure].
  static const Failure parseFailure = ParseFailure();

  // ─── Internals ───

  static _ParsedError? _extractError(dynamic body) {
    if (body is! Map) return null;
    final error = body['error'];
    if (error is! Map) return null;

    final code = error['code'];
    final message = error['message'];
    final rawDetails = error['details'];

    final details = <FieldError>[];
    if (rawDetails is List) {
      for (final d in rawDetails) {
        if (d is! Map) continue;
        details.add(
          FieldError(
            field: d['field'] as String?,
            code: d['code'] as String?,
            message: (d['message'] as String?) ?? '',
          ),
        );
      }
    }

    return _ParsedError(
      code: code is String ? code : null,
      message: message is String ? message : null,
      details: details,
    );
  }

  static Duration? _retryAfter(Response<dynamic> response) {
    final raw = response.headers.value('retry-after');
    if (raw == null) return null;
    final seconds = int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }
}

class _ParsedError {
  const _ParsedError({
    required this.code,
    required this.message,
    required this.details,
  });

  final String? code;
  final String? message;
  final List<FieldError> details;
}
