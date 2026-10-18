import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

final class ListDevicesParams {
  const ListDevicesParams({
    required this.externalId,
    this.isActive,
    this.limit = 20,
    this.offset = 0,
  });

  final String externalId;
  final bool? isActive;
  final int limit;
  final int offset;
}

class ListDevicesUseCase implements UseCase<Page<Device>, ListDevicesParams> {
  ListDevicesUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<Either<Failure, Page<Device>>> call(ListDevicesParams params) =>
      _repository.listForUser(
        externalId: params.externalId,
        isActive: params.isActive,
        limit: params.limit,
        offset: params.offset,
      );
}
