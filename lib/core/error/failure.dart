import 'package:flutter/foundation.dart';

/// A single field-level error, mirroring the backend's `ErrorDetail`.
///
/// `field` and `code` are optional; `message` is always present.
@immutable
class FieldError {
  const FieldError({this.field, this.code, required this.message});

  /// Dot-path to the offending field, e.g., `body.external_id`.
  final String? field;

  /// Machine-readable sub-code, e.g., `string_too_short`.
  final String? code;

  /// Human-readable description.
  final String message;

  /// The last segment of [field], ignoring any location prefix.
  /// `body.external_id` → `external_id`
  String? get leafField => field?.split('.').last;

  @override
  String toString() =>
      'FieldError(field: $field, code: $code, '
      'message: $message)';
}

/// Domain-level failures returned by repositories and use cases.
///
/// Failures are pure Dart — no Flutter imports (beyond `foundation` for
/// `@immutable`), no network DTOs, no UI concerns. User-facing messages
/// are produced separately in `failure_messages.dart`.
sealed class Failure {
  const Failure({this.code, this.message});

  /// Backend stable, machine-readable code in SCREAMING_SNAKE_CASE.
  /// Example: `USER_NOT_FOUND`, `DEVICE_TOKEN_TAKEN`.
  ///
  /// Present only when the failure originated from a structured API
  /// response. Safe to branch on.
  final String? code;

  /// Backend human-readable message. May change over time —
  /// do not branch on it. Kept for logging and debugging.
  final String? message;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// 401 — missing, invalid, or expired API key.
/// Backend code: `AUTHENTICATION_REQUIRED`.
final class AuthFailure extends Failure {
  const AuthFailure({super.code, super.message});
}

/// 404 — the requested resource does not exist.
/// Backend codes: `USER_NOT_FOUND`, `DEVICE_NOT_FOUND`,
/// `NOTIFICATION_NOT_FOUND`.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.code, super.message});
}

/// 409 — a uniqueness or state conflict.
/// Backend codes: `USER_ALREADY_EXISTS`, `USER_EXISTS_INACTIVE`,
/// `DEVICE_TOKEN_TAKEN`, `DEVICE_ALREADY_REGISTERED`.
final class ConflictFailure extends Failure {
  const ConflictFailure({super.code, super.message});
}

/// 422 — request validation failed with field-level details.
///
/// Note: the backend may also return `422` for semantic issues
/// (e.g., `USER_HAS_NO_EMAIL`) where `details` is empty. In that case
/// branch on [code] rather than looking for field errors.
final class ValidationFailure extends Failure {
  const ValidationFailure({super.code, super.message, this.details = const []});

  /// List of field-level errors. May be empty even for 422.
  final List<FieldError> details;

  /// All errors matching the given full dot-path (e.g., `body.external_id`).
  List<FieldError> errorsFor(String field) =>
      details.where((e) => e.field == field).toList();

  /// All errors whose leaf field name matches (e.g., `external_id`
  /// matches `body.external_id`). Useful in form widgets that don't
  /// know the backend's location prefix.
  List<FieldError> errorsForLeaf(String leaf) =>
      details.where((e) => e.leafField == leaf).toList();

  /// First message for a given leaf field, or `null`.
  String? firstMessageForLeaf(String leaf) =>
      errorsForLeaf(leaf).firstOrNull?.message;

  /// Errors grouped by their full dot-path field.
  /// Errors with a `null` field are keyed under `'_'`.
  Map<String, List<FieldError>> get groupedByField {
    final map = <String, List<FieldError>>{};
    for (final e in details) {
      map.putIfAbsent(e.field ?? '_', () => []).add(e);
    }
    return map;
  }
}

/// 429 — client exceeded the rate limit.
/// Backend code: (not implemented yet; reserved).
final class RateLimitFailure extends Failure {
  const RateLimitFailure({super.code, super.message, this.retryAfter});

  final Duration? retryAfter;
}

/// 5xx from an upstream dependency the backend proxies to.
final class ExternalServiceFailure extends Failure {
  const ExternalServiceFailure({super.code, super.message, this.service});

  /// Optional upstream label, e.g., `smtp`, `fcm`.
  final String? service;
}

/// 5xx — server-side failure.
/// Backend code: `INTERNAL_SERVER_ERROR`.
final class ServerFailure extends Failure {
  const ServerFailure({super.code, super.message, this.statusCode});

  final int? statusCode;
}

/// Transport-level failure (connection refused, timeout, offline).
/// Not produced by the backend — no [code].
final class NetworkFailure extends Failure {
  const NetworkFailure({super.code, super.message});
}

/// Response could not be parsed into the expected shape.
/// Not produced by the backend — no [code].
final class ParseFailure extends Failure {
  const ParseFailure({super.code, super.message});
}

/// Fallback for anything not covered above.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.code, super.message});
}
