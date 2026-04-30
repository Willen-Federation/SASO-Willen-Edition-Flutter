import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'auth_provider_config.dart';

/// Discovers the auth provider config from the server's public endpoint.
///
/// Calls GET {serverUrl}/api/v1/auth/providers (no auth required).
/// Falls back to [AuthProviderConfig.legacy] on any error or non-200 status.
class AuthDiscoveryService {
  AuthDiscoveryService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<AuthProviderConfig> discover(String serverUrl) async {
    if (serverUrl.isEmpty) return const AuthProviderConfig.legacy();

    final uri = Uri.tryParse('$serverUrl/api/v1/auth/providers');
    if (uri == null || !uri.hasScheme) return const AuthProviderConfig.legacy();

    try {
      final response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthProviderConfig.fromJson(json);
      }
      // 404 or any non-200 → legacy
      return const AuthProviderConfig.legacy();
    } catch (_) {
      return const AuthProviderConfig.legacy();
    }
  }
}
