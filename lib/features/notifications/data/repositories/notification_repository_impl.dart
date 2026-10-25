import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required this._remote});

  final NotificationRemoteDataSource _remote;

  @override
  Future<Either<Failure, Page<Notification>>> list({
    NotificationStatus? status,
    NotificationChannel? channel,
    int limit = 20,
    int offset = 0,
  }) => _remote.list(
    status: status,
    channel: channel,
    limit: limit,
    offset: offset,
  );

  @override
  Future<Either<Failure, Notification>> getById(String id) =>
      _remote.getById(id);

  @override
  Future<Either<Failure, Notification>> sendEmail({
    required String externalId,
    required String subject,
    required String body,
    String? fromEmail,
    String? replyTo,
    List<String> cc = const [],
    List<String> bcc = const [],
    List<String> attachments = const [],
  }) => _remote.sendEmail(
    externalId: externalId,
    subject: subject,
    body: body,
    fromEmail: fromEmail,
    replyTo: replyTo,
    cc: cc,
    bcc: bcc,
    attachments: attachments,
  );
}
