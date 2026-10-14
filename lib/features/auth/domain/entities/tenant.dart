import 'package:meta/meta.dart';

@immutable
final class Tenant {
  const Tenant({
    required this.id,
    required this.name,
    required this.apiKeyPrefix,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String apiKeyPrefix;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Environment segment from `api_key_prefix`
  /// (`sk_<env>_<random>` → `<env>`). Null if the format is unexpected.
  String? get environment {
    final parts = apiKeyPrefix.split('_');
    if (parts.length >= 3 && parts.first == 'sk') return parts[1];
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tenant &&
          other.id == id &&
          other.name == name &&
          other.apiKeyPrefix == apiKeyPrefix &&
          other.isActive == isActive &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(id, name, apiKeyPrefix, isActive, createdAt, updatedAt);

  @override
  String toString() => 'Tenant(id: $id, name: $name)';
}
