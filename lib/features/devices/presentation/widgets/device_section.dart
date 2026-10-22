import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/usecases/update_device_usecase.dart';
import '../providers/device_providers.dart';
import 'device_card.dart';
import 'edit_device_dialog.dart';

/// Panel showing a user's devices with filter and pagination.
///
/// Lives inside UserDetailPage but manages its own state through
/// [deviceListProvider].
class DeviceSection extends ConsumerWidget {
  const DeviceSection({required this.userExternalId, super.key});

  final String userExternalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deviceListProvider(userExternalId));
    final notifier = ref.read(deviceListProvider(userExternalId).notifier);
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header row: title + register button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Text('Devices', style: theme.textTheme.titleMedium),
                const Spacer(),
                AppButton(
                  label: 'Register device',
                  icon: Icons.add,
                  onPressed: () =>
                      context.go(AppRoutes.deviceRegisterPath(userExternalId)),
                ),
              ],
            ),
          ),

          // ── Toolbar row: filter + pagination ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
            child: async.maybeWhen(
              data: (state) => _Toolbar(
                state: state,
                onFilter: notifier.setFilter,
                onPrev: () => _goToPage(ref, notifier, forward: false),
                onNext: () => _goToPage(ref, notifier, forward: true),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          Divider(height: 1, color: theme.colorScheme.outlineVariant),

          // ── Body ──
          async.when(
            data: (state) {
              if (state.devices.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    icon: Icons.devices_other_outlined,
                    title: state.filter == DeviceActiveFilter.all
                        ? 'No devices yet'
                        : 'No devices match this filter',
                    message: state.filter == DeviceActiveFilter.all
                        ? 'Register a device to enable push or email delivery.'
                        : null,
                    actionLabel: state.filter == DeviceActiveFilter.all
                        ? 'Register device'
                        : null,
                    onAction: state.filter == DeviceActiveFilter.all
                        ? () => context.go(
                            AppRoutes.deviceRegisterPath(userExternalId),
                          )
                        : null,
                  ),
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < state.devices.length; i++) ...[
                    DeviceCard(
                      device: state.devices[i],
                      onTap: () => _editDevice(context, ref, state.devices[i]),
                    ),
                    if (i < state.devices.length - 1)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Text(
                'Failed to load devices.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editDevice(
    BuildContext context,
    WidgetRef ref,
    Device device,
  ) async {
    final changes = await EditDeviceDialog.show(
      context: context,
      device: device,
    );
    if (changes == null) return;

    final result = await ref
        .read(updateDeviceUseCaseProvider)
        .call(
          UpdateDeviceParams(
            deviceId: device.id,
            deviceName: changes.name,
            isActive: changes.isActive,
          ),
        );

    if (!context.mounted) return;

    result.match(
      (failure) => AppSnackbar.error(context, FailureMessages.of(failure)),
      (updated) {
        ref.read(deviceListProvider(userExternalId).notifier).upsert(updated);
        AppSnackbar.success(context, 'Device updated.');
      },
    );
  }

  Future<void> _goToPage(
    WidgetRef ref,
    DeviceListNotifier notifier, {
    required bool forward,
  }) async {
    // Placeholder for pagination actions; wired below.
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.state,
    required this.onFilter,
    required this.onPrev,
    required this.onNext,
  });

  final DeviceListState state;
  final ValueChanged<DeviceActiveFilter> onFilter;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        SegmentedButton<DeviceActiveFilter>(
          segments: const [
            ButtonSegment(value: DeviceActiveFilter.all, label: Text('All')),
            ButtonSegment(
              value: DeviceActiveFilter.active,
              label: Text('Active'),
            ),
            ButtonSegment(
              value: DeviceActiveFilter.inactive,
              label: Text('Inactive'),
            ),
          ],
          selected: {state.filter},
          onSelectionChanged: (s) => onFilter(s.first),
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        Text(
          state.total == 0
              ? 'No results'
              : 'Showing ${state.page?.firstIndex ?? 0}'
                    '–${state.page?.lastIndex ?? 0} of ${state.total}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          tooltip: 'Previous page',
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: state.hasPrev ? onPrev : null,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          tooltip: 'Next page',
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: state.hasNext ? onNext : null,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
