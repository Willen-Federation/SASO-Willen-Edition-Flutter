import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' hide AuthResult;
import 'package:amplify_flutter/amplify_flutter.dart';

import '../../constants/app_constants.dart';
import '../../push/providers/amplify_configurator.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Amazon Cognito authentication service using Amplify Auth plugin.
/// Active when the server returns provider=cognito from /api/v1/auth/providers.
///
/// Configures Amplify dynamically from server-provided pool credentials so
/// multiple deployments can share a single app binary.
///
/// Requires native platform setup for Hosted UI redirect:
///   iOS   — Info.plist: CFBundleURLSchemes includes "jp.willen.saso"
///   Android — AndroidManifest.xml: intent-filter for jp.willen.saso://callback
class CognitoAuthService implements AuthService {
  CognitoAuthService({
    required String userPoolId,
    required String clientId,
    required String region,
    String? hostedUiDomain,
    required SecureStorageService secureStorage,
  }) : _userPoolId = userPoolId,
       _clientId = clientId,
       _region = region,
       _hostedUiDomain = hostedUiDomain,
       _secureStorage = secureStorage;

  final String _userPoolId;
  final String _clientId;
  final String _region;
  final String? _hostedUiDomain;
  final SecureStorageService _secureStorage;

  bool _amplifyConfigured = false;
  String? _cachedToken;
  String? _cachedUserId;

  @override
  String? get currentToken => _cachedToken;

  @override
  String? get currentUserId => _cachedUserId;

  @override
  bool get isAuthenticated => _cachedToken != null;



  Future<void> _ensureConfigured() async {
    if (_amplifyConfigured) return;
    if (!Amplify.isConfigured) {
      await AmplifyConfigurator.configureWithDetails(
        userPoolId: _userPoolId,
        clientId: _clientId,
        region: _region,
        hostedUiDomain: _hostedUiDomain,
      );
    }
    _amplifyConfigured = Amplify.isConfigured;
  }

  @override
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      await _ensureConfigured();

      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );

      if (!result.isSignedIn) {
        return const AuthResult.failure(
          message: 'Cognito sign-in did not complete',
        );
      }

      final session = await Amplify.Auth.fetchAuthSession();
      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.accessToken.raw;
      final userId = cognitoSession.userSubResult.value;

      _cachedToken = token;
      _cachedUserId = userId;
      await _secureStorage.write(AppConstants.jwtTokenKey, token);

      return AuthResult.success(userId: userId, token: token);
    } on AuthException catch (e) {
      return AuthResult.failure(message: e.message, code: e.recoverySuggestion);
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _ensureConfigured();
      await Amplify.Auth.signOut();
    } catch (_) {}
    _cachedToken = null;
    _cachedUserId = null;
    await _secureStorage.delete(AppConstants.jwtTokenKey);
  }

  @override
  Future<bool> refreshToken() async {
    try {
      await _ensureConfigured();
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true),
      );
      final cognitoSession = session as CognitoAuthSession;
      final token = cognitoSession.userPoolTokensResult.value.accessToken.raw;
      _cachedToken = token;
      await _secureStorage.write(AppConstants.jwtTokenKey, token);
      return true;
    } catch (_) {}
    return false;
  }
}
