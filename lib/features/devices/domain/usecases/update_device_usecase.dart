import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

final class UpdateDeviceParams {
  const UpdateDeviceParams({
    required this.deviceId,
    this.deviceName,
    this.isActive,
  });

  final String deviceId;
  final String? deviceName;
  final bool? isActive;
}

class UpdateDeviceUseCase implements UseCase<Device, UpdateDeviceParams> {
  UpdateDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<Either<Failure, Device>> call(UpdateDeviceParams params) =>
      _repository.update(
        params.deviceId,
        deviceName: params.deviceName,
        isActive: params.isActive,
      );
}
