import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/mock/mock_api_client.dart';
import '../../data/datasources/remote/legacy/legacy_api_client.dart';
import '../../data/datasources/remote/v1/rest_api_client.dart';
import '../../domain/entities/category.dart';
import 'server_config_provider.dart';

part 'category_provider.g.dart';

@riverpod
Future<List<Category>> categories(Ref ref) async {
  final config = ref.watch(serverConfigNotifierProvider);

  final client = switch (config.apiMode) {
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

  final models = await client.fetchCategories();
  return models.map((m) => m.toDomain()).toList();
}
