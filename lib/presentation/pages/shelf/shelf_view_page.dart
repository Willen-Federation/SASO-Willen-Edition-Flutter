import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/datasources/mock/mock_api_client.dart';
import '../../../data/datasources/remote/v1/rest_api_client.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/value_objects/shelf_id.dart';
import '../../providers/server_config_provider.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/item/item_list_tile.dart';

part 'shelf_view_page.g.dart';

@riverpod
Future<({String label, List<Item> items})> shelfData(
  Ref ref,
  String shelfId,
) async {
  final config = ref.watch(serverConfigNotifierProvider);
  final client = switch (config.apiMode) {
    ApiMode.mock => MockApiClient(),
    ApiMode.rest => RestV1ApiClient(
      serverUrl: config.baseUrl,
      jwtToken: config.jwtToken ?? '',
    ),
  };

  final shelfModel = await client.fetchShelf(shelfId);
  final itemModels = await client.fetchItemsByShelf(shelfId);
  final items = itemModels.map((m) => m.toDomain()).toList();
  return (label: shelfModel.label ?? shelfId, items: items);
}

class ShelfViewPage extends ConsumerWidget {
  const ShelfViewPage({super.key, required this.shelfId});

  final String shelfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ShelfId.tryParse(shelfId);
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('棚')),
        body: Center(child: Text('無効な棚ID: $shelfId')),
      );
    }

    final dataAsync = ref.watch(shelfDataProvider(shelfId));

    return Scaffold(
      appBar: AppBar(title: Text('棚: $shelfId')),
      body: dataAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          error: e,
          onRetry: () => ref.invalidate(shelfDataProvider(shelfId)),
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                data.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: data.items.isEmpty
                  ? const Center(child: Text('棚にアイテムがありません'))
                  : ListView.builder(
                      itemCount: data.items.length,
                      itemBuilder: (_, i) => ItemListTile(
                        item: data.items[i],
                        onTap: () =>
                            context.push('/items/${data.items[i].id.value}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
