import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/page.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_scope_provider.dart';
import '../../data/datasources/device_remote_datasource.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/usecases/list_devices_usecase.dart';
import '../../domain/usecases/register_device_usecase.dart';
import '../../domain/usecases/update_device_usecase.dart';

final deviceListProvider =
    AsyncNotifierProvider.family<DeviceListNotifier, DeviceListState, String>(
      DeviceListNotifier.new,
    );

// ─── Data sources ───

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>(
  (ref) => DeviceRemoteDataSource(ref.watch(dioProvider)),
);

// ─── Repository ───

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) =>
      DeviceRepositoryImpl(remote: ref.watch(deviceRemoteDataSourceProvider)),
);

// ─── Use cases ───

final listDevicesUseCaseProvider = Provider<ListDevicesUseCase>(
  (ref) => ListDevicesUseCase(ref.watch(deviceRepositoryProvider)),
);

final registerDeviceUseCaseProvider = Provider<RegisterDeviceUseCase>(
  (ref) => RegisterDeviceUseCase(ref.watch(deviceRepositoryProvider)),
);

// ─── List state for a user's devices ───

final updateDeviceUseCaseProvider = Provider<UpdateDeviceUseCase>(
  (ref) => UpdateDeviceUseCase(ref.watch(deviceRepositoryProvider)),
);

/// Filter for active/inactive devices within a user.
enum DeviceActiveFilter { all, active, inactive }

class DeviceListNotifier extends AsyncNotifier<DeviceListState> {
  final String externalId;

  DeviceListNotifier(this.externalId);

  @override
  Future<DeviceListState> build() async {
    final scope = ref.watch(tenantScopeProvider);
    if (scope == null) {
      return const DeviceListState(
        devices: [],
        page: null,
        filter: DeviceActiveFilter.all,
        isLoadingMore: false,
      );
    }
    return _fetch(filter: DeviceActiveFilter.all, offset: 0);
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(filter: current.filter, offset: 0),
    );
  }

  Future<void> setFilter(DeviceActiveFilter filter) async {
    if (state.value == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(filter: filter, offset: 0));
  }

  /// Insert or replace a device in the current list.
  /// Used after registration to keep state fresh without refetching.
  void upsert(Device device) {
    final current = state.value;
    if (current == null) return;
    final idx = current.devices.indexWhere((d) => d.id == device.id);
    final next = [...current.devices];
    if (idx == -1) {
      next.insert(0, device);
    } else {
      next[idx] = device;
    }
    state = AsyncValue.data(current.copyWith(devices: next));
  }

  Future<DeviceListState> _fetch({
    required DeviceActiveFilter filter,
    required int offset,
  }) async {
    const limit = 20;
    final result = await ref
        .read(listDevicesUseCaseProvider)
        .call(
          ListDevicesParams(
            externalId: externalId,
            isActive: switch (filter) {
              DeviceActiveFilter.all => null,
              DeviceActiveFilter.active => true,
              DeviceActiveFilter.inactive => false,
            },
            limit: limit,
            offset: offset,
          ),
        );

    return result.match(
      (failure) => throw failure,
      (page) => DeviceListState(
        devices: page.items,
        page: page,
        filter: filter,
        isLoadingMore: false,
      ),
    );
  }
}

class DeviceListState {
  final List<Device> devices;

  final Page<Device>? page;
  final DeviceActiveFilter filter;
  final bool isLoadingMore;
  const DeviceListState({
    required this.devices,
    required this.page,
    required this.filter,
    required this.isLoadingMore,
  });

  bool get hasNext => page?.hasNext ?? false;
  bool get hasPrev => page?.hasPrev ?? false;
  int get total => page?.total ?? 0;

  DeviceListState copyWith({
    List<Device>? devices,
    Page<Device>? page,
    DeviceActiveFilter? filter,
    bool? isLoadingMore,
  }) => DeviceListState(
    devices: devices ?? this.devices,
    page: page ?? this.page,
    filter: filter ?? this.filter,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}
