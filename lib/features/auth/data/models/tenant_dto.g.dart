// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenantDto _$TenantDtoFromJson(Map<String, dynamic> json) => TenantDto(
  id: json['id'] as String,
  name: json['name'] as String,
  apiKeyPrefix: json['api_key_prefix'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TenantDtoToJson(TenantDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'api_key_prefix': instance.apiKeyPrefix,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
