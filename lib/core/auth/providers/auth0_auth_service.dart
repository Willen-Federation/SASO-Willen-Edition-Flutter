import 'package:auth0_flutter/auth0_flutter.dart';

import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Auth0 native SDK authentication service.
/// Active when the server returns provider=auth0 from /api/v1/auth/providers.
///
/// Uses Auth0 Universal Login via the native Auth0 iOS/Android SDK.
/// Requires native platform setup:
///   iOS   — Info.plist: CFBundleURLSchemes includes "jp.willen.saso"
///   Android — AndroidManifest.xml: intent-filter for jp.willen.saso://callback
class Auth0AuthService implements AuthService {
  Auth0AuthService({
    required String domain,
    required String clientId,
    required SecureStorageService secureStorage,
  }) : _auth0 = Auth0(domain, clientId),
       _secureStorage = secureStorage;

  final Auth0 _auth0;
  final SecureStorageService _secureStorage;

  static const _redirectScheme = 'jp.willen.saso';

  Credentials? _credentials;

  @override
  String? get currentToken => _credentials?.accessToken;

  @override
  String? get currentUserId => _credentials?.user.sub;

  @override
  bool get isAuthenticated {
    final creds = _credentials;
    if (creds == null) return false;
    final exp = creds.expiresAt;
    return exp.isAfter(DateTime.now());
  }

  @override
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      // Auth0 Universal Login opens a browser — username/password are ignored
      // because Auth0 manages the login form natively.
      _credentials = await _auth0
          .webAuthentication(scheme: _redirectScheme)
          .login(parameters: const {'prompt': 'login'});

      final token = _credentials!.accessToken;
      await _secureStorage.write(AppConstants.jwtTokenKey, token);

      return AuthResult.success(
        userId: _credentials!.user.sub,
        token: token,
        expiresAt: _credentials!.expiresAt,
      );
    } on WebAuthenticationException catch (e) {
      return AuthResult.failure(message: e.message, code: e.code);
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: _redirectScheme).logout();
    } catch (_) {}
    _credentials = null;
    await _secureStorage.delete(AppConstants.jwtTokenKey);
  }

  @override
  Future<bool> refreshToken() async {
    final creds = _credentials;
    if (creds == null) return false;
    try {
      _credentials = await _auth0.credentialsManager.credentials();
      final token = _credentials!.accessToken;
      await _secureStorage.write(AppConstants.jwtTokenKey, token);
      return true;
    } catch (_) {
      return false;
    }
  }
}
