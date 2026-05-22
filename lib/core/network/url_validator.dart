import 'package:flutter/foundation.dart';

/// Validates and normalizes server URLs configured by the user.
///
/// Enforces HTTPS-only outside of debug loopback to prevent
/// credentials/tokens from being transmitted in cleartext.
abstract final class UrlValidator {
  static const _loopbackHosts = {'localhost', '127.0.0.1', '::1'};

  /// Validates [url] and returns a normalized [Uri].
  ///
  /// Rules:
  /// - Must be an absolute URL with an authority component.
  /// - Must not embed userinfo (credentials).
  /// - Scheme must be `https`, OR `http` with a loopback host while
  ///   [allowLoopback] is true (defaults to `kDebugMode`).
  ///
  /// Normalizes by lowercasing the host, stripping a trailing slash from
  /// the path, and dropping an accidental `/api/v1[/...]` suffix (clients
  /// append the API path themselves).
  ///
  /// Throws [ArgumentError] when any rule is violated.
  static Uri ensureHttpsOrLoopback(String url, {bool? allowLoopback}) {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null || !parsed.hasAuthority) {
      throw ArgumentError.value(
        url,
        'url',
        'Server URL must be a valid absolute URL',
      );
    }
    if (parsed.userInfo.isNotEmpty) {
      throw ArgumentError.value(url, 'url', 'URL must not contain credentials');
    }

    final scheme = parsed.scheme.toLowerCase();
    final host = parsed.host.toLowerCase();
    final loopback = _loopbackHosts.contains(host);
    final allowLb = allowLoopback ?? kDebugMode;

    final httpOnLoopbackOk = scheme == 'http' && loopback && allowLb;
    if (scheme != 'https' && !httpOnLoopbackOk) {
      throw ArgumentError.value(url, 'url', 'Server URL must use HTTPS');
    }

    var path = parsed.path;
    while (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    // Anchor the baseUrl at the server root — clients append `/api/v1/...`
    // themselves, so a pasted `https://host/api/v1` would otherwise produce
    // `/api/v1/api/v1/...`.
    const apiPrefix = '/api/v1';
    if (path == apiPrefix || path.startsWith('$apiPrefix/')) {
      path = '';
    }

    return parsed.replace(scheme: scheme, host: host, path: path);
  }
}
