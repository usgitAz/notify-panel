import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

final class ListNotificationsParams {
  const ListNotificationsParams({
    this.status,
    this.channel,
    this.limit = 20,
    this.offset = 0,
  });

  final NotificationStatus? status;
  final NotificationChannel? channel;
  final int limit;
  final int offset;
}

class ListNotificationsUseCase
    implements UseCase<Page<Notification>, ListNotificationsParams> {
  ListNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Page<Notification>>> call(
    ListNotificationsParams params,
  ) => _repository.list(
    status: params.status,
    channel: params.channel,
    limit: params.limit,
    offset: params.offset,
  );
}
