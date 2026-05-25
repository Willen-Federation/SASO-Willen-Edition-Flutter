import 'dart:convert';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Helper to decode and validate basic JWT claims.
class JwtDecoder {
  const JwtDecoder._();

  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT token structure');
    }
    final payloadPart = parts[1];
    final normalized = base64Url.normalize(payloadPart);
    final decodedBytes = base64Url.decode(normalized);
    final decodedString = utf8.decode(decodedBytes);
    return jsonDecode(decodedString) as Map<String, dynamic>;
  }

  static bool isExpired(String token) {
    try {
      final payload = decodePayload(token);
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryTime);
    } catch (_) {
      return true;
    }
  }
}

/// SAML authentication service using an in-app WebView.
/// Active when the server returns provider=saml from /api/v1/auth/providers.
///
/// Opens the IdP SSO URL in a WebView and monitors redirects for the
/// callback URL "jp.willen.saso://callback?token=..." to extract the JWT.
///
/// The actual WebView is rendered by SamlWebViewPage; this service manages
/// token storage and the AuthService contract.
class SamlAuthService implements AuthService {
  SamlAuthService({
    required String loginUrl,
    required SecureStorageService secureStorage,
  }) : _loginUrl = loginUrl,
       _secureStorage = secureStorage;

  final String _loginUrl;
  final SecureStorageService _secureStorage;

  String? _token;
  String? _userId;

  /// SSO entry URL exposed to the login UI so it can open the WebView.
  String get loginUrl => _loginUrl;

  @override
  String? get currentToken => _token;

  @override
  String? get currentUserId => _userId;

  @override
  bool get isAuthenticated => _token != null;

  /// Called by [SamlWebViewPage] after it has intercepted the callback URL
  /// and extracted the JWT from the query parameter `token`.
  Future<AuthResult> completeWithToken(String token, {String? userId}) async {
    // Validate JWT structure and expiration
    final Map<String, dynamic> payload;
    try {
      payload = JwtDecoder.decodePayload(token);
    } catch (e) {
      return AuthResult.failure(
        message: 'Invalid token structure: $e',
        code: 'saml_invalid_token',
      );
    }

    if (JwtDecoder.isExpired(token)) {
      return const AuthResult.failure(
        message: 'Token has expired',
        code: 'saml_token_expired',
      );
    }

    // Use subject (sub) as userId fallback if not provided
    final resolvedUserId = userId ?? payload['sub']?.toString() ?? 'saml-user';

    _token = token;
    _userId = resolvedUserId;
    await _secureStorage.write(AppConstants.jwtTokenKey, token);
    return AuthResult.success(userId: resolvedUserId, token: token);
  }

  /// [login] is not used directly for SAML — the UI opens the WebView.
  /// Returns a failure so callers know to use [SamlWebViewPage] instead.
  @override
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    return const AuthResult.failure(
      message: 'SAML login requires WebView — call SamlWebViewPage instead',
      code: 'saml_webview_required',
    );
  }

  @override
  Future<void> logout() async {
    _token = null;
    _userId = null;
    await _secureStorage.delete(AppConstants.jwtTokenKey);
  }

  @override
  Future<bool> refreshToken() async => false;
}
