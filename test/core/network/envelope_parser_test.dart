import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:notify_panel/core/error/failure.dart';
import 'package:notify_panel/core/network/envelope_parser.dart';

import '../../fixtures/http_fixtures.dart';

void main() {
  group('EnvelopeParser.parseObject', () {
    test('unwraps data on success', () {
      final result = EnvelopeParser.parseObject<String>(
        response: HttpFixtures.successObject({'name': 'alice'}),
        fromJson: (json) => json['name'] as String,
      );
      expect(result, const Right<Failure, String>('alice'));
    });

    test('returns AuthFailure on 401 envelope', () {
      final result = EnvelopeParser.parseObject<String>(
        response: HttpFixtures.error(
          statusCode: 401,
          code: 'AUTHENTICATION_REQUIRED',
        ),
        fromJson: (_) => '',
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<AuthFailure>());
    });

    test('returns ParseFailure when data is not a Map', () {
      final result = EnvelopeParser.parseObject<String>(
        response: HttpFixtures.response(
          statusCode: 200,
          data: {'success': true, 'data': 'not-an-object', 'meta': {}},
        ),
        fromJson: (_) => '',
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ParseFailure>());
    });

    test('returns ParseFailure when fromJson throws', () {
      final result = EnvelopeParser.parseObject<String>(
        response: HttpFixtures.successObject({'name': 'alice'}),
        fromJson: (_) => throw const FormatException('boom'),
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ParseFailure>());
    });

    test('returns ParseFailure when body is not a Map', () {
      final result = EnvelopeParser.parseObject<String>(
        response: HttpFixtures.response(statusCode: 200, data: 'oops'),
        fromJson: (_) => '',
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ParseFailure>());
    });
  });

  group('EnvelopeParser.parseList', () {
    test('unwraps list on success', () {
      final result = EnvelopeParser.parseList<String>(
        response: HttpFixtures.response(
          statusCode: 200,
          data: {
            'success': true,
            'data': [
              {'name': 'a'},
              {'name': 'b'},
            ],
            'meta': {},
          },
        ),
        fromJson: (json) => json['name'] as String,
      );

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable(), equals(['a', 'b']));
    });

    test('returns ParseFailure when data is not a List', () {
      final result = EnvelopeParser.parseList<String>(
        response: HttpFixtures.successObject({'x': 1}),
        fromJson: (_) => '',
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ParseFailure>());
    });
  });

  group('EnvelopeParser.parsePage', () {
    test('unwraps page metadata correctly', () {
      final result = EnvelopeParser.parsePage<String>(
        response: HttpFixtures.successPage(
          items: [
            {'name': 'a'},
            {'name': 'b'},
          ],
          total: 42,
          limit: 20,
          offset: 20,
          hasNext: true,
          hasPrev: true,
        ),
        itemFromJson: (json) => json['name'] as String,
      );

      expect(result.isRight(), isTrue);
      final page = result.getRight().toNullable()!;
      expect(page.items, ['a', 'b']);
      expect(page.total, 42);
      expect(page.limit, 20);
      expect(page.offset, 20);
      expect(page.hasNext, isTrue);
      expect(page.hasPrev, isTrue);
    });

    test('returns ParseFailure when items is not a List', () {
      final result = EnvelopeParser.parsePage<String>(
        response: HttpFixtures.response(
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'items': 'not-a-list',
              'total': 0,
              'limit': 20,
              'offset': 0,
              'has_next': false,
              'has_prev': false,
            },
            'meta': {},
          },
        ),
        itemFromJson: (_) => '',
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ParseFailure>());
    });

    test('returns ParseFailure when metadata is missing', () {
      final result = EnvelopeParser.parsePage<String>(
        response: HttpFixtures.response(
          statusCode: 200,
          data: {
            'success': true,
            'data': {'items': <dynamic>[]},
            'meta': {},
          },
        ),
        itemFromJson: (_) => '',
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ParseFailure>());
    });
  });

  group('EnvelopeParser.parseVoid', () {
    test('returns unit on success', () {
      final result = EnvelopeParser.parseVoid(
        HttpFixtures.response(
          statusCode: 200,
          data: {'success': true, 'data': null, 'meta': {}},
        ),
      );
      expect(result, const Right<Failure, Unit>(unit));
    });

    test('returns Left on error envelope', () {
      final result = EnvelopeParser.parseVoid(
        HttpFixtures.error(statusCode: 409, code: 'USER_ALREADY_EXISTS'),
      );
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<ConflictFailure>());
    });
  });
}
