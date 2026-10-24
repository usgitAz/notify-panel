import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../entities/notification.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, Page<Notification>>> list({
    NotificationStatus? status,
    NotificationChannel? channel,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, Notification>> getById(String id);
}
