import 'package:meta/meta.dart';

@immutable
final class User {
  const User({
    required this.id,
    required this.tenantId,
    required this.externalId,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String externalId;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          other.id == id &&
          other.tenantId == tenantId &&
          other.externalId == externalId &&
          other.email == email &&
          other.isActive == isActive &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    externalId,
    email,
    isActive,
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'User(externalId: $externalId, isActive: $isActive)';
}
