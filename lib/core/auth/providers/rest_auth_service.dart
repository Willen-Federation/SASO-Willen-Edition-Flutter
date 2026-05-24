import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/app_constants.dart';
import '../../logging/app_logger.dart';
import '../../network/url_validator.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// REST v1 username/password authentication.
///
/// Talks to the server endpoints introduced in SASO-Willen-Edition PR-A3
/// (`POST /api/v1/auth/login`, `/logout`, `/password`) which return the same
/// `{access_token, refresh_token, device_id, expires_in, expires_at}` shape
/// as `POST /api/v1/mobile/connect`. From this service's perspective the
/// two flows are interchangeable — only the credential shape differs
/// (typed username/password vs. QR-derived pairing code).
///
/// Use this when [ApiMode.rest] is active and the server's discovery
/// document advertises the `local` provider. For legacy SASO deployments
/// that still go through the form-based `/auth/start/` redirect dance,
/// see [LegacyAuthService] — slated for removal in v3.0.
///
/// Error model: the server returns RFC 7807 `application/problem+json`
/// bodies with `SASO-AUTH-1xxx` codes. This service parses them into
/// [AuthResult.failure] with a human-readable [AuthResult.failure.message]
/// and the original error code preserved in [AuthResult.failure.code] so
/// the UI can branch on it (e.g. show a "rate limited" banner vs. a
/// "wrong password" inline error).
class RestAuthService implements AuthService {
  RestAuthService(this._secureStorage, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final SecureStorageService _secureStorage;
  final http.Client _http;

  String? _accessToken;
  String? _refreshToken;
  int? _deviceId;
  String? _userId;
  DateTime? _expiresAt;

  @override
  String? get currentToken => _accessToken;

  @override
  String? get currentUserId => _userId;

  @override
  bool get isAuthenticated => _accessToken != null;

  /// The refresh token returned by the most recent successful login.
  ///
  /// Exposed (alongside [currentDeviceId]) so the caller — typically
  /// [AuthStateNotifier.loginWithCredentials] — can hand the values to
  /// [ServerConfigNotifier.updateTokenPair] and keep the in-memory
  /// `ServerConfig` in sync with the freshly persisted secure-storage
  /// values. `_AuthResult` does not carry these fields because they're
  /// REST-specific and would be meaningless for the legacy / SSO paths.
  String? get currentRefreshToken => _refreshToken;

  /// The mobile device id allocated by `POST /api/v1/auth/login` (or
  /// `/mobile/connect`). Used by `DELETE /api/v1/mobile/tokens/{id}` to
  /// revoke this device's refresh token later.
  int? get currentDeviceId => _deviceId;

  /// When the access token expires (UTC). May be null if the server
  /// response didn't include `expires_at` or `expires_in`.
  DateTime? get currentExpiresAt => _expiresAt;

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

    final uri = base.replace(path: '${base.path}/api/v1/auth/login');

    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
              'deviceName': 'SASO Mobile',
            }),
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

    if (status == 200 || status == 201) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = json['access_token'] as String;
        final refreshToken = json['refresh_token'] as String;
        final deviceIdRaw = json['device_id'];
        final deviceId = deviceIdRaw is int
            ? deviceIdRaw
            : int.parse(deviceIdRaw.toString());
        final expiresAt = _parseExpiresAt(json);

        _accessToken = accessToken;
        _refreshToken = refreshToken;
        _deviceId = deviceId;
        _userId = username;
        _expiresAt = expiresAt;

        // Persist the access token as the "REST session existed" signal
        // that `AuthStateNotifier.loadStoredCredentials()` reads on app
        // restart. Refresh-token persistence is intentionally delegated
        // to `ServerConfigNotifier.updateTokenPair()` (called by the
        // auth-state notifier right after this method returns) so there
        // is a single source of truth for the refresh-token write and
        // the same code path is exercised by both REST login and QR
        // pairing. Writing the refresh token here too would double-write
        // SecureStorage on every login for no benefit.
        await _secureStorage.write(AppConstants.jwtTokenKey, accessToken);

        return AuthResult.success(
          userId: username,
          token: accessToken,
          expiresAt: expiresAt,
        );
      } catch (e) {
        return AuthResult.failure(
          message:
              'Authentication failed: server returned HTTP $status but the '
              'response body could not be parsed ($e). '
              'Body: ${_snippet(response.body)}',
        );
      }
    }

    // Map known SASO-AUTH-* error codes to user-friendly messages while
    // preserving the original code so UI layers can branch on it.
    final problem = _tryParseProblemJson(response);
    if (problem != null) {
      final code = problem.code ?? 'UNKNOWN';
      final message = switch (code) {
        // The legacy 1001 + the PR-A3 numbering (1001/1009/1010/1011 etc.)
        // are append-only. See docs/api/auth-endpoints.md on the server
        // side for the canonical mapping.
        'SASO-AUTH-1001' => 'The username or password is incorrect.',
        'SASO-AUTH-1009' =>
          'This account is locked. Contact your administrator.',
        'SASO-AUTH-1010' =>
          problem.retryAfterSeconds != null
              ? 'Too many failed attempts. Try again in '
                    '${problem.retryAfterSeconds} seconds.'
              : 'Too many failed attempts. Try again later.',
        'SASO-AUTH-1011' => 'Login request was malformed. Please retry.',
        _ =>
          'Authentication failed (HTTP $status, code $code): '
              '${problem.detail ?? _snippet(response.body)}',
      };
      return AuthResult.failure(message: message, code: code);
    }

    return AuthResult.failure(
      message:
          'Authentication failed (HTTP $status): ${_snippet(response.body)}',
    );
  }

  /// [AuthService] contract: clears LOCAL state only.
  ///
  /// The `AuthService` interface predates the REST flow and does not
  /// carry a `serverUrl` — every other implementation (legacy, Auth0,
  /// OIDC, …) does its server-side teardown either against a known URL
  /// (Auth0 / OIDC) or not at all (legacy form login). For the REST
  /// flow we expose a separate [logoutFromServer] that takes the
  /// `serverUrl` so the auth-state notifier can revoke the refresh
  /// token server-side without changing the interface.
  ///
  /// Calling this directly skips the server-side revoke. Prefer
  /// [logoutFromServer] when you have the serverUrl in hand (the
  /// normal case from `AuthStateNotifier.logout()`).
  @override
  Future<void> logout() async {
    await _clearLocalState();
  }

  /// REST-specific logout. POSTs `/api/v1/auth/logout` with the active
  /// Bearer so the server revokes the refresh token bound to this
  /// device, then clears local state.
  ///
  /// Local state is cleared UNCONDITIONALLY: a network failure or a
  /// server error must not leave the user "stuck signed in" locally
  /// after they explicitly asked to sign out. The trade-off is the
  /// server-side refresh token remains valid until its natural TTL
  /// expires when the network call fails — acceptable because the
  /// local client can no longer use it.
  Future<void> logoutFromServer(String serverUrl) async {
    final accessToken = _accessToken;
    if (accessToken != null && serverUrl.isNotEmpty) {
      try {
        final base = UrlValidator.ensureHttpsOrLoopback(serverUrl);
        final uri = base.replace(path: '${base.path}/api/v1/auth/logout');
        final response = await _http
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Accept': 'application/json',
              },
            )
            .timeout(AppConstants.httpTimeout);
        if (response.statusCode != 204 && response.statusCode != 200) {
          AppLogger.warn(
            'RestAuth',
            'logout returned HTTP ${response.statusCode}; '
                'clearing local state regardless.',
          );
        }
      } on TimeoutException {
        AppLogger.warn('RestAuth', 'logout timed out; clearing local state.');
      } on ArgumentError catch (e) {
        AppLogger.warn(
          'RestAuth',
          'logout skipped — invalid serverUrl: ${e.message}',
        );
      } catch (e) {
        AppLogger.warn(
          'RestAuth',
          'logout network error; clearing local state.',
          e,
        );
      }
    }

    await _clearLocalState();
  }

  Future<void> _clearLocalState() async {
    _accessToken = null;
    _refreshToken = null;
    _deviceId = null;
    _userId = null;
    _expiresAt = null;

    await _secureStorage.delete(AppConstants.jwtTokenKey);
    await _secureStorage.delete(AppConstants.refreshTokenKey);
  }

  /// Change the authenticated member's password via
  /// `POST /api/v1/auth/password`.
  ///
  /// Side effects on success: the server revokes every OTHER device's
  /// refresh token while keeping this device's tokens valid. The client
  /// stores nothing new — the current access token remains usable until
  /// it expires, then the normal refresh flow takes over.
  ///
  /// Returns [AuthResult.success] on 204; [AuthResult.failure] with the
  /// SASO-AUTH-* code preserved on any error so the UI can branch on it.
  Future<AuthResult> changePassword({
    required String serverUrl,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_accessToken == null) {
      return const AuthResult.failure(
        message: 'Not authenticated. Sign in before changing your password.',
      );
    }

    final Uri base;
    try {
      base = UrlValidator.ensureHttpsOrLoopback(serverUrl);
    } on ArgumentError catch (e) {
      return AuthResult.failure(
        message: 'Server URL must use HTTPS: ${e.message}',
      );
    }

    final uri = base.replace(path: '${base.path}/api/v1/auth/password');

    final http.Response response;
    try {
      response = await _http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
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

    if (response.statusCode == 204) {
      return AuthResult.success(userId: _userId ?? 'rest-user');
    }

    final problem = _tryParseProblemJson(response);
    if (problem != null) {
      final code = problem.code ?? 'UNKNOWN';
      final message = switch (code) {
        'SASO-AUTH-1004' =>
          'Your session has expired. Sign in again to change your password.',
        'SASO-AUTH-1010' =>
          problem.retryAfterSeconds != null
              ? 'Too many attempts. Try again in '
                    '${problem.retryAfterSeconds} seconds.'
              : 'Too many attempts. Try again later.',
        'SASO-AUTH-1011' =>
          'Password change request was malformed. Please retry.',
        'SASO-AUTH-1012' => 'Your current password is incorrect.',
        'SASO-AUTH-1013' =>
          problem.detail ?? 'New password does not meet the password policy.',
        _ =>
          'Password change failed (HTTP ${response.statusCode}, code $code): '
              '${problem.detail ?? _snippet(response.body)}',
      };
      return AuthResult.failure(message: message, code: code);
    }

    return AuthResult.failure(
      message:
          'Password change failed (HTTP ${response.statusCode}): '
          '${_snippet(response.body)}',
    );
  }

  /// REST tokens are renewed via [RestV1ApiClient.refreshAccessToken];
  /// this method is kept for the [AuthService] contract but is a no-op
  /// here. Returning [isAuthenticated] preserves the same shape as the
  /// legacy implementation.
  @override
  Future<bool> refreshToken() async => isAuthenticated;

  static DateTime? _parseExpiresAt(Map<String, dynamic> json) {
    final raw = json['expires_at'];
    if (raw is String) {
      try {
        return DateTime.parse(raw).toUtc();
      } catch (_) {
        return null;
      }
    }
    final expiresIn = json['expires_in'];
    if (expiresIn is num) {
      return DateTime.now().toUtc().add(Duration(seconds: expiresIn.toInt()));
    }
    return null;
  }

  /// Parses an RFC 7807 `application/problem+json` body. Returns `null`
  /// if the response is not problem+json or the body is malformed.
  /// Server-side reference: SASO-Willen-Edition's
  /// `ProblemExceptionHandler` (see `Bootstrap.php`).
  static _AuthProblemJson? _tryParseProblemJson(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/problem+json')) return null;
    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return null;
      final retryAfter = response.headers['retry-after'];
      return _AuthProblemJson(
        code: json['code'] as String?,
        detail: json['detail'] as String?,
        retryAfterSeconds: retryAfter == null ? null : int.tryParse(retryAfter),
      );
    } catch (_) {
      return null;
    }
  }

  static String _snippet(String body) {
    final flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.isEmpty) return '(empty body)';
    if (flat.length <= 200) return flat;
    return '${flat.substring(0, 200)}…';
  }
}

class _AuthProblemJson {
  _AuthProblemJson({this.code, this.detail, this.retryAfterSeconds});
  final String? code;
  final String? detail;
  final int? retryAfterSeconds;
}
