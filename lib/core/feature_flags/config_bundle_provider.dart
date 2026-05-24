import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/v1/rest_api_client.dart';
import '../../presentation/providers/server_config_provider.dart';
import '../logging/app_logger.dart';
import 'feature_flag_service.dart';

/// Fetches the server's offline config bundle (GET /api/v1/mobile/config)
/// and applies it to [FeatureFlagService] when REST mode is active.
///
/// Triggered automatically whenever [serverConfigNotifierProvider] changes
/// (e.g., after QR pairing sets a new access token). Silently skips in mock
/// and legacy modes, or if no access token is present.
final configBundleSyncProvider = FutureProvider<void>((ref) async {
  final config = ref.watch(serverConfigNotifierProvider);

  if (config.apiMode != ApiMode.rest) return;
  if (config.jwtToken == null || config.jwtToken!.isEmpty) return;
  if (config.baseUrl.isEmpty) return;

  final client = RestV1ApiClient(
    serverUrl: config.baseUrl,
    jwtToken: config.jwtToken!,
  );

  try {
    final bundle = await client.fetchConfigBundle();
    FeatureFlagService.instance.applyServerConfigBundle(bundle);
  } catch (e) {
    AppLogger.warn('ConfigBundle', 'Fetch failed, keeping existing flags', e);
  }
});
