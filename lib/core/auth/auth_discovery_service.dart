import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../logging/app_logger.dart';
import 'auth_provider_config.dart';

/// Why discovery fell back to the local-only sentinel.
///
/// Surfaced via [AuthDiscoveryOutcome] so callers (settings UI, splash page,
/// admin diagnostic surfaces) can distinguish operational misconfiguration
/// from genuine network / parse issues. The default [none] is set when
/// discovery succeeded — including the "empty providers" case where the
/// server replied 200 but explicitly listed no providers (we synthesize a
/// local-only entry so the credential form still renders).
enum AuthDiscoveryFailureReason {
  /// Discovery succeeded — either parsed normally or the server returned an
  /// empty providers list (handled as local-only).
  none,

  /// `serverUrl` was empty, malformed, or had no scheme.
  invalidUrl,

  /// `httpClient.get(...)` threw — DNS failure, TLS error, timeout, etc.
  networkError,

  /// Server returned 500 with `application/problem+json` body carrying
  /// `code: "SASO-INFRA-9000"` — the server's APP_KEY is missing or invalid
  /// in its `.env`. This is an operations issue, not a client bug. The
  /// admin remediation is to run `php tools/repair-app-key.php` on the
  /// server (or to set APP_KEY manually) and reload PHP-FPM.
  serverMisconfigured,

  /// Any other non-200 response (404, 401, 503, …).
  httpNonSuccess,

  /// Body returned 200 but JSON parsing or schema validation failed.
  parseError,
}

/// Result of an auth-provider discovery call.
///
/// [discovery] is always a usable [ServerAuthDiscovery]; on any failure it
/// is the [ServerAuthDiscovery.localOnly] sentinel so the credential form
/// still renders. [failureReason] tells callers why we fell back, and
/// [failureDetail] carries a short admin-readable note (HTTP status, error
/// code, exception message, etc.) suitable for surfacing in a diagnostic
/// banner or settings page.
typedef AuthDiscoveryOutcome = ({
  ServerAuthDiscovery discovery,
  AuthDiscoveryFailureReason failureReason,
  String? failureDetail,
});

/// Discovers the auth providers the server has enabled.
///
/// Calls `GET {serverUrl}/api/v1/auth/providers` (public, no auth required)
/// and returns a [ServerAuthDiscovery] describing every enabled login
/// mechanism. Falls back to [ServerAuthDiscovery.localOnly] on any error or
/// non-200 status so the user can still attempt a username/password login.
/// The fallback path is intentionally non-fatal so the UI keeps rendering,
/// but each branch emits an `[AuthDiscovery]` [AppLogger] entry (debug-only
/// — see lib/core/logging/app_logger.dart) so the cause can still be
/// inspected via `flutter logs`. Nothing leaks in release builds.
///
/// Use [discoverWithOutcome] in new code to access the failure-reason
/// metadata; [discover] is kept as a thin wrapper for legacy callers that
/// only need the discovery payload.
class AuthDiscoveryService {
  AuthDiscoveryService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Backward-compatible entry point. Returns only the discovery payload;
  /// failure reasons are still logged via [AppLogger] (debug-only) but
  /// not surfaced to the caller.
  Future<ServerAuthDiscovery> discover(String serverUrl) async {
    final outcome = await discoverWithOutcome(serverUrl);
    return outcome.discovery;
  }

  /// Primary entry point. Returns the discovery payload plus a structured
  /// [AuthDiscoveryFailureReason] explaining any fallback to local-only.
  ///
  /// On a 500 with `code: "SASO-INFRA-9000"` the [failureReason] will be
  /// [AuthDiscoveryFailureReason.serverMisconfigured]; UI surfaces should
  /// treat this as an admin-level error rather than an end-user one.
  Future<AuthDiscoveryOutcome> discoverWithOutcome(String serverUrl) async {
    if (serverUrl.isEmpty) {
      return (
        discovery: ServerAuthDiscovery.localOnly,
        failureReason: AuthDiscoveryFailureReason.invalidUrl,
        failureDetail: 'serverUrl is empty',
      );
    }

    final uri = Uri.tryParse('$serverUrl/api/v1/auth/providers');
    if (uri == null || !uri.hasScheme) {
      AppLogger.warn('AuthDiscovery', 'invalid serverUrl: $serverUrl');
      return (
        discovery: ServerAuthDiscovery.localOnly,
        failureReason: AuthDiscoveryFailureReason.invalidUrl,
        failureDetail: 'invalid serverUrl: $serverUrl',
      );
    }

    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(AppConstants.httpTimeout);
    } catch (e) {
      AppLogger.warn('AuthDiscovery', 'GET $uri failed', e);
      return (
        discovery: ServerAuthDiscovery.localOnly,
        failureReason: AuthDiscoveryFailureReason.networkError,
        failureDetail: e.toString(),
      );
    }

