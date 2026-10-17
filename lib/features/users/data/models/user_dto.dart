import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

@JsonSerializable(createToJson: false)
class UserDto {
  const UserDto({
    required this.id,
    required this.tenantId,
    required this.externalId,
    required this.email,
    required this.isActive,
    required this.deactivatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String id;

  @JsonKey(name: 'tenant_id')
  final String tenantId;

  @JsonKey(name: 'external_id')
  final String externalId;

  final String? email;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'deactivated_at')
  final DateTime? deactivatedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  User toEntity() => User(
    id: id,
    tenantId: tenantId,
    externalId: externalId,
    email: email,
    isActive: isActive,
    deactivatedAt: deactivatedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
