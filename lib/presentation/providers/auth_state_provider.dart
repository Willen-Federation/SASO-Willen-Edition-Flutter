import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/auth_provider_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/providers/auth0_auth_service.dart';
import '../../core/auth/providers/cognito_auth_service.dart';
import '../../core/auth/providers/firebase_auth_service.dart';
import '../../core/auth/providers/legacy_auth_service.dart';
import '../../core/auth/providers/oidc_auth_service.dart';
import '../../core/auth/providers/saml_auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/push/push_notification_router.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/datasources/remote/v1/rest_api_client.dart';
import 'server_config_provider.dart';

part 'auth_state_provider.g.dart';

// ---------------------------------------------------------------------------
// Detected auth provider config
// ---------------------------------------------------------------------------

@riverpod
class AuthProviderConfigNotifier extends _$AuthProviderConfigNotifier {
  @override
  AuthProviderConfig build() => const AuthProviderConfig.legacy();

  void set(AuthProviderConfig config) => state = config;
}

// ---------------------------------------------------------------------------
// Auth service selector
// ---------------------------------------------------------------------------

/// Selects and instantiates the appropriate [AuthService] based on the
/// currently detected provider config and server URL.
@riverpod
AuthService authService(Ref ref) {
  final config = ref.watch(serverConfigNotifierProvider);
  final providerConfig = ref.watch(authProviderConfigNotifierProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final serverUrl = config.baseUrl;

  return switch (providerConfig) {
    OidcAuthConfig() => OidcAuthService(serverUrl, secureStorage),
    SamlAuthConfig(:final loginUrl) => SamlAuthService(
      loginUrl: loginUrl,
      secureStorage: secureStorage,
    ),
    FirebaseAuthConfig() => FirebaseAuthService(secureStorage),
    Auth0AuthConfig(:final domain, :final clientId) => Auth0AuthService(
      domain: domain,
      clientId: clientId,
      secureStorage: secureStorage,
    ),
    CognitoAuthConfig(
      :final userPoolId,
      :final clientId,
      :final region,
      :final hostedUiDomain,
    ) =>
      CognitoAuthService(
        userPoolId: userPoolId,
        clientId: clientId,
        region: region,
        hostedUiDomain: hostedUiDomain,
        secureStorage: secureStorage,
      ),
    _ => LegacyAuthService(secureStorage),
  };
}

// ---------------------------------------------------------------------------
// Auth state notifier
// ---------------------------------------------------------------------------

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();

  /// Tries to restore credentials from secure storage on app start.
  Future<void> loadStoredCredentials() async {
    state = const AuthState.loading();
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.read(AppConstants.jwtTokenKey);
      if (token != null && token.isNotEmpty) {
        state = AuthState.authenticated(userId: 'restored', token: token);
        return;
      }
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  /// Credential-based login (legacy / firebase / cognito user+pass).
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

  /// Browser-based login (OIDC / Auth0 / Cognito hosted UI).
  Future<AuthResult> loginWithBrowser() async {
    state = const AuthState.loading();
    final service = ref.read(authServiceProvider);
    final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;

    final result = await service.login(
      serverUrl: serverUrl,
      username: '',
      password: '',
    );

    _applyResult(result, service);
    return result;
  }

  /// Called after SAML WebView captures the token from the callback URL.
  Future<AuthResult> loginWithSamlToken(String token) async {
    state = const AuthState.loading();
    final service = ref.read(authServiceProvider);
    if (service is SamlAuthService) {
      final result = await service.completeWithToken(token);
      _applyResult(result, service);
      return result;
    }
    const err = AuthResult.failure(
      message: 'SAML service not active',
      code: 'wrong_provider',
    );
    state = const AuthState.unauthenticated();
    return err;
  }

  /// Exchanges a QR pairing token for access+refresh tokens via the REST API.
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
              'pairing_token': pairingToken,
              'device_name': _deviceName(),
            }),
          )
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = json['access_token'] as String;
        final refreshToken = json['refresh_token'] as String;
        final deviceId = json['device_id'] as int;

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
        // Issue #19 — best-effort push-token registration after QR pairing.
        unawaited(_registerPushTokenAfterAuth(accessToken));
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
      success: (userId, token, _, expiresAt) {
        state = AuthState.authenticated(
          userId: userId,
          token: token,
          expiresAt: expiresAt,
        );
        // Issue #19 — best-effort push token registration after every
        // successful login. Fire-and-forget; never block the auth flow.
        if (token != null && token.isNotEmpty) {
          unawaited(_registerPushTokenAfterAuth(token));
        }
      },
      failure: (_, __) => state = const AuthState.unauthenticated(),
    );
  }

  /// Push-token registration hook called after successful authentication.
  ///
  /// Issue #19 — pairs an FCM/APNs token with the SASO backend so the
  /// server can fan out notifications to this device. The backend
  /// endpoint is in a separate repo and may not yet be deployed; the
  /// `RestV1ApiClient.registerPushToken` helper swallows 404/501 so
  /// rollout order doesn't break the mobile auth UX.
  ///
  /// All errors are caught here as well — push registration is
  /// strictly best-effort; failures must never bubble up and break a
  /// logged-in session.
  Future<void> _registerPushTokenAfterAuth(String accessToken) async {
    try {
      final pushService = ref.read(pushNotificationServiceProvider);
      if (!pushService.isSupported) return;

      final pushToken = await pushService.getDeviceToken();
      if (pushToken == null || pushToken.isEmpty) return;

      final platform = _detectPushPlatform();
      if (platform == null) return;

      final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;
      if (serverUrl.isEmpty) return;

      final client = RestV1ApiClient(
        serverUrl: serverUrl,
        jwtToken: accessToken,
      );
      await client.registerPushToken(token: pushToken, platform: platform);
    } catch (_) {
      // Best-effort: never let push-token registration fail auth.
    }
  }

  String? _detectPushPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'fcm';
      case TargetPlatform.iOS:
        return 'apns';
      default:
        // Other platforms (Linux/macOS/Windows/Fuchsia/web) have no
        // mobile push channel — skip registration entirely.
        return null;
    }
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
