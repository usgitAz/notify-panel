import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notify_panel/core/error/failure.dart';
import 'package:notify_panel/core/error/failure_mapper.dart';

import '../../fixtures/http_fixtures.dart';

void main() {
  group('FailureMapper.fromDio — transport errors', () {
    test('connection timeout → NetworkFailure', () {
      final f = FailureMapper.fromDio(
        HttpFixtures.dio(type: DioExceptionType.connectionTimeout),
      );
      expect(f, isA<NetworkFailure>());
    });

    test('transform timeout → NetworkFailure', () {
      final f = FailureMapper.fromDio(
        HttpFixtures.dio(type: DioExceptionType.transformTimeout),
      );
      expect(f, isA<NetworkFailure>());
    });

    test('cancel → UnknownFailure', () {
      final f = FailureMapper.fromDio(
        HttpFixtures.dio(type: DioExceptionType.cancel),
      );
      expect(f, isA<UnknownFailure>());
    });

    test('bad certificate → NetworkFailure', () {
      final f = FailureMapper.fromDio(
        HttpFixtures.dio(type: DioExceptionType.badCertificate),
      );
      expect(f, isA<NetworkFailure>());
    });

    test('badResponse delegates to fromResponse', () {
      final f = FailureMapper.fromDio(
        HttpFixtures.dio(
          type: DioExceptionType.badResponse,
          response: HttpFixtures.error(statusCode: 404, code: 'USER_NOT_FOUND'),
        ),
      );
      expect(f, isA<NotFoundFailure>());
      expect(f.code, 'USER_NOT_FOUND');
    });
  });

  group('FailureMapper.fromResponse — status mapping', () {
    test('401 → AuthFailure with code', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(statusCode: 401, code: 'AUTHENTICATION_REQUIRED'),
      );
      expect(f, isA<AuthFailure>());
      expect(f.code, 'AUTHENTICATION_REQUIRED');
    });

    test('409 → ConflictFailure', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(statusCode: 409, code: 'USER_ALREADY_EXISTS'),
      );
      expect(f, isA<ConflictFailure>());
      expect(f.code, 'USER_ALREADY_EXISTS');
    });

    test('422 with details → ValidationFailure with parsed fields', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(
          statusCode: 422,
          code: 'VALIDATION_ERROR',
          details: [
            {
              'field': 'body.external_id',
              'code': 'string_too_short',
              'message': 'String should have at least 1 character',
            },
          ],
        ),
      );
      expect(f, isA<ValidationFailure>());
      final v = f as ValidationFailure;
      expect(v.details, hasLength(1));
      expect(v.details.first.field, 'body.external_id');
      expect(
        v.firstMessageForLeaf('external_id'),
        'String should have at least 1 character',
      );
    });

    test('422 without details still parses', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(statusCode: 422, code: 'USER_HAS_NO_EMAIL'),
      );
      expect(f, isA<ValidationFailure>());
      expect((f as ValidationFailure).details, isEmpty);
    });

    test('429 parses Retry-After header', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(
          statusCode: 429,
          code: 'RATE_LIMITED',
          headers: {
            'retry-after': ['30'],
          },
        ),
      );
      expect(f, isA<RateLimitFailure>());
      expect((f as RateLimitFailure).retryAfter, const Duration(seconds: 30));
    });

    test('500 → ServerFailure with status code', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(statusCode: 500, code: 'INTERNAL_SERVER_ERROR'),
      );
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, 500);
    });

    test('unknown status (418) → UnknownFailure', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.error(statusCode: 418, code: 'TEAPOT'),
      );
      expect(f, isA<UnknownFailure>());
    });

    test('null response → UnknownFailure', () {
      expect(FailureMapper.fromResponse(null), isA<UnknownFailure>());
    });

    test('non-envelope body still maps by status code', () {
      final f = FailureMapper.fromResponse(
        HttpFixtures.response(statusCode: 404, data: 'plain text'),
      );
      expect(f, isA<NotFoundFailure>());
      expect(f.code, isNull);
    });
  });
}
