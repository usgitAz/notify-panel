import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/envelope_parser.dart';
import '../../domain/entities/user.dart';
import '../models/user_dto.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Either<Failure, User>> getByExternalId(String externalId) async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.user(externalId));
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: UserDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  Future<Either<Failure, User>> create({
    required String externalId,
    String? email,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.users,
        data: {
          'external_id': externalId,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: UserDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  Future<Either<Failure, User>> update(
    String externalId, {
    String? email,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{
        if (email != null) 'email': email.isEmpty ? null : email,
        'is_active': ?isActive,
      };
      final response = await _dio.patch<dynamic>(
        ApiEndpoints.user(externalId),
        data: body,
      );
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: UserDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }
}
