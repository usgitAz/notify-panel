import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

abstract final class EditUserEmailDialog {
  static Future<String?> show({
    required BuildContext context,
    required String? initialEmail,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => _EditEmailDialog(initialEmail: initialEmail),
    );
  }
}

class _EditEmailDialog extends StatefulWidget {
  const _EditEmailDialog({required this.initialEmail});

  final String? initialEmail;

  @override
  State<_EditEmailDialog> createState() => _EditEmailDialogState();
}

class _EditEmailDialogState extends State<_EditEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit email'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: AppTextField(
            controller: _controller,
            label: 'Email',
            hint: 'user@example.com',
            helperText: 'Leave empty to remove the email.',
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            onSubmitted: (_) => _save(),
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
