// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      userId: json['user_id'] as String,
      userExternalId: json['user_external_id'] as String?,
      channel: json['channel'] as String,
      title: json['title'] as String?,
      body: json['body'] as String,
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      attempts: (json['attempts'] as num).toInt(),
      lastError: json['last_error'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
