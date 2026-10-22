import 'package:flutter/material.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/device.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({required this.device, required this.onTap, super.key});

  final Device device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _platformIcon(device.platform),
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceName?.isNotEmpty == true
                          ? device.deviceName!
                          : 'Unnamed device',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: device.deviceName?.isNotEmpty == true
                            ? null
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_platformLabel(device.platform)} · '
                      '${_providerLabel(device.provider)} · '
                      '${_tokenPreview(device.token)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(
                label: device.isActive ? 'Active' : 'Inactive',
                tone: device.isActive
                    ? StatusTone.delivered
                    : StatusTone.neutral,
                compact: true,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _platformIcon(DevicePlatform p) => switch (p) {
    DevicePlatform.ios => Icons.phone_iphone,
    DevicePlatform.android => Icons.phone_android,
    DevicePlatform.web => Icons.public,
  };

  static String _platformLabel(DevicePlatform p) => switch (p) {
    DevicePlatform.ios => 'iOS',
    DevicePlatform.android => 'Android',
    DevicePlatform.web => 'Web',
  };

  static String _providerLabel(PushProvider p) => switch (p) {
    PushProvider.fcm => 'FCM',
  };
  static String _tokenPreview(String token) {
    if (token.length <= 16) return token;
    return '${token.substring(0, 8)}…${token.substring(token.length - 4)}';
  }
}
