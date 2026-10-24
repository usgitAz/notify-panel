import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const _deepEq = DeepCollectionEquality();

enum NotificationStatus {
  pending,
  delivered,
  failed;

  static NotificationStatus fromJson(String value) => switch (value) {
    'pending' => NotificationStatus.pending,
    'delivered' => NotificationStatus.delivered,
    'failed' => NotificationStatus.failed,
    _ => throw FormatException('Unknown notification status: $value'),
  };

  String get wire => name;
}

enum NotificationChannel {
  push,
  email;

  static NotificationChannel fromJson(String value) => switch (value) {
    'push' => NotificationChannel.push,
    'email' => NotificationChannel.email,
    _ => throw FormatException('Unknown notification channel: $value'),
  };

  String get wire => name;
}

@immutable
final class Notification {
  const Notification({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.userExternalId,
    required this.channel,
    required this.title,
    required this.body,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tenantId;
  final String userId;

  /// Recipient external ID as known by the tenant. Null when the user
  /// was deleted or data is not joined.
  final String? userExternalId;

  final NotificationChannel channel;

  /// Optional title. Email and push have it; future channels (SMS) may not.
  final String? title;

  final String body;

  /// Channel-specific data. `email` → cc/bcc/attachments; `push` → image_url
  /// /data. Content shape is not modeled — see JsonViewer on detail page.
  final Map<String, dynamic> payload;

  final NotificationStatus status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == NotificationStatus.pending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          other.id == id &&
          other.tenantId == tenantId &&
          other.userId == userId &&
          other.userExternalId == userExternalId &&
          other.channel == channel &&
          other.title == title &&
          other.body == body &&
          _deepEq.equals(other.payload, payload) &&
          other.status == status &&
          other.attempts == attempts &&
          other.lastError == lastError &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    userId,
    userExternalId,
    channel,
    title,
    body,
    _deepEq.hash(payload),
    status,
    attempts,
    lastError,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Notification(id: $id, channel: ${channel.name}, status: ${status.name})';
}
