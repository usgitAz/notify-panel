import 'dart:convert';

import 'package:flutter/material.dart';

/// Collapsible JSON viewer with pretty-printed, selectable content.
///
/// Used for the notification payload where the shape varies by channel
/// and cannot be modeled as a typed schema.
class JsonViewer extends StatefulWidget {
  const JsonViewer({
    required this.data,
    this.label = 'Payload',
    this.initiallyExpanded = false,
    super.key,
  });

  final Map<String, dynamic> data;
  final String label;
  final bool initiallyExpanded;

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pretty = const JsonEncoder.withIndent('  ').convert(widget.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(widget.label, style: theme.textTheme.titleSmall),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            constraints: const BoxConstraints(maxHeight: 360),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                pretty,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
