import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../entities/device.dart';

abstract interface class DeviceRepository {
  Future<Either<Failure, Page<Device>>> listForUser({
    required String externalId,
    bool? isActive,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, Device>> register({
    required String externalId,
    required DevicePlatform platform,
    required PushProvider provider,
    required String token,
    String? deviceName,
  });

  Future<Either<Failure, Device>> update(
    String deviceId, {
    String? deviceName,
    bool? isActive,
  });
}
