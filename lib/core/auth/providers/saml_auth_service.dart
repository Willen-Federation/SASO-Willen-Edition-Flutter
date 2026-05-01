import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

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
    _token = token;
    _userId = userId;
    await _secureStorage.write(AppConstants.jwtTokenKey, token);
    return AuthResult.success(userId: userId ?? 'saml-user', token: token);
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
