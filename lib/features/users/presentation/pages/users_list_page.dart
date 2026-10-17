import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/user.dart';
import '../providers/users_list_provider.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(usersListProvider);
    final notifier = ref.read(usersListProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onSearchChanged: (q) => setState(() => _searchQuery = q),
            searchController: _searchController,
            onCreate: () => context.go(AppRoutes.userCreatePath()),
            onRefresh: notifier.refresh,
          ),
          const SizedBox(height: 16),
          _Toolbar(
            filter: asyncState.value?.filter ?? ActiveFilter.all,
            limit: asyncState.value?.limit ?? 20,
            onFilterChanged: notifier.applyFilter,
            onLimitChanged: notifier.setLimit,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AsyncValueWidget<UsersListState>(
              value: asyncState,
              onRetry: notifier.refresh,
              data: (state) {
                final filtered = _searchQuery.isEmpty
                    ? state.users
                    : state.users
                          .where(
                            (u) => u.externalId.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: _searchQuery.isEmpty
                        ? 'No users yet'
                        : 'No matching users',
                    message: _searchQuery.isEmpty
                        ? 'Create your first user to get started.'
                        : 'Try a different search term.',
                    actionLabel: _searchQuery.isEmpty ? 'Create user' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.go(AppRoutes.userCreatePath())
                        : null,
                  );
                }

                return _UsersTable(users: filtered);
              },
            ),
          ),
          const SizedBox(height: 16),
          _Pagination(
            hasNext: asyncState.value?.hasNext ?? false,
            hasPrev: asyncState.value?.hasPrev ?? false,
            total: asyncState.value?.total ?? 0,
            firstIndex: asyncState.value?.page?.firstIndex ?? 0,
            lastIndex: asyncState.value?.page?.lastIndex ?? 0,
            onNext: notifier.goToNextPage,
            onPrev: notifier.goToPrevPage,
            loading: asyncState.isLoading,
          ),
        ],
      ),
    );
  }
}

// ─── Header (title + search + create) ───

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreate,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreate;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Users', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Manage end-users of your tenant.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 280,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search external ID',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
        const SizedBox(width: 8),
        AppButton(label: 'New user', icon: Icons.add, onPressed: onCreate),
      ],
    );
  }
}

// ─── Toolbar (filter + page size) ───

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.filter,
    required this.limit,
    required this.onFilterChanged,
    required this.onLimitChanged,
  });

  final ActiveFilter filter;
  final int limit;
  final ValueChanged<ActiveFilter> onFilterChanged;
  final ValueChanged<int> onLimitChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterChips(selected: filter, onChanged: onFilterChanged),
        _PageSizeDropdown(limit: limit, onChanged: onLimitChanged),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final ActiveFilter selected;
  final ValueChanged<ActiveFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ActiveFilter>(
      segments: const [
        ButtonSegment(value: ActiveFilter.all, label: Text('All')),
        ButtonSegment(value: ActiveFilter.active, label: Text('Active')),
        ButtonSegment(value: ActiveFilter.inactive, label: Text('Inactive')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

class _PageSizeDropdown extends StatelessWidget {
  const _PageSizeDropdown({required this.limit, required this.onChanged});

  final int limit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Rows per page:', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: limit,
          underline: const SizedBox.shrink(),
          onChanged: (v) => v == null ? null : onChanged(v),
          items: const [
            DropdownMenuItem(value: 10, child: Text('10')),
            DropdownMenuItem(value: 20, child: Text('20')),
            DropdownMenuItem(value: 50, child: Text('50')),
            DropdownMenuItem(value: 100, child: Text('100')),
          ],
        ),
      ],
    );
  }
}

// ─── Table ───

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: const [
                _CellHeader('External ID', flex: 3),
                _CellHeader('Email', flex: 4),
                _CellHeader('Status', flex: 2),
                _CellHeader('Created', flex: 3),
                SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              itemBuilder: (_, i) => _UserRow(user: users[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CellHeader extends StatelessWidget {
  const _CellHeader(this.label, {required this.flex});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoutes.userDetailPath(user.externalId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  user.externalId,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  user.email ?? '—',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: user.email == null
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    label: user.isActive ? 'Active' : 'Inactive',
                    tone: user.isActive
                        ? StatusTone.delivered
                        : StatusTone.neutral,
                    compact: true,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  _formatDate(user.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(
                width: 40,
                child: Icon(Icons.chevron_right, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${_pad(local.month)}-${_pad(local.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

// ─── Pagination ───

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.hasNext,
    required this.hasPrev,
    required this.total,
    required this.firstIndex,
    required this.lastIndex,
    required this.onNext,
    required this.onPrev,
    required this.loading,
  });

  final bool hasNext;
  final bool hasPrev;
  final int total;
  final int firstIndex;
  final int lastIndex;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          total == 0
              ? 'No results'
              : 'Showing $firstIndex–$lastIndex of $total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: hasPrev && !loading ? onPrev : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Previous'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: hasNext && !loading ? onNext : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: const Text('Next'),
        ),
      ],
    );
  }
}
