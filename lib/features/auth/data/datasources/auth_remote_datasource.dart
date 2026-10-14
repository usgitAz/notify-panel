import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/envelope_parser.dart';
import '../../domain/entities/tenant.dart';
import '../models/tenant_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Validates [apiKey] and returns the owning tenant.
  ///
  /// Sets the header explicitly rather than relying on the interceptor,
  /// because during login the holder is not populated yet.
  Future<Either<Failure, Tenant>> fetchCurrentTenant(String apiKey) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.authMe,
        options: Options(headers: {'X-API-Key': apiKey}),
      );
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: TenantDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }
}
