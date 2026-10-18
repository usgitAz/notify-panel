import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

final class RegisterDeviceParams {
  const RegisterDeviceParams({
    required this.externalId,
    required this.platform,
    required this.provider,
    required this.token,
    this.deviceName,
  });

  final String externalId;
  final DevicePlatform platform;
  final PushProvider provider;
  final String token;
  final String? deviceName;
}

class RegisterDeviceUseCase implements UseCase<Device, RegisterDeviceParams> {
  RegisterDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<Either<Failure, Device>> call(RegisterDeviceParams params) =>
      _repository.register(
        externalId: params.externalId,
        platform: params.platform,
        provider: params.provider,
        token: params.token,
        deviceName: params.deviceName,
      );
}
