import 'dart:convert';
import 'dart:math';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Result of a successful mobile-setup web auth round-trip.
class PairingWebAuthResult {
  const PairingWebAuthResult({
    required this.token,
    required this.serverUrl,
  });
  final String token;
  final String serverUrl;
}

class PairingWebAuthFailure implements Exception {
  const PairingWebAuthFailure(this.message);
  final String message;
  @override
  String toString() => 'PairingWebAuthFailure: $message';
}

/// Drives the in-app browser for the `/m/setup → /auth/start → IdP →
/// /auth/callback → /m/issue-pairing → jp.willen.saso://callback#…` flow.
///
/// On iOS this uses ASWebAuthenticationSession (no cookie sharing with
/// Safari, automatic dismissal on callback). On Android Chrome Custom Tabs.
/// On web, a popup window. The custom URL scheme `jp.willen.saso` must be
/// registered in `ios/Runner/Info.plist` (CFBundleURLTypes) and
/// `android/app/src/main/AndroidManifest.xml` (intent-filter on the
/// `flutter_web_auth_2` CallbackActivity).
class PairingWebAuthService {
  static const String callbackScheme = 'jp.willen.saso';
  static const String redirectUri = 'jp.willen.saso://callback';

  /// Starts the flow by opening [setupUrl] (typically
  /// `<base>/m/setup`). Returns the pairing token + server URL parsed
  /// from the callback fragment.
  Future<PairingWebAuthResult> requestPairing(Uri setupUrl) async {
    final state = generateState();
    final url = setupUrl.replace(
      queryParameters: {
        ...setupUrl.queryParameters,
        'redirect_uri': redirectUri,
        'state': state,
      },
    );

    final raw = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: callbackScheme,
    );

    return _parseCallback(raw, expectedState: state);
  }

  /// Generates a 32-byte URL-safe CSRF state. Public so tests can stub it.
  static String generateState() {
    final r = Random.secure();
    final bytes = List<int>.generate(32, (_) => r.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  PairingWebAuthResult _parseCallback(
    String raw, {
    required String expectedState,
  }) {
    final uri = Uri.parse(raw);
    final fragment = uri.fragment;
    if (fragment.isEmpty) {
      throw const PairingWebAuthFailure('コールバックにトークンがありません');
    }
    final params = Uri.splitQueryString(fragment);
    final token = params['token'];
    final state = params['state'];
    final server = params['server'];

    if (token == null || token.isEmpty) {
      throw const PairingWebAuthFailure('コールバックに token がありません');
    }
    if (state != expectedState) {
      throw const PairingWebAuthFailure('state が一致しません(CSRF 防御)');
    }
    if (server == null || server.isEmpty) {
      throw const PairingWebAuthFailure('コールバックに server URL がありません');
    }
    return PairingWebAuthResult(token: token, serverUrl: server);
  }
}
