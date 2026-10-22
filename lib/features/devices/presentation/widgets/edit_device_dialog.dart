import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/device.dart';

/// Result of editing a device. `null` from [show] means the user
/// cancelled.
typedef DeviceChanges = ({String? name, bool isActive});

abstract final class EditDeviceDialog {
  static Future<DeviceChanges?> show({
    required BuildContext context,
    required Device device,
  }) {
    return showDialog<DeviceChanges>(
      context: context,
      builder: (_) => _EditDeviceDialog(device: device),
    );
  }
}

class _EditDeviceDialog extends StatefulWidget {
  const _EditDeviceDialog({required this.device});

  final Device device;

  @override
  State<_EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<_EditDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.device.deviceName ?? '',
    );
    _isActive = widget.device.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final raw = _nameController.text.trim();
    Navigator.of(context)
        .pop((name: raw.isEmpty ? null : raw, isActive: _isActive));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit device'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Device name',
                hint: 'e.g. iPhone 15 Pro',
                maxLength: 100,
                autofocus: true,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text(
                  'Inactive devices will not receive notifications.',
                ),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(label: 'Save', onPressed: _save),
      ],
    );
  }
}
