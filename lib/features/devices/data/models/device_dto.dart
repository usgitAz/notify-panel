import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/device.dart';

part 'device_dto.g.dart';

@JsonSerializable(createToJson: false)
class DeviceDto {
  const DeviceDto({
    required this.id,
    required this.userId,
    required this.platform,
    required this.provider,
    required this.token,
    required this.deviceName,
    required this.isActive,
    required this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceDtoFromJson(json);

  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  final String platform;
  final String provider;
  final String token;

  @JsonKey(name: 'device_name')
  final String? deviceName;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'last_used_at')
  final DateTime? lastUsedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Device toEntity() => Device(
    id: id,
    userId: userId,
    platform: DevicePlatform.fromJson(platform),
    provider: PushProvider.fromJson(provider),
    token: token,
    deviceName: deviceName,
    isActive: isActive,
    lastUsedAt: lastUsedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
