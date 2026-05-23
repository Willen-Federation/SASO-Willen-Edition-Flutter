import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../network/url_validator.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Session-cookie based auth for SASO legacy endpoints.
/// Used when ff_auth_oidc and ff_auth_firebase are both OFF.
///
/// **Deprecation status (v2.5):** Selected by `authServiceProvider`
/// only when `ApiMode.legacy` is active. `ApiMode.rest` users hit
/// `RestAuthService` (`POST /api/v1/auth/login`, added in PR-B3) instead.
///
/// **Removal target (v3.0):** this file is deleted in the same PR
/// that drops `ApiMode.legacy` and `ServerConfig.sessionCookie`. The
/// authServiceProvider switch (auth_state_provider.dart) and the
/// legacy session-cookie restore branch in `loadStoredCredentials()`
/// also go away. See `docs/v3-migration.md`.
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
    // Posts to the canonical SASO login endpoint. The trailing slash
    // matters: the server's `/auth/start/` template anchors its form
    // action on this absolute path so webview-embedded logins can't drift
    // the POST target via relative URL resolution, and the failure-redirect
    // logic on newer SASO builds anchors on `/auth/start/error/1/` rather
    // than the older bare `/error/1/`.
    final uri = base.replace(path: '${base.path}/auth/start/');
    final http.Response response;
    try {
      // Disable redirect-follow so we can inspect the 3xx response directly.
      // SASO's login endpoint signals "wrong credentials" via 303 →
      // `/auth/start/error/1/` (post-fix) or the older `/error/1/` (pre-fix),
      // both of which then 404. If the http client silently follows the
      // redirect we lose the actual auth signal and surface a misleading
      // "HTTP 404" with a homepage HTML body.
      final request = http.Request('POST', uri)
        ..headers['Content-Type'] = 'application/x-www-form-urlencoded'
        ..bodyFields = {'id': username, 'password': password}
        ..followRedirects = false;
      final streamed = await _http
          .send(request)
          .timeout(AppConstants.httpTimeout);
      response = await http.Response.fromStream(streamed);
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
    final cookie = response.headers['set-cookie'];

    // 302/303: SASO uses a See-Other redirect to either an error page
    // (`/error/1/` on bad credentials) or to a logged-in landing page on
    // success. Both responses set a PHPSESSID cookie, so the cookie alone
    // is not a success signal — the Location target is.
    if (status == 302 || status == 303) {
      final location = response.headers['location'] ?? '';
      if (_looksLikeAuthErrorRedirect(location)) {
        return AuthResult.failure(
          message:
              'Authentication failed: server redirected to "$location" — '
              'the username or password is likely incorrect.',
        );
      }
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
            'Authentication failed: server returned HTTP $status '
            '(Location: "$location") but no Set-Cookie header.',
      );
    }

    if (status == 200) {
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

  /// Returns true when [location] looks like the SASO server's "credentials
  /// rejected" landing page. The server redirects with `303 → /error/...`
  /// on older deployments or `303 → /auth/start/error/...` on newer ones
  /// after failed POSTs, while successful logins redirect to `/home/`,
  /// `/mypage/`, etc.
  static bool _looksLikeAuthErrorRedirect(String location) {
    if (location.isEmpty) return false;
    final path = Uri.tryParse(location)?.path ?? location;
    // Match any path containing an `/error/` segment so both legacy and
    // newer SASO redirect shapes are covered, plus the bare `/error`
    // tail and relative `error/...` variants.
    return path.contains('/error/') ||
        path.endsWith('/error') ||
        path == 'error' ||
        path.startsWith('error/');
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
