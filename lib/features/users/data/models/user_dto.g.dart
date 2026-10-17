// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['id'] as String,
  tenantId: json['tenant_id'] as String,
  externalId: json['external_id'] as String,
  email: json['email'] as String?,
  isActive: json['is_active'] as bool,
  deactivatedAt: json['deactivated_at'] == null
      ? null
      : DateTime.parse(json['deactivated_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);
