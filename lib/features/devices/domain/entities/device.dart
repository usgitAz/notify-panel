import 'package:meta/meta.dart';

enum DevicePlatform {
  ios,
  android,
  web;

  static DevicePlatform fromJson(String value) => switch (value) {
    'ios' => DevicePlatform.ios,
    'android' => DevicePlatform.android,
    'web' => DevicePlatform.web,
    _ => throw FormatException('Unknown platform: $value'),
  };

  String get wire => name;
}

/// Push provider for device delivery.
enum PushProvider {
  fcm;

  static PushProvider fromJson(String value) => switch (value) {
    'fcm' => PushProvider.fcm,
    _ => throw FormatException('Unknown provider: $value'),
  };

  String get wire => name;
}

@immutable
final class Device {
  const Device({
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

  final String id;
  final String userId;
  final DevicePlatform platform;
  final PushProvider provider;
  final String token;
  final String? deviceName;
  final bool isActive;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          other.id == id &&
          other.userId == userId &&
          other.platform == platform &&
          other.provider == provider &&
          other.token == token &&
          other.deviceName == deviceName &&
          other.isActive == isActive &&
          other.lastUsedAt == lastUsedAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    platform,
    provider,
    token,
    deviceName,
    isActive,
    lastUsedAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Device(id: $id, platform: ${platform.name}, provider: ${provider.name}, active: $isActive)';
}
