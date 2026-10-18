// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceDto _$DeviceDtoFromJson(Map<String, dynamic> json) => DeviceDto(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  platform: json['platform'] as String,
  provider: json['provider'] as String,
  token: json['token'] as String,
  deviceName: json['device_name'] as String?,
  isActive: json['is_active'] as bool,
  lastUsedAt: json['last_used_at'] == null
      ? null
      : DateTime.parse(json['last_used_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);
