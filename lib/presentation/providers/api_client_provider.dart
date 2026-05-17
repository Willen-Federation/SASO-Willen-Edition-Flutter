import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/database_helper.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/datasources/local/item_local_cache.dart';
import '../../data/datasources/mock/mock_api_client.dart';
import '../../data/datasources/remote/legacy/legacy_api_client.dart';
import '../../data/datasources/remote/saso_api_client.dart';
import '../../data/datasources/remote/v1/rest_api_client.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/repositories/item_repository.dart';
import 'auth_state_provider.dart';
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
    ApiMode.rest => _buildRestClient(ref, config),
  };
}

RestV1ApiClient _buildRestClient(Ref ref, ServerConfig config) {
  final secureStorage = ref.watch(secureStorageProvider);
  final configNotifier = ref.read(serverConfigNotifierProvider.notifier);

  return RestV1ApiClient(
    serverUrl: config.baseUrl,
    jwtToken: config.jwtToken ?? '',
    refreshTokenLoader: () => secureStorage.read(AppConstants.refreshTokenKey),
    onTokenRefreshed: ({
      required String accessToken,
      required String refreshToken,
      required int deviceId,
    }) => configNotifier.updateTokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      deviceId: deviceId,
    ),
    onRefreshFailed: () async {
      await ref.read(authStateNotifierProvider.notifier).logout();
    },
  );
}

@riverpod
Future<ItemRepository> itemRepository(Ref ref) async {
  final client = ref.watch(sasoApiClientProvider);
  final dbHelper = await ref.watch(databaseHelperProvider.future);
  return ItemRepositoryImpl(client, cache: SqliteItemLocalCache(dbHelper.db));
}
