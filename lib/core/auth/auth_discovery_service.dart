import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'auth_provider_config.dart';

/// Discovers the auth providers the server has enabled.
///
/// Calls `GET {serverUrl}/api/v1/auth/providers` (public, no auth required)
/// and returns a [ServerAuthDiscovery] describing every enabled login
/// mechanism. Falls back to [ServerAuthDiscovery.localOnly] on any error or
/// non-200 status so the user can still attempt a username/password login.
/// The fallback path is intentionally non-fatal so the UI keeps rendering,
/// but each branch emits a `[AuthDiscovery]` debugPrint with the reason so
/// the cause can still be inspected via `flutter logs`.
class AuthDiscoveryService {
  AuthDiscoveryService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<ServerAuthDiscovery> discover(String serverUrl) async {
    if (serverUrl.isEmpty) return ServerAuthDiscovery.localOnly;

    final uri = Uri.tryParse('$serverUrl/api/v1/auth/providers');
    if (uri == null || !uri.hasScheme) {
      debugPrint('[AuthDiscovery] invalid serverUrl: $serverUrl');
      return ServerAuthDiscovery.localOnly;
    }

    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConstants.httpTimeout);
    } catch (e) {
      debugPrint('[AuthDiscovery] GET $uri failed: $e');
      return ServerAuthDiscovery.localOnly;
    }

    if (response.statusCode != 200) {
      debugPrint(
        '[AuthDiscovery] GET $uri returned HTTP ${response.statusCode}: '
        '${_snippet(response.body)}',
      );
      return ServerAuthDiscovery.localOnly;
    }

    try {
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
    } catch (e) {
      debugPrint(
        '[AuthDiscovery] could not parse response from $uri: $e. '
        'Body: ${_snippet(response.body)}',
      );
      return ServerAuthDiscovery.localOnly;
    }
  }

  static String _snippet(String body) {
    final flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.isEmpty) return '(empty body)';
    if (flat.length <= 200) return flat;
    return '${flat.substring(0, 200)}…';
  }
}
