import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/send_email_usecase.dart';
import 'notification_providers.dart';

enum RecipientStatus { pending, sending, delivered, failed }

@immutable
class RecipientResult {
  const RecipientResult({
    required this.externalId,
    required this.status,
    this.notification,
    this.failure,
  });

  factory RecipientResult.pending(String id) =>
      RecipientResult(externalId: id, status: RecipientStatus.pending);

  factory RecipientResult.sending(String id) =>
      RecipientResult(externalId: id, status: RecipientStatus.sending);

  factory RecipientResult.delivered(String id, Notification notification) =>
      RecipientResult(
        externalId: id,
        status: RecipientStatus.delivered,
        notification: notification,
      );

  factory RecipientResult.failed(String id, Failure failure) => RecipientResult(
    externalId: id,
    status: RecipientStatus.failed,
    failure: failure,
  );

  final String externalId;
  final RecipientStatus status;
  final Notification? notification;
  final Failure? failure;
}

@immutable
class ComposerState {
  const ComposerState({
    required this.isSending,
    required this.completed,
    required this.total,
    required this.results,
  });

  const ComposerState.initial()
    : isSending = false,
      completed = 0,
      total = 0,
      results = const [];

  final bool isSending;
  final int completed;
  final int total;
  final List<RecipientResult> results;

  bool get isDone => !isSending && total > 0 && completed == total;
  bool get hasResults => results.isNotEmpty;

  int get successCount =>
      results.where((r) => r.status == RecipientStatus.delivered).length;

  int get failureCount =>
      results.where((r) => r.status == RecipientStatus.failed).length;

  double get progress => total == 0 ? 0 : completed / total;

  ComposerState copyWith({
    bool? isSending,
    int? completed,
    int? total,
    List<RecipientResult>? results,
  }) => ComposerState(
    isSending: isSending ?? this.isSending,
    completed: completed ?? this.completed,
    total: total ?? this.total,
    results: results ?? this.results,
  );
}

class ComposerNotifier extends Notifier<ComposerState> {
  @override
  ComposerState build() => const ComposerState.initial();

  /// Sends the email to every recipient sequentially.
  ///
  /// Sequential (not parallel) to avoid bursty traffic and rate-limit
  /// surprises. Each request carries a unique Idempotency-Key from the
  /// interceptor — retries get fresh keys, so users can safely retry
  /// after a failure. Stops early on AuthFailure.
  Future<void> sendBulk({
    required List<String> recipients,
    required String subject,
    required String body,
    String? fromEmail,
    String? replyTo,
    List<String> cc = const [],
    List<String> bcc = const [],
    List<String> attachments = const [],
  }) async {
    if (state.isSending || recipients.isEmpty) return;

    state = ComposerState(
      isSending: true,
      completed: 0,
      total: recipients.length,
      results: recipients.map(RecipientResult.pending).toList(growable: false),
    );

    final useCase = ref.read(sendEmailUseCaseProvider);

    for (var i = 0; i < recipients.length; i++) {
      final externalId = recipients[i];
      _updateResult(i, RecipientResult.sending(externalId));

      final either = await useCase.call(
        SendEmailParams(
          externalId: externalId,
          subject: subject,
          body: body,
          fromEmail: fromEmail,
          replyTo: replyTo,
          cc: cc,
          bcc: bcc,
          attachments: attachments,
        ),
      );

      either.match(
        (failure) =>
            _updateResult(i, RecipientResult.failed(externalId, failure)),
        (n) => _updateResult(i, RecipientResult.delivered(externalId, n)),
      );

      state = state.copyWith(completed: i + 1);

      final authFailure = either.fold<AuthFailure?>(
        (f) => f is AuthFailure ? f : null,
        (_) => null,
      );
      if (authFailure != null) {
        state = state.copyWith(isSending: false);
        return;
      }
    }

    state = state.copyWith(isSending: false);
  }

  void reset() => state = const ComposerState.initial();

  void _updateResult(int index, RecipientResult result) {
    final next = [...state.results];
    next[index] = result;
    state = state.copyWith(results: next);
  }
}

final composerProvider = NotifierProvider<ComposerNotifier, ComposerState>(
  ComposerNotifier.new,
);
