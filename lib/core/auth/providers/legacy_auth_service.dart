import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../network/url_validator.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Session-cookie based auth for SASO legacy endpoints.
/// Used when ff_auth_oidc and ff_auth_firebase are both OFF.
class LegacyAuthService implements AuthService {
  LegacyAuthService(this._secureStorage);

  final SecureStorageService _secureStorage;
  String? _sessionCookie;
  String? _userId;

  @override
  String? get currentToken => _sessionCookie;

  @override
  String? get currentUserId => _userId;

  @override
  bool get isAuthenticated => _sessionCookie != null;

  @override
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final Uri base;
    try {
      base = UrlValidator.ensureHttpsOrLoopback(serverUrl);
    } on ArgumentError catch (e) {
      return AuthResult.failure(
        message: 'Server URL must use HTTPS: ${e.message}',
      );
    }
    try {
      final uri = base.replace(path: '${base.path}/auth/start');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'id': username, 'password': password},
          )
          .timeout(AppConstants.httpTimeout);

      if (response.statusCode == 200 || response.statusCode == 302) {
        final cookie = response.headers['set-cookie'];
        if (cookie != null) {
          _sessionCookie = cookie.split(';').first;
          _userId = username;
          await _secureStorage.write(
            AppConstants.sessionCookieKey,
            _sessionCookie!,
          );
          return AuthResult.success(
            userId: username,
            sessionCookie: _sessionCookie,
          );
        }
      }

      return const AuthResult.failure(message: 'Authentication failed');
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _sessionCookie = null;
    _userId = null;
    await _secureStorage.delete(AppConstants.sessionCookieKey);
  }

  @override
  Future<bool> refreshToken() async => isAuthenticated;

  Future<void> restoreSession() async {
    _sessionCookie = await _secureStorage.read(AppConstants.sessionCookieKey);
  }

  Map<String, String> get authHeaders =>
      _sessionCookie != null ? {'Cookie': _sessionCookie!} : {};

  static Future<String?> parseJson(String html) async {
    final jsonRegex = RegExp(r'var\s+data\s*=\s*(\{.*?\});', dotAll: true);
    final match = jsonRegex.firstMatch(html);
    return match?.group(1);
  }

  static dynamic decodeResponse(http.Response response) {
    if (response.body.trimLeft().startsWith('{') ||
        response.body.trimLeft().startsWith('[')) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
