import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({required this._remote});

  final DeviceRemoteDataSource _remote;

  @override
  Future<Either<Failure, Page<Device>>> listForUser({
    required String externalId,
    bool? isActive,
    int limit = 20,
    int offset = 0,
  }) => _remote.listForUser(
    externalId: externalId,
    isActive: isActive,
    limit: limit,
    offset: offset,
  );

  @override
  Future<Either<Failure, Device>> register({
    required String externalId,
    required DevicePlatform platform,
    required PushProvider provider,
    required String token,
    String? deviceName,
  }) => _remote.register(
    externalId: externalId,
    platform: platform,
    provider: provider,
    token: token,
    deviceName: deviceName,
  );

  @override
  Future<Either<Failure, Device>> update(
    String deviceId, {
    String? deviceName,
    bool? isActive,
  }) => _remote.update(deviceId, deviceName: deviceName, isActive: isActive);
}
