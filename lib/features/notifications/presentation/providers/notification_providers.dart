import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notification_usecase.dart';
import '../../domain/usecases/list_notifications_usecase.dart';

// ─── Data sources ───

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
      (ref) => NotificationRemoteDataSource(ref.watch(dioProvider)),
    );

// ─── Repository ───

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    remote: ref.watch(notificationRemoteDataSourceProvider),
  ),
);

// ─── Use cases ───

final listNotificationsUseCaseProvider = Provider<ListNotificationsUseCase>(
  (ref) => ListNotificationsUseCase(ref.watch(notificationRepositoryProvider)),
);

final getNotificationUseCaseProvider = Provider<GetNotificationUseCase>(
  (ref) => GetNotificationUseCase(ref.watch(notificationRepositoryProvider)),
);
