import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';
import '../error/failure_mapper.dart';

/// Parses the backend's standard response envelope into domain values.
///
/// Success envelope: `{ success: true, data: <T>, meta: {...} }`
/// Error envelope:   `{ success: false, error: {code, message, details?},
///                     meta: {...} }`
///
/// This class is intentionally thin: it only unwraps the envelope and
/// delegates error mapping to [FailureMapper]. JSON-to-model conversion
/// is the responsibility of DTOs in each feature's data layer.
abstract final class EnvelopeParser {
  /// Parses a success response whose `data` is a single JSON object.
  static Either<Failure, T> parseObject<T>({
    required Response<dynamic> response,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return _parse(response, (data) {
      if (data is! Map<String, dynamic>) {
        throw FormatException(
          'Expected a JSON object at "data" but got ${data.runtimeType}.',
        );
      }
      return fromJson(data);
    });
  }

  /// Parses a success response whose `data` is a JSON array.
  static Either<Failure, List<T>> parseList<T>({
    required Response<dynamic> response,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return _parse(response, (data) {
      if (data is! List) {
        throw FormatException(
          'Expected a JSON array at "data" but got ${data.runtimeType}.',
        );
      }
      return data
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    });
  }

  /// Parses a success response with no payload.
  static Either<Failure, Unit> parseVoid(Response<dynamic> response) {
    return _parse(response, (_) => unit);
  }

  // ─── Internals ───

  static Either<Failure, T> _parse<T>(
    Response<dynamic> response,
    T Function(dynamic data) fromData,
  ) {
    final body = response.data;

    if (body is! Map) {
      return const Left(
        ParseFailure(message: 'Response body is not a JSON object.'),
      );
    }

    if (body['success'] != true) {
      return Left(FailureMapper.fromResponse(response));
    }

    try {
      return Right(fromData(body['data']));
    } catch (e) {
      return Left(ParseFailure(message: e.toString()));
    }
  }
}
