import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/mock/mock_api_client.dart';
import '../../data/datasources/remote/legacy/legacy_api_client.dart';
import '../../data/datasources/remote/saso_api_client.dart';
import '../../data/datasources/remote/v1/rest_api_client.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/repositories/item_repository.dart';
import 'server_config_provider.dart';

part 'api_client_provider.g.dart';

@riverpod
SasoApiClient sasoApiClient(SasoApiClientRef ref) {
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
    ),
  };
}

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  final client = ref.watch(sasoApiClientProvider);
  return ItemRepositoryImpl(client);
}
