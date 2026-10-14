import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/tenant.dart';

part 'tenant_dto.g.dart';

@JsonSerializable()
class TenantDto {
  const TenantDto({
    required this.id,
    required this.name,
    required this.apiKeyPrefix,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantDto.fromJson(Map<String, dynamic> json) =>
      _$TenantDtoFromJson(json);

  factory TenantDto.fromEntity(Tenant tenant) => TenantDto(
    id: tenant.id,
    name: tenant.name,
    apiKeyPrefix: tenant.apiKeyPrefix,
    isActive: tenant.isActive,
    createdAt: tenant.createdAt,
    updatedAt: tenant.updatedAt,
  );

  final String id;
  final String name;

  @JsonKey(name: 'api_key_prefix')
  final String apiKeyPrefix;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$TenantDtoToJson(this);

  Tenant toEntity() => Tenant(
    id: id,
    name: name,
    apiKeyPrefix: apiKeyPrefix,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
