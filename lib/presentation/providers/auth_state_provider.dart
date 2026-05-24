import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/providers/auth0_auth_service.dart';
import '../../core/auth/providers/legacy_auth_service.dart';
import '../../core/auth/providers/oidc_auth_service.dart';
import '../../core/auth/providers/rest_auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
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

/// Returns the local credential-based auth service.
///
/// Selection rule:
///   - [ApiMode.rest] → [RestAuthService] (`POST /api/v1/auth/login`,
///     introduced in PR-A3 server-side). New deployments should land here.
///   - [ApiMode.legacy] → [LegacyAuthService] (`POST /auth/start/` form
///     redirect dance). Deprecated in v2.5; removed in v3.0.
///   - [ApiMode.mock] → also returns [LegacyAuthService] but the mock
///     code path skips the network call entirely so the choice doesn't
///     matter — kept simple to avoid an extra branch.
///
/// External providers (OIDC / SAML / Auth0 / Cognito / Firebase) are reached
/// through the server's `/m/setup` browser flow rather than a per-provider
/// native SDK, so this provider does not depend on discovery.
@riverpod
AuthService authService(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final mode = ref.watch(
    serverConfigNotifierProvider.select((config) => config.apiMode),
  );
  if (mode == ApiMode.rest) {
    return RestAuthService(secureStorage);
  }
  // TODO(v3.0): collapse this provider to `return RestAuthService(secureStorage);`
  // once ApiMode.legacy is removed. See docs/v3-migration.md.
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
      // TODO(v3.0): drop this branch with the ApiMode.legacy removal.
      // The sessionCookieKey read + AppConstants.sessionCookieKey itself
      // also go away. See docs/v3-migration.md.
      final cookie = await secureStorage.read(AppConstants.sessionCookieKey);
      if (cookie != null && cookie.isNotEmpty) {
        state = const AuthState.authenticated(userId: 'restored');
        return;
      }
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  /// Credential-based login. Dispatches to the [authServiceProvider]
  /// configured for the active [ApiMode] — [RestAuthService] for REST
  /// deployments (`POST /api/v1/auth/login`), [LegacyAuthService] for
  /// legacy ones (`POST /auth/start/`). On success, the REST path also
  /// pumps the freshly issued token pair through
  /// [ServerConfigNotifier.updateTokenPair] so the in-memory config —
  /// and therefore [RestV1ApiClient] — picks up the new Bearer
  /// immediately without an app restart.
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

    // Propagate the REST token pair into ServerConfig so api_client_provider
    // rebuilds the RestV1ApiClient with the new Bearer. The service has
    // already written the tokens to SecureStorage; this just syncs the
    // in-memory state so the current session is usable without a restart.
    if (result is AuthSuccess && service is RestAuthService) {
      final access = service.currentToken;
      final refresh = service.currentRefreshToken;
      final deviceId = service.currentDeviceId;
      if (access != null && refresh != null && deviceId != null) {
        await ref
            .read(serverConfigNotifierProvider.notifier)
            .updateTokenPair(
              accessToken: access,
              refreshToken: refresh,
              deviceId: deviceId,
            );
      }
    }

    _applyResult(result, service);
    return result;
  }

  /// Auth0 Universal Login. The server must have advertised an enabled
  /// Auth0 provider with `domain` + `clientId` via
  /// `GET /api/v1/auth/providers` — the caller is expected to pull those
  /// values out of [ServerAuthDiscoveryX.auth0Provider]. We deliberately
  /// take the raw strings (not the summary) so this method stays usable
  /// from tests that inject fake configs.
  ///
  /// On success the Auth0 access token is persisted as
  /// [AppConstants.jwtTokenKey] (done by [Auth0AuthService.login]). We
  /// also clear stale OIDC / session-cookie state so the next
  /// `loadStoredCredentials()` resolves to the Auth0 JWT instead of
  /// preferring an expired OIDC refresh.
  Future<AuthResult> loginWithAuth0({
    required String domain,
    required String clientId,
  }) async {
    state = const AuthState.loading();
    final secureStorage = ref.read(secureStorageProvider);
    final service = Auth0AuthService(
      domain: domain,
      clientId: clientId,
      secureStorage: secureStorage,
    );
    final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;

    final result = await service.login(
      serverUrl: serverUrl,
      username: '',
      password: '',
    );

    if (result is AuthSuccess) {
      await secureStorage.delete(AppConstants.oidcRefreshTokenKey);
      await secureStorage.delete(AppConstants.oidcExpiresAtKey);
      await secureStorage.delete(AppConstants.oidcUserIdKey);
      await secureStorage.delete(AppConstants.sessionCookieKey);
    }

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
    final uri = Uri.parse('$serverUrl/api/v1/mobile/connect');
    AppLogger.debug('QrPairing', 'POST $uri');

    final http.Response response;
    try {
      response = await http
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
    } on TimeoutException catch (_) {
      state = const AuthState.unauthenticated();
      final msg =
          'Network timeout after ${AppConstants.httpTimeout.inSeconds}s '
          '(POST $uri)';
      AppLogger.warn('QrPairing', msg);
      return AuthResult.failure(message: msg);
    } catch (e) {
      state = const AuthState.unauthenticated();
      final msg = 'Network error: $e (POST $uri)';
      AppLogger.warn('QrPairing', msg);
      return AuthResult.failure(message: msg);
    }

    final status = response.statusCode;
    AppLogger.debug(
      'QrPairing',
      'HTTP $status (${response.body.length} bytes body)',
    );

    if (status == 200 || status == 201) {
      try {
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
      } catch (e) {
        state = const AuthState.unauthenticated();
        final msg =
            'Pairing failed: server returned HTTP $status but the response '
            'body could not be parsed ($e). Body: ${_snippet(response.body)}';
        AppLogger.warn('QrPairing', msg);
        return AuthResult.failure(message: msg);
      }
    }

    state = const AuthState.unauthenticated();
    // A 404 on /api/v1/mobile/connect almost always means the server is a
    // legacy SASO deployment that doesn't expose the v1 REST surface —
    // QR pairing is REST-only, so surface that hint instead of a bare code.
    final hint =
        status == 404
            ? ' — /api/v1/mobile/connect not found; the server may be a '
                'legacy SASO deployment without the v1 REST API'
            : '';
    final msg =
        'Pairing failed (HTTP $status$hint): ${_snippet(response.body)} '
        '(POST $uri)';
    AppLogger.warn('QrPairing', msg);
    return AuthResult.failure(message: msg);
  }

  /// Collapse whitespace and truncate so HTML/JSON error bodies stay
  /// readable when surfaced in the pairing UI banner.
  static String _snippet(String body) {
    final flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.isEmpty) return '(empty body)';
    if (flat.length <= 200) return flat;
    return '${flat.substring(0, 200)}…';
  }

  /// Sign out the active session. For REST mode, this hits
  /// `POST /api/v1/auth/logout` so the server-side refresh token is
  /// revoked. For legacy / SSO modes, falls through to the service's
  /// own teardown (cookie clear / SDK signOut / etc.). Local state is
  /// cleared even when the server is unreachable.
  Future<void> logout() async {
    try {
      final service = ref.read(authServiceProvider);
      if (service is RestAuthService) {
        // REST: revoke the refresh token server-side via /api/v1/auth/logout
        // before the local-state clear. We pass the baseUrl explicitly
        // because AuthService.logout() doesn't carry one — see
        // RestAuthService.logoutFromServer() for the rationale.
        final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;
        await service.logoutFromServer(serverUrl);
      } else {
        await service.logout();
      }
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
