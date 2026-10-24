import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/envelope_parser.dart';
import '../../../../core/network/page.dart';
import '../../domain/entities/notification.dart';
import '../models/notification_dto.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Either<Failure, Page<Notification>>> list({
    NotificationStatus? status,
    NotificationChannel? channel,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.notifications,
        queryParameters: {
          if (status != null) 'status': status.wire,
          if (channel != null) 'channel': channel.wire,
          'limit': limit,
          'offset': offset,
        },
      );
      return EnvelopeParser.parsePage(
        response: response,
        itemFromJson: NotificationDto.fromJson,
      ).map((page) => page.map((dto) => dto.toEntity()));
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }

  Future<Either<Failure, Notification>> getById(String id) async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.notification(id));
      return EnvelopeParser.parseObject(
        response: response,
        fromJson: NotificationDto.fromJson,
      ).map((dto) => dto.toEntity());
    } on DioException catch (e) {
      return Left(FailureMapper.fromDio(e));
    }
  }
}
