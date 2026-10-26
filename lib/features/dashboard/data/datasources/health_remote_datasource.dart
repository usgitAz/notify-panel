import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/config/env.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/health_status.dart';

class HealthRemoteDataSource {
  HealthRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /health — liveness probe. Expects `{ "status": "healthy" }`.
  Future<Either<Failure, HealthProbe>> checkLiveness() async {
    try {
      final response = await _dio.get<dynamic>(_url('/health'));
      return _parseProbe(
        response,
        expectedStatus: 'healthy',
        withChecks: false,
      );
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  /// GET /health/ready — readiness probe. Returns 200 when ready,
  /// 503 when one or more dependencies are unavailable. Both responses
  /// carry `{ "status": "...", "checks": { database, redis } }`.
  Future<Either<Failure, HealthProbe>> checkReadiness() async {
    try {
      final response = await _dio.get<dynamic>(_url('/health/ready'));
      return _parseProbe(response, expectedStatus: 'ready', withChecks: true);
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  // ─── Internals ───

  /// Absolute URL for health endpoints (which live outside `/api/v1`).
  static String _url(String path) =>
      Uri.parse(Env.apiBaseUrl).replace(path: path).toString();

  static Either<Failure, HealthProbe> _parseProbe(
    Response<dynamic> response, {
    required String expectedStatus,
    required bool withChecks,
  }) {
    final body = response.data;

    // Both 200 and 503 carry a valid probe body for readiness.
    final isProbeBody =
        (response.statusCode == 200 || response.statusCode == 503) &&
        body is Map;

    if (!isProbeBody) {
      return Left(FailureMapper.fromResponse(response));
    }

    final status = body['status'];
    final checks = <String, String>{};
    if (withChecks) {
      final raw = body['checks'];
      if (raw is Map) {
        for (final e in raw.entries) {
          if (e.value is String) {
            checks[e.key.toString()] = e.value as String;
          }
        }
      }
    }

    return Right(
      HealthProbe(
        ok: status == expectedStatus,
        status: status is String ? status : null,
        checks: withChecks && checks.isNotEmpty ? checks : null,
      ),
    );
  }
}
