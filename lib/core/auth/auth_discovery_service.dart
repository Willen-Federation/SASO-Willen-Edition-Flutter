import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'auth_provider_config.dart';

/// Discovers the auth providers the server has enabled.
///
/// Calls `GET {serverUrl}/api/v1/auth/providers` (public, no auth required)
/// and returns a [ServerAuthDiscovery] describing every enabled login
/// mechanism. Falls back to [ServerAuthDiscovery.localOnly] on any error or
/// non-200 status so the user can still attempt a username/password login.
class AuthDiscoveryService {
  AuthDiscoveryService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<ServerAuthDiscovery> discover(String serverUrl) async {
    if (serverUrl.isEmpty) return ServerAuthDiscovery.localOnly;

    final uri = Uri.tryParse('$serverUrl/api/v1/auth/providers');
    if (uri == null || !uri.hasScheme) return ServerAuthDiscovery.localOnly;

    try {
      final response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final discovery = ServerAuthDiscovery.fromJson(json);
        // Server may legitimately return an empty providers list — surface
        // a local-only fallback so the credential form still renders.
        if (discovery.providers.isEmpty) {
          return discovery.copyWith(
            providers: ServerAuthDiscovery.localOnly.providers,
            authStrategy: AuthStrategy.localOnly,
          );
        }
        return discovery;
      }
      return ServerAuthDiscovery.localOnly;
    } catch (_) {
      return ServerAuthDiscovery.localOnly;
    }
  }
}
