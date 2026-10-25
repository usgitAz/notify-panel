import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Parameters for sending one email notification to a single recipient.
///
/// Bulk send is orchestrated in the composer notifier by calling this
/// use case once per recipient — the backend accepts exactly one
/// `user_id` per request.
final class SendEmailParams {
  const SendEmailParams({
    required this.externalId,
    required this.subject,
    required this.body,
    this.fromEmail,
    this.replyTo,
    this.cc = const [],
    this.bcc = const [],
    this.attachments = const [],
  });

  /// Recipient external ID as known by the tenant.
  final String externalId;

  final String subject;
  final String body;

  /// Optional custom From address. Backend falls back to SMTP_FROM.
  final String? fromEmail;

  /// Optional Reply-To address.
  final String? replyTo;

  /// Carbon-copy recipients (additional emails).
  final List<String> cc;

  /// Blind carbon-copy recipients.
  final List<String> bcc;

  /// URLs of files to attach (max 10 per backend).
  final List<String> attachments;
}

class SendEmailUseCase implements UseCase<Notification, SendEmailParams> {
  SendEmailUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, Notification>> call(SendEmailParams params) =>
      _repository.sendEmail(
        externalId: params.externalId,
        subject: params.subject,
        body: params.body,
        fromEmail: params.fromEmail,
        replyTo: params.replyTo,
        cc: params.cc,
        bcc: params.bcc,
        attachments: params.attachments,
      );
}
