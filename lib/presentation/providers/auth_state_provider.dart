import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/providers/legacy_auth_service.dart';
import '../../core/auth/providers/oidc_auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import 'server_config_provider.dart';

part 'auth_state_provider.g.dart';

// ---------------------------------------------------------------------------
// Detected server discovery
// ---------------------------------------------------------------------------

/// Holds the latest [ServerAuthDiscovery] document received from the server.
///
/// The splash page populates this after calling [AuthDiscoveryService]; the
/// login page reads from it to decide which sections to render (credential
/// form / per-provider buttons / QR + manual token).
@riverpod
class ServerAuthDiscoveryNotifier extends _$ServerAuthDiscoveryNotifier {
  @override
  ServerAuthDiscovery build() => ServerAuthDiscovery.localOnly;

  void set(ServerAuthDiscovery discovery) => state = discovery;
}

// ---------------------------------------------------------------------------
// Local auth service (username/password) — always available
// ---------------------------------------------------------------------------

/// Returns the local credential-based auth service that talks to the
/// server's `/auth/start` endpoint with `{id, password}`.
///
/// External providers (OIDC / SAML / Auth0 / Cognito / Firebase) are reached
/// through the server's `/m/setup` browser flow rather than a per-provider
/// native SDK, so this provider does not depend on discovery.
@riverpod
AuthService authService(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return LegacyAuthService(secureStorage);
}

// ---------------------------------------------------------------------------
// Auth state notifier
// ---------------------------------------------------------------------------

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();

  /// Tries to restore credentials from secure storage on app start.
  ///
  /// Issue #31 — OIDC fast path is checked first: when an OIDC refresh
  /// token is persisted, we route through `OidcAuthService.restoreSession()`
  /// so the fail-closed expiry check runs (and a silent refresh fires
  /// when the access token is dead but the refresh token is alive).
  /// Falls back to the legacy raw-jwt path for non-OIDC providers.
  Future<void> loadStoredCredentials() async {
    state = const AuthState.loading();
    try {
      final secureStorage = ref.read(secureStorageProvider);

      final oidcRefresh = await secureStorage.read(
        AppConstants.oidcRefreshTokenKey,
      );
      if (oidcRefresh != null) {
        final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;
        final oidc = OidcAuthService(serverUrl, secureStorage);
        final restored = await oidc.restoreSession();
        if (restored) {
          state = AuthState.authenticated(
            userId: oidc.currentUserId ?? 'oidc',
            token: oidc.currentToken,
          );
          return;
        }
        // restoreSession() returned false → session was unrecoverable
        // (expired access token + dead refresh token). Fall through to
        // the legacy path; in practice this will land on
        // unauthenticated because restoreSession() cleared the keys.
      }

      final token = await secureStorage.read(AppConstants.jwtTokenKey);
      if (token != null && token.isNotEmpty) {
        state = AuthState.authenticated(userId: 'restored', token: token);
        return;
      }

      // Legacy session-cookie path: cookie is already restored into
      // ServerConfig by ServerConfigNotifier.load(); just reflect the
      // authenticated state so the router skips the login screen.
      final cookie = await secureStorage.read(AppConstants.sessionCookieKey);
      if (cookie != null && cookie.isNotEmpty) {
        state = const AuthState.authenticated(userId: 'restored');
        return;
      }
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  /// Credential-based login against the server's `/auth/start` endpoint.
  Future<AuthResult> loginWithCredentials({
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading();
    final service = ref.read(authServiceProvider);
    final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;

    final result = await service.login(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );

    _applyResult(result, service);
    return result;
  }

  /// Exchanges a QR / setup-flow pairing token for access+refresh tokens
  /// via `POST /api/v1/mobile/connect`.
  Future<AuthResult> loginWithQrToken({
    required String pairingToken,
    required String serverUrl,
  }) async {
    state = const AuthState.loading();
    try {
      final uri = Uri.parse('$serverUrl/api/v1/mobile/connect');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'token': pairingToken,
              'deviceName': _deviceName(),
            }),
          )
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = json['access_token'] as String;
        final refreshToken = json['refresh_token'] as String;
        final deviceIdRaw = json['device_id'];
        final deviceId =
            deviceIdRaw is int
                ? deviceIdRaw
                : int.parse(deviceIdRaw.toString());

        await ref
            .read(serverConfigNotifierProvider.notifier)
            .updateTokenPair(
              accessToken: accessToken,
              refreshToken: refreshToken,
              deviceId: deviceId,
            );

        state = AuthState.authenticated(
          userId: 'qr-device',
          token: accessToken,
        );
        return AuthResult.success(userId: 'qr-device', token: accessToken);
      }
      state = const AuthState.unauthenticated();
      return AuthResult.failure(
        message: 'ペアリング失敗 (HTTP ${response.statusCode})',
      );
    } catch (e) {
      state = const AuthState.unauthenticated();
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authServiceProvider).logout();
      await ref.read(serverConfigNotifierProvider.notifier).clearTokens();
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  void _applyResult(AuthResult result, AuthService service) {
    result.when(
      success: (userId, token, sessionCookie, expiresAt) {
        if (sessionCookie != null) {
          ref
              .read(serverConfigNotifierProvider.notifier)
              .updateSessionCookie(sessionCookie);
        }
        state = AuthState.authenticated(
          userId: userId,
          token: token,
          expiresAt: expiresAt,
        );
      },
      failure: (_, __) => state = const AuthState.unauthenticated(),
    );
  }

  String _deviceName() {
    // Placeholder — can be replaced with device_info_plus for real device name.
    return 'SASO Mobile';
  }
}

// Convenience getter used by router redirect and splash page.
extension AuthStateX on AuthState {
  bool get isAuthenticated => this is Authenticated;
}
