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

  Future<Either<Failure, Notification>> sendEmail({
    required String externalId,
    required String subject,
    required String body,
    String? fromEmail,
    String? replyTo,
    List<String> cc = const [],
    List<String> bcc = const [],
    List<String> attachments = const [],
  });
}
