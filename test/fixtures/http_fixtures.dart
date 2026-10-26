import 'package:dio/dio.dart';

/// Builders for Dio [Response] and [DioException] used in tests.
abstract final class HttpFixtures {
  static Response<dynamic> response({
    required int statusCode,
    dynamic data,
    Map<String, List<String>> headers = const {},
  }) {
    return Response<dynamic>(
      statusCode: statusCode,
      data: data,
      headers: Headers.fromMap(headers),
      requestOptions: RequestOptions(path: '/test'),
    );
  }

  static Response<dynamic> successObject(Map<String, dynamic> data) => response(
    statusCode: 200,
    data: {
      'success': true,
      'data': data,
      'meta': {'timestamp': '2026-10-14T10:00:00Z', 'request_id': 'req_test'},
    },
  );

  static Response<dynamic> successPage({
    required List<Map<String, dynamic>> items,
    int total = 0,
    int limit = 20,
    int offset = 0,
    bool hasNext = false,
    bool hasPrev = false,
  }) => response(
    statusCode: 200,
    data: {
      'success': true,
      'data': {
        'items': items,
        'total': total,
        'limit': limit,
        'offset': offset,
        'has_next': hasNext,
        'has_prev': hasPrev,
      },
      'meta': {'timestamp': '2026-10-14T10:00:00Z', 'request_id': 'req_test'},
    },
  );

  static Response<dynamic> error({
    required int statusCode,
    required String code,
    String message = 'Error',
    List<Map<String, dynamic>>? details,
    Map<String, List<String>> headers = const {},
  }) => response(
    statusCode: statusCode,
    data: {
      'success': false,
      'error': {'code': code, 'message': message, 'details': ?details},
      'meta': {'timestamp': '2026-10-14T10:00:00Z', 'request_id': 'req_test'},
    },
    headers: headers,
  );

  static DioException dio({
    required DioExceptionType type,
    Response<dynamic>? response,
  }) => DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    response: response,
  );
}
