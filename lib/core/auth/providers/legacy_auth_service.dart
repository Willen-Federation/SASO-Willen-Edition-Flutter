import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../network/url_validator.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Session-cookie based auth for SASO legacy endpoints.
/// Used when ff_auth_oidc and ff_auth_firebase are both OFF.
class LegacyAuthService implements AuthService {
  LegacyAuthService(this._secureStorage, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final SecureStorageService _secureStorage;
  final http.Client _http;
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
    final uri = base.replace(path: '${base.path}/auth/start');
    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'id': username, 'password': password},
          )
          .timeout(AppConstants.httpTimeout);
    } on TimeoutException catch (_) {
      return AuthResult.failure(
        message:
            'Network timeout after ${AppConstants.httpTimeout.inSeconds}s '
            '(POST $uri)',
      );
    } catch (e) {
      return AuthResult.failure(message: 'Network error: $e (POST $uri)');
    }

    final status = response.statusCode;
    if (status == 200 || status == 302) {
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
      return AuthResult.failure(
        message:
            'Authentication failed: server returned HTTP $status but no '
            'Set-Cookie header. Body: ${_snippet(response.body)}',
      );
    }

    return AuthResult.failure(
      message:
          'Authentication failed (HTTP $status): ${_snippet(response.body)}',
    );
  }

  /// Collapse whitespace and truncate to keep error messages displayable
  /// in the login banner while still surfacing the meaningful prefix of
  /// a server response (HTML error page, JSON `{"error":"…"}`, etc.).
  static String _snippet(String body) {
    final flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.isEmpty) return '(empty body)';
    if (flat.length <= 200) return flat;
    return '${flat.substring(0, 200)}…';
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
