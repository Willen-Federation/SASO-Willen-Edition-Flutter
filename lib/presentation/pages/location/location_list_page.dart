import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/storage_location_model.dart';
import '../../providers/mcp_provider.dart';

/// Browse warehouse storage locations in a hierarchical list.
/// Tapping a location drills down into its children.
/// Tapping a shelf-like location navigates to the shelf view page.
class LocationListPage extends ConsumerWidget {
  const LocationListPage({super.key, this.parentId, this.parentName});

  final int? parentId;
  final String? parentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(storageLocationsProvider(parentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(parentName ?? '場所一覧'),
      ),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          error: e,
          onRetry: () => ref.invalidate(storageLocationsProvider(parentId)),
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return const _EmptyView();
          }
          return _LocationListView(locations: locations);
        },
      ),
    );
  }
}

class _LocationListView extends StatelessWidget {
  const _LocationListView({required this.locations});
  final List<StorageLocationModel> locations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: locations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final loc = locations[i];
        return _LocationTile(location: loc);
      },
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location});
  final StorageLocationModel location;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          location.code.substring(0, location.code.length.clamp(0, 2)),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(location.name),
      subtitle: Text(location.code),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Open as shelf view
          IconButton(
            icon: const Icon(Icons.shelves),
            tooltip: '棚として開く',
            onPressed: () => context.push('/shelves/${location.code}'),
          ),
          // Drill down
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => context.push(
        '/locations',
        extra: {'parentId': location.id, 'parentName': location.name},
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          '場所が登録されていません',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        const Text('サーバーでストレージロケーションを作成してください'),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 8),
        Text('取得失敗: $error'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('再試行'),
        ),
      ],
    ),
  );
}
