import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../logging/app_logger.dart';

/// HTTPS certificate-pinned [http.Client] factory.
///
/// Pins are supplied via `--dart-define` at build time so the pin set
/// can rotate without re-shipping Dart code:
///
/// ```
/// flutter run \
///   --dart-define=PINNED_HOST_AUTH=auth.willen.jp \
///   --dart-define=PINNED_SPKI_SHA256_AUTH=BASE64_PRIMARY,BASE64_BACKUP
/// ```
///
/// Computing the base64 SHA-256 of a server certificate:
/// ```
/// openssl s_client -servername auth.willen.jp -connect auth.willen.jp:443 \
///   < /dev/null 2>/dev/null \
///   | openssl x509 -outform DER \
///   | openssl dgst -sha256 -binary \
///   | openssl enc -base64
/// ```
///
/// Implementation notes
/// --------------------
/// `HttpClient.badCertificateCallback` only fires when the platform's
/// default chain validation has *failed*; for a CA-signed cert it never
/// runs. To enforce the pin against valid certs too, the client is
/// constructed with `SecurityContext(withTrustedRoots: false)`, which
/// forces every cert through the callback where we accept/deny based
/// on the pin set.
///
/// **Scope of this PR (#27):** the class and its factory live here and
/// can be injected into `RestV1ApiClient` / `LegacyApiClient` /
/// `OidcAuthService` / `IsbnLookupService` / `McpClient` /
/// `ConnectionTester` / `AuthDiscoveryService` through their existing
/// optional `http.Client` constructor parameters. Wiring those call
/// sites is a follow-up so this PR's diff stays auditable.
///
/// TODO(team): confirm rotation cadence — default below assumes a
/// 12-month primary + 12-month backup pin window.
class PinnedHttpClient {
  PinnedHttpClient._();

  /// Optional escape hatch: when true, falls back to an unpinned
  /// client if no pins are configured. Defaults to `kDebugMode` so
  /// developers can iterate without pins, but release builds without
  /// pins throw at startup (fail-closed).
  static bool _allowUnpinnedFallback = kDebugMode;

  @visibleForTesting
  // ignore: avoid_setters_without_getters
  static set allowUnpinnedFallback(bool value) =>
      _allowUnpinnedFallback = value;

  /// Build an [http.Client] enforcing the pinned SPKI/cert hashes in
  /// [pins]. When [pins] is `null`, reads from `--dart-define`s.
  static http.Client create({Map<String, List<String>>? pins}) {
    final effectivePins = pins ?? _pinsFromEnvironment();

    if (effectivePins.isEmpty) {
      if (!_allowUnpinnedFallback) {
        throw StateError(
          'PinnedHttpClient: no pins configured in a release build. '
          'Pass --dart-define=PINNED_SPKI_SHA256_AUTH=<base64>.',
        );
      }
      AppLogger.warn(
        'PinnedHttpClient',
        'running unpinned (no pins configured). '
            'This is acceptable only in debug.',
      );
      return http.Client();
    }

    // Disable platform trust anchors so every cert is routed through
    // our callback for explicit pin verification (SecurityContext()
    // defaults to withTrustedRoots: false).
    final httpClient = HttpClient(context: SecurityContext());
    httpClient.badCertificateCallback = (cert, host, port) {
      final accepted = effectivePins[host];
      if (accepted == null || accepted.isEmpty) return false;
      final hash = base64Encode(sha256.convert(cert.der).bytes);
      return accepted.contains(hash);
    };
    return IOClient(httpClient);
  }

  static Map<String, List<String>> _pinsFromEnvironment() {
    const authPin = String.fromEnvironment('PINNED_SPKI_SHA256_AUTH');
    const apiPin = String.fromEnvironment('PINNED_SPKI_SHA256_API');
    const authHost = String.fromEnvironment(
      'PINNED_HOST_AUTH',
      defaultValue: 'auth.willen.jp',
    );
    const apiHost = String.fromEnvironment(
      'PINNED_HOST_API',
      defaultValue: 'api.willen.jp',
    );
    final pins = <String, List<String>>{};
    if (authPin.isNotEmpty) {
      pins[authHost] = authPin.split(',').map((s) => s.trim()).toList();
    }
    if (apiPin.isNotEmpty) {
      pins[apiHost] = apiPin.split(',').map((s) => s.trim()).toList();
    }
    return pins;
  }
}
