import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/storage/database_helper.dart';
import '../../data/datasources/local/item_local_cache.dart';
import '../../data/datasources/mock/mock_api_client.dart';
import '../../data/datasources/remote/legacy/legacy_api_client.dart';
import '../../data/datasources/remote/saso_api_client.dart';
import '../../data/datasources/remote/v1/rest_api_client.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/repositories/item_repository.dart';
import 'server_config_provider.dart';

part 'api_client_provider.g.dart';

@riverpod
SasoApiClient sasoApiClient(Ref ref) {
  final config = ref.watch(serverConfigNotifierProvider);
  return switch (config.apiMode) {
    ApiMode.mock => MockApiClient(),
    ApiMode.legacy => LegacyApiClient(
      serverUrl: config.baseUrl,
      sessionCookie: config.sessionCookie,
    ),
    ApiMode.rest => RestV1ApiClient(
      serverUrl: config.baseUrl,
      jwtToken: config.jwtToken ?? '',
      refreshToken: config.refreshToken,
      onTokenRefreshed: ({required accessToken, required refreshToken}) {
        final deviceId = config.deviceId;
        if (deviceId == null) return;
        // Persist the rotated pair so the next client rebuild sees them.
        ref
            .read(serverConfigNotifierProvider.notifier)
            .updateTokenPair(
              accessToken: accessToken,
              refreshToken: refreshToken,
              deviceId: deviceId,
            );
      },
    ),
  };
}

@riverpod
Future<ItemRepository> itemRepository(Ref ref) async {
  final client = ref.watch(sasoApiClientProvider);
  final dbHelper = await ref.watch(databaseHelperProvider.future);
  return ItemRepositoryImpl(client, cache: SqliteItemLocalCache(dbHelper.db));
}
