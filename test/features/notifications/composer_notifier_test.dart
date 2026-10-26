import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notify_panel/core/error/failure.dart';
import 'package:notify_panel/features/notifications/domain/entities/notification.dart';
import 'package:notify_panel/features/notifications/domain/usecases/send_email_usecase.dart';
import 'package:notify_panel/features/notifications/presentation/providers/composer_provider.dart';
import 'package:notify_panel/features/notifications/presentation/providers/notification_providers.dart';

class _MockSendEmail extends Mock implements SendEmailUseCase {}

Notification _fakeNotification(String id) => Notification(
  id: id,
  tenantId: 't1',
  userId: 'u1',
  userExternalId: 'user',
  channel: NotificationChannel.email,
  title: 'Hi',
  body: 'Body',
  payload: const {},
  status: NotificationStatus.pending,
  attempts: 0,
  lastError: null,
  createdAt: DateTime.utc(2026, 10, 14),
  updatedAt: DateTime.utc(2026, 10, 14),
);

void main() {
  late _MockSendEmail mockUseCase;

  setUp(() {
    mockUseCase = _MockSendEmail();
    registerFallbackValue(
      const SendEmailParams(externalId: 'x', subject: 'x', body: 'x'),
    );
  });

  ProviderContainer container0() => ProviderContainer(
    overrides: [sendEmailUseCaseProvider.overrideWithValue(mockUseCase)],
  );

  group('ComposerNotifier.sendBulk', () {
    test('empty recipients → no-op', () async {
      final container = container0();
      addTearDown(container.dispose);

      final notifier = container.read(composerProvider.notifier);
      await notifier.sendBulk(recipients: const [], subject: 's', body: 'b');

      expect(container.read(composerProvider).isSending, isFalse);
      expect(container.read(composerProvider).total, 0);
      verifyNever(() => mockUseCase.call(any()));
    });

    test('all succeed → all delivered, progress complete', () async {
      when(() => mockUseCase.call(any())).thenAnswer((inv) async {
        final params = inv.positionalArguments.first as SendEmailParams;
        return Right(_fakeNotification(params.externalId));
      });

      final container = container0();
      addTearDown(container.dispose);

      await container
          .read(composerProvider.notifier)
          .sendBulk(
            recipients: const ['a', 'b', 'c'],
            subject: 'Hi',
            body: 'Body',
          );

      final state = container.read(composerProvider);
      expect(state.isSending, isFalse);
      expect(state.total, 3);
      expect(state.completed, 3);
      expect(state.isDone, isTrue);
      expect(state.successCount, 3);
      expect(state.failureCount, 0);
      expect(state.progress, 1.0);
    });

    test('partial failure → mixed results', () async {
      when(() => mockUseCase.call(any())).thenAnswer((inv) async {
        final params = inv.positionalArguments.first as SendEmailParams;
        if (params.externalId == 'bad') {
          return const Left(
            ValidationFailure(code: 'USER_HAS_NO_EMAIL', details: []),
          );
        }
        return Right(_fakeNotification(params.externalId));
      });

      final container = container0();
      addTearDown(container.dispose);

      await container
          .read(composerProvider.notifier)
          .sendBulk(
            recipients: const ['a', 'bad', 'c'],
            subject: 'Hi',
            body: 'Body',
          );

      final state = container.read(composerProvider);
      expect(state.isDone, isTrue);
      expect(state.successCount, 2);
      expect(state.failureCount, 1);
      expect(state.completed, 3);
      expect(
        state.results.firstWhere((r) => r.externalId == 'bad').failure,
        isA<ValidationFailure>(),
      );
    });

    test('auth failure stops the loop early', () async {
      var callCount = 0;
      when(() => mockUseCase.call(any())).thenAnswer((inv) async {
        callCount++;
        if (callCount == 2) {
          return const Left(AuthFailure(code: 'AUTHENTICATION_REQUIRED'));
        }
        final params = inv.positionalArguments.first as SendEmailParams;
        return Right(_fakeNotification(params.externalId));
      });

      final container = container0();
      addTearDown(container.dispose);

      await container
          .read(composerProvider.notifier)
          .sendBulk(
            recipients: const ['a', 'b', 'c', 'd'],
            subject: 'Hi',
            body: 'Body',
          );

      final state = container.read(composerProvider);
      expect(state.isSending, isFalse);
      expect(state.isDone, isFalse); // stopped before full completion
      expect(state.completed, 2);
      expect(state.successCount, 1);
      expect(state.failureCount, 1);
      expect(
        state.results.where((r) => r.status == RecipientStatus.pending).length,
        2, // c and d never sent
      );
    });

    test('progress state visible mid-send', () async {
      final completer1 = Completer<Either<Failure, Notification>>();
      final completer2 = Completer<Either<Failure, Notification>>();
      var calls = 0;

      when(() => mockUseCase.call(any())).thenAnswer((_) {
        calls++;
        if (calls == 1) return completer1.future;
        return completer2.future;
      });

      final container = container0();
      addTearDown(container.dispose);

      final notifier = container.read(composerProvider.notifier);
      final future = notifier.sendBulk(
        recipients: const ['a', 'b'],
        subject: 'Hi',
        body: 'Body',
      );

      // Let the loop start
      await Future<void>.delayed(Duration.zero);

      var state = container.read(composerProvider);
      expect(state.isSending, isTrue);
      expect(state.total, 2);
      expect(state.results.first.status, RecipientStatus.sending);

      // Complete first, second becomes sending
      completer1.complete(Right(_fakeNotification('a')));
      await Future<void>.delayed(Duration.zero);

      state = container.read(composerProvider);
      expect(state.completed, 1);
      expect(state.results.first.status, RecipientStatus.delivered);

      // Complete second
      completer2.complete(Right(_fakeNotification('b')));
      await future;

      state = container.read(composerProvider);
      expect(state.isDone, isTrue);
    });

    test('reset clears state', () async {
      when(() => mockUseCase.call(any()))
          .thenAnswer((_) async => Right(_fakeNotification('x')));

      final container = container0();
      addTearDown(container.dispose);

      final notifier = container.read(composerProvider.notifier);
      await notifier.sendBulk(recipients: const ['a'], subject: 's', body: 'b');

      expect(container.read(composerProvider).hasResults, isTrue);

      notifier.reset();

      final state = container.read(composerProvider);
      expect(state.hasResults, isFalse);
      expect(state.isSending, isFalse);
      expect(state.total, 0);
    });
  });
}
