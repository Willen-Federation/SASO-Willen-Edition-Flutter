import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/mcp/mcp_client.dart';
import '../../data/models/mcp_item_model.dart';
import '../../data/models/storage_location_model.dart';
import 'server_config_provider.dart';

/// Provides an [McpClient] configured from [ServerConfigNotifier].
/// Returns null when not in REST mode or JWT is absent.
final mcpClientProvider = Provider<McpClient?>((ref) {
  final config = ref.watch(serverConfigNotifierProvider);
  if (config.apiMode != ApiMode.rest) return null;
  if (config.jwtToken == null || config.jwtToken!.isEmpty) return null;
  if (config.baseUrl.isEmpty) return null;
  return McpClient(serverUrl: config.baseUrl, jwtToken: config.jwtToken!);
});

// ---------------------------------------------------------------------------
// Item search via MCP
// ---------------------------------------------------------------------------

final mcpItemSearchProvider = FutureProvider.family<List<McpItemModel>, String>(
  (ref, query) async {
    final client = ref.watch(mcpClientProvider);
    if (client == null) return [];
    final result = await client.callTool('search_items', {
      'query': query,
      'limit': 50,
    });
    final items = result['items'] as List<dynamic>? ?? [];
    return items
        .cast<Map<String, dynamic>>()
        .map(McpItemModel.fromJson)
        .toList();
  },
);

// ---------------------------------------------------------------------------
// Single item via MCP
// ---------------------------------------------------------------------------

final mcpItemByIdProvider = FutureProvider.family<McpItemModel?, int>(
  (ref, id) async {
    final client = ref.watch(mcpClientProvider);
    if (client == null) return null;
    final result = await client.callTool('get_item', {'id': id});
    if (result.isEmpty) return null;
    return McpItemModel.fromJson(result);
  },
);

// ---------------------------------------------------------------------------
// Storage locations via MCP
// ---------------------------------------------------------------------------

final storageLocationsProvider =
    FutureProvider.family<List<StorageLocationModel>, int?>(
      (ref, parentId) async {
        final client = ref.watch(mcpClientProvider);
        if (client == null) return [];
        final args = <String, dynamic>{};
        if (parentId != null) args['parentId'] = parentId;
        final result = await client.callTool('list_storage_locations', args);
        final locations = result['locations'] as List<dynamic>? ?? [];
        return locations
            .cast<Map<String, dynamic>>()
            .map(StorageLocationModel.fromJson)
            .toList();
      },
    );

// ---------------------------------------------------------------------------
// Item registration via MCP
// ---------------------------------------------------------------------------

class RegisterItemParams {
  const RegisterItemParams({
    required this.name,
    required this.categoryId,
    this.janCode,
    this.price = 0,
    this.stock = 0,
  });
  final String name;
  final int categoryId;
  final String? janCode;
  final int price;
  final int stock;
}

/// Call to register a new item. Returns the created [McpItemModel].
Future<McpItemModel> registerItem(McpClient client, RegisterItemParams p) async {
  final args = <String, dynamic>{
    'name': p.name,
    'categoryId': p.categoryId,
    'stock': p.stock,
    'price': p.price,
  };
  if (p.janCode != null && p.janCode!.isNotEmpty) args['janCode'] = p.janCode;
  final result = await client.callTool('register_item', args);
  return McpItemModel.fromJson(result);
}
