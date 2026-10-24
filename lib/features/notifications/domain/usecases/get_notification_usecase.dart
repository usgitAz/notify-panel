import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationUseCase implements UseCase<Notification, String> {
  GetNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Notification>> call(String id) =>
      _repository.getById(id);
}
