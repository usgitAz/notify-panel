import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/notification.dart';

part 'notification_dto.g.dart';

@JsonSerializable(createToJson: false)
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.userExternalId,
    required this.channel,
    required this.title,
    required this.body,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  final String id;

  @JsonKey(name: 'tenant_id')
  final String tenantId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'user_external_id')
  final String? userExternalId;

  final String channel;
  final String? title;
  final String body;

  /// Channel-specific data. Defaults to an empty map when the field
  /// is absent — see the OpenAPI schema; `payload` is not required.
  @JsonKey(defaultValue: <String, dynamic>{})
  final Map<String, dynamic> payload;

  final String status;
  final int attempts;

  @JsonKey(name: 'last_error')
  final String? lastError;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Notification toEntity() => Notification(
    id: id,
    tenantId: tenantId,
    userId: userId,
    userExternalId: userExternalId,
    channel: NotificationChannel.fromJson(channel),
    title: title,
    body: body,
    payload: payload,
    status: NotificationStatus.fromJson(status),
    attempts: attempts,
    lastError: lastError,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
