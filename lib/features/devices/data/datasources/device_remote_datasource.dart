import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/envelope_parser.dart';
import '../../../../core/network/page.dart';
import '../../domain/entities/device.dart';
import '../models/device_dto.dart';

class DeviceRemoteDataSource {
  DeviceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Either<Failure, Page<Device>>> listForUser({
    required String externalId,
    bool? isActive,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.userDevices(externalId),
        queryParameters: {
          'is_active': ?isActive,
          'limit': limit,
          'offset': offset,
        },
      );
      return EnvelopeParser.parsePage(
        response: response,
        itemFromJson: DeviceDto.fromJson,
      ).map((page) => page.map((dto) => dto.toEntity()));
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  Future<Either<Failure, Device>> register({
    required String externalId,
    required DevicePlatform platform,
    required PushProvider provider,
    required String token,
    String? deviceName,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.registerDevice(externalId),
        data: {
          'platform': platform.wire,
          'provider': provider.wire,
          'token': token,
          if (deviceName != null && deviceName.isNotEmpty)
            'device_name': deviceName,
        },
      );
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: DeviceDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  Future<Either<Failure, Device>> update(
    String deviceId, {
    String? deviceName,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{
        if (deviceName != null)
          'device_name': deviceName.isEmpty ? null : deviceName,
        'is_active': ?isActive,
      };
      final response = await _dio.patch<dynamic>(
        ApiEndpoints.device(deviceId),
        data: body,
      );
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: DeviceDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }
}