    if (response.statusCode != 200) {
      final problem = _tryParseProblemJson(response);
      if (response.statusCode == 500 &&
          problem != null &&
          problem.code == 'SASO-INFRA-9000') {
        // Operations-level diagnostic, not an end-user error. The server's
        // APP_KEY is missing or invalid; until ops repair the `.env` the
        // SSO chooser cannot render. Admins: run `php tools/repair-app-key.php`
        // on the server and reload PHP-FPM, or set APP_KEY manually.
        AppLogger.error(
          'AuthDiscovery',
          'Server misconfigured (SASO-INFRA-9000): '
              'APP_KEY missing or invalid in server .env. '
              'Falling back to local credentials. '
              'Server admin: run `php tools/repair-app-key.php` on the server, '
              'or set APP_KEY in .env (32 random bytes, base64-encoded) and '
              'reload PHP-FPM. traceId=${problem.traceId ?? '(none)'}',
          'SASO-INFRA-9000',
        );
        return (
          discovery: ServerAuthDiscovery.localOnly,
          failureReason: AuthDiscoveryFailureReason.serverMisconfigured,
          failureDetail:
              'SASO-INFRA-9000: server APP_KEY missing or invalid '
              '(traceId=${problem.traceId ?? '-'})',
        );
      }

      AppLogger.warn(
        'AuthDiscovery',
        'GET $uri returned HTTP ${response.statusCode}: '
            '${_snippet(response.body)}',
      );
      return (
        discovery: ServerAuthDiscovery.localOnly,
        failureReason: AuthDiscoveryFailureReason.httpNonSuccess,
        failureDetail:
            'HTTP ${response.statusCode}: ${_snippet(response.body)}',
      );
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final discovery = ServerAuthDiscovery.fromJson(json);
      // Server may legitimately return an empty providers list — surface
      // a local-only fallback so the credential form still renders.
      if (discovery.providers.isEmpty) {
        return (
          discovery: discovery.copyWith(
            providers: ServerAuthDiscovery.localOnly.providers,
            authStrategy: AuthStrategy.localOnly,
          ),
          failureReason: AuthDiscoveryFailureReason.none,
          failureDetail: null,
        );
      }
      return (
        discovery: discovery,
        failureReason: AuthDiscoveryFailureReason.none,
        failureDetail: null,
      );
    } catch (e) {
      AppLogger.warn(
        'AuthDiscovery',
        'could not parse response from $uri. '
            'Body: ${_snippet(response.body)}',
        e,
      );
      return (
        discovery: ServerAuthDiscovery.localOnly,
        failureReason: AuthDiscoveryFailureReason.parseError,
        failureDetail: 'parse error: $e',
      );
    }
  }

  /// Parses an RFC 7807 `application/problem+json` body. Returns `null` if
  /// the response is not problem+json or the body is malformed.
  ///
  /// The server's `InfraUnhandled` handler emits these bodies for any
  /// unrecovered exception (see `Bootstrap.php` → `ProblemExceptionHandler`
  /// in SASO-Willen-Edition). The shape is:
  ///
  /// ```json
  /// {
  ///   "type":     "https://docs.willen-federation.org/error-codes#SASO-INFRA-9000",
  ///   "title":    "Internal server error",
  ///   "status":   500,
  ///   "detail":   "An unexpected error occurred. Reference: <uuid>.",
  ///   "instance": "/api/v1/auth/providers",
  ///   "code":     "SASO-INFRA-9000",
  ///   "traceId":  "<uuid>"
  /// }
  /// ```
  static _ProblemJson? _tryParseProblemJson(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/problem+json')) return null;
    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return null;
      return _ProblemJson(
        code: json['code'] as String?,
        traceId: json['traceId'] as String?,
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

/// Minimal RFC 7807 projection — just the fields the client cares about.
class _ProblemJson {
  _ProblemJson({this.code, this.traceId});
  final String? code;
  final String? traceId;
}
