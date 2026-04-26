import 'package:flutter_appauth/flutter_appauth.dart';

import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// OIDC / OAuth2 auth service using flutter_appauth.
/// Active when ff_auth_oidc = true (M3 REST API support).
/// Connects to the SASO backend OIDC provider.
class OidcAuthService implements AuthService {
  OidcAuthService(this._serverUrl, this._secureStorage);

  final String _serverUrl;
  final SecureStorageService _secureStorage;

  static const _appAuth = FlutterAppAuth();
  static const _clientId = 'saso-mobile';
  static const _redirectUrl = 'jp.willen.saso://callback';
  static const _scopes = ['openid', 'profile', 'saso:read', 'saso:write'];

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  DateTime? _expiresAt;

  @override
  String? get currentToken => _accessToken;

  @override
  String? get currentUserId => _userId;

  @override
  bool get isAuthenticated =>
      _accessToken != null &&
      (_expiresAt == null || _expiresAt!.isAfter(DateTime.now()));

  @override
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      final issuer = '$serverUrl/oidc';
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: issuer,
          scopes: _scopes,
        ),
      );

      _accessToken = result.accessToken;
      _refreshToken = result.refreshToken;
      _expiresAt = result.accessTokenExpirationDateTime;
      _userId = result.idToken ?? username;

      if (_accessToken != null) {
        await _secureStorage.write(AppConstants.jwtTokenKey, _accessToken!);
      }

      return AuthResult.success(
        userId: _userId!,
        token: _accessToken,
        expiresAt: _expiresAt,
      );
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _expiresAt = null;
    await _secureStorage.delete(AppConstants.jwtTokenKey);
  }

  @override
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          issuer: '$_serverUrl/oidc',
          refreshToken: _refreshToken,
          scopes: _scopes,
        ),
      );
      if (result.accessToken != null) {
        _accessToken = result.accessToken;
        _expiresAt = result.accessTokenExpirationDateTime;
        await _secureStorage.write(AppConstants.jwtTokenKey, _accessToken!);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
