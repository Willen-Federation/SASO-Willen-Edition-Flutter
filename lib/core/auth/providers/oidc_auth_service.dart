import 'package:flutter_appauth/flutter_appauth.dart';

import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// OIDC / OAuth2 auth service using flutter_appauth.
/// Active when ff_auth_oidc = true (M3 REST API support).
/// Connects to the SASO backend OIDC provider.
///
/// Issue #31 — fail-closed token expiry:
/// `isAuthenticated` requires both a non-null access token AND a known
/// expiry strictly in the future (with a small skew). Tokens whose
/// expiry has been lost (e.g. app killed before expiry was persisted)
/// are treated as expired so the user is forced through the refresh /
/// re-login path rather than racing the server with a stale token.
class OidcAuthService implements AuthService {
  OidcAuthService(this._serverUrl, this._secureStorage);

  final String _serverUrl;
  final SecureStorageService _secureStorage;

  static const _appAuth = FlutterAppAuth();
  static const _clientId = 'saso-mobile';
  static const _redirectUrl = 'jp.willen.saso://callback';
  static const _scopes = ['openid', 'profile', 'saso:read', 'saso:write'];

  /// Treat tokens as expired this many seconds before their actual `exp`
  /// — guards against client/server clock drift and against the case
  /// where the network round-trip itself eats the remaining lifetime.
  static const _expiryClockSkew = Duration(seconds: 30);

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  DateTime? _expiresAt;

  @override
  String? get currentToken => _accessToken;

  @override
  String? get currentUserId => _userId;

  /// Fail-closed: token is valid only when expiry is **known** and in
  /// the future (minus skew). Treating null expiry as "valid forever"
  /// (the previous behaviour) let a token survive across app restarts
  /// even when its real expiry had passed, because `_expiresAt` was
  /// only held in memory and reset to null on rehydration.
  @override
  bool get isAuthenticated {
    if (_accessToken == null) return false;
    final expiry = _expiresAt;
    if (expiry == null) return false;
    return expiry.subtract(_expiryClockSkew).isAfter(DateTime.now());
  }

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

      await _persistSession();

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
    await _clearPersistedSession();
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
        if (result.refreshToken != null) {
          _refreshToken = result.refreshToken;
        }
        await _persistSession();
        return true;
      }
    } catch (_) {
      // Refresh failed — caller should surface a re-login. We do NOT
      // clear the cached refresh token here so transient network errors
      // don't log the user out; logout() is the only way to nuke state.
    }
    return false;
  }

  /// Rehydrate session state from secure storage. Call once at app
  /// startup — typically from the auth-state provider's `build()` /
  /// resume hook. Returns true when a still-valid session was
  /// restored, false otherwise (no token, expired token, or storage
  /// read error).
  ///
  /// When the persisted access token is expired, this method attempts
  /// a silent refresh using the persisted refresh token before giving
  /// up. That way the user is only forced through the OIDC re-auth
  /// flow when the refresh token is also dead.
  Future<bool> restoreSession() async {
    try {
      _accessToken = await _secureStorage.read(AppConstants.jwtTokenKey);
      _refreshToken = await _secureStorage.read(
        AppConstants.oidcRefreshTokenKey,
      );
      _userId = await _secureStorage.read(AppConstants.oidcUserIdKey);
      final expiresAtRaw = await _secureStorage.read(
        AppConstants.oidcExpiresAtKey,
      );
      _expiresAt =
          expiresAtRaw == null ? null : DateTime.tryParse(expiresAtRaw);
    } catch (_) {
      await _clearPersistedSession();
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _expiresAt = null;
      return false;
    }

    if (isAuthenticated) return true;

    // Access token gone / expired but a refresh token is on disk: try
    // a silent refresh before falling back to interactive login.
    if (_refreshToken != null) {
      final refreshed = await refreshToken();
      if (refreshed && isAuthenticated) return true;
    }

    // Either no refresh token, or refresh failed — clear the dead
    // session so a stale access token can't be returned via
    // `currentToken`. This is the fail-closed half of the contract.
    _accessToken = null;
    _expiresAt = null;
    await _secureStorage.delete(AppConstants.jwtTokenKey);
    await _secureStorage.delete(AppConstants.oidcExpiresAtKey);
    return false;
  }

  Future<void> _persistSession() async {
    if (_accessToken != null) {
      await _secureStorage.write(AppConstants.jwtTokenKey, _accessToken!);
    }
    if (_refreshToken != null) {
      await _secureStorage.write(
        AppConstants.oidcRefreshTokenKey,
        _refreshToken!,
      );
    }
    if (_expiresAt != null) {
      await _secureStorage.write(
        AppConstants.oidcExpiresAtKey,
        _expiresAt!.toUtc().toIso8601String(),
      );
    }
    if (_userId != null) {
      await _secureStorage.write(AppConstants.oidcUserIdKey, _userId!);
    }
  }

  Future<void> _clearPersistedSession() async {
    await _secureStorage.delete(AppConstants.jwtTokenKey);
    await _secureStorage.delete(AppConstants.oidcRefreshTokenKey);
    await _secureStorage.delete(AppConstants.oidcExpiresAtKey);
    await _secureStorage.delete(AppConstants.oidcUserIdKey);
  }
}
