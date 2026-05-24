import 'package:flutter/foundation.dart';

/// Centralised logging facade for the SASO Flutter app.
///
/// Every call collapses to a no-op in release builds, eliminating both
/// the Logcat / OSLog leak surface and the underlying string-literal
/// payload (the Dart tree-shaker drops the unreachable bodies). The
/// guards are written as `if (kDebugMode)` so they fold at compile time
/// — calls inside `if (kDebugMode) ...` blocks are removed entirely
/// from the release bundle.
///
/// Why not just `debugPrint`?
/// --------------------------
/// `debugPrint` itself is already a no-op in release mode (it routes
/// through `debugPrintThrottled`, which checks `kDebugMode` internally),
/// **but** the call-site arguments — `'[QrPairing] POST $uri'`, string
/// interpolations of JWTs / FCM tokens / SAML responses — still get
/// constructed and the literal prefixes still ship inside the APK
/// `.rodata`. R8 / Dart tree-shaking can prune those literals only when
/// the call is guarded by an unreachable branch. Centralising on
/// [AppLogger] guarantees every log site sits behind that guard.
///
/// PII / token safety
/// ------------------
/// **Never** pass a raw JWT, refresh token, FCM token, SAML assertion,
/// password, or session cookie to these methods. The methods short-
/// circuit in release mode, but a developer running a debug build over
/// `adb logcat` (or with a third-party logging tool installed) can read
/// every line. Log the *event* and a *redacted* shape (e.g. `len=512`,
/// `prefix=eyJ…`), not the secret itself.
///
/// Tag convention
/// --------------
/// Pass an upper-camelcase [tag] that identifies the subsystem
/// (`AuthDiscovery`, `RestAuth`, `QrPairing`, `FeatureFlags`, …). The
/// formatter renders it as `[TAG] message`, matching the bracketed
/// prefix the codebase already used with raw `debugPrint`.
///
/// See: docs/architecture/logging.md (logging policy + release-build
/// verification checklist). Also: dart.dev/tools/linter-rules/avoid_print
/// — the lint is promoted to `error` in `analysis_options.yaml` so any
/// new `print()` call fails CI.
class AppLogger {
  AppLogger._();

  /// Verbose developer trace. Stripped from release builds.
  ///
  /// Use for "I'm about to call this URL", "the body parsed cleanly",
  /// and similar fine-grained diagnostics. [error] is an optional
  /// payload appended after the message — typically an exception or a
  /// short HTTP status snippet.
  static void debug(String tag, String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint(
        error == null ? '[$tag] $message' : '[$tag] $message — $error',
      );
    }
  }

  /// Routine state-change log (login success, config bundle applied,
  /// remote-flag fetch finished). Stripped from release builds.
  static void info(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// Warning — recoverable but worth knowing about. Stripped from
  /// release builds.
  ///
  /// Use for "logout returned 500, clearing local state anyway", "the
  /// server-misconfigured fallback fired", etc. — anything we recover
  /// from but that an on-call engineer would want to see in a debug
  /// build.
  static void warn(String tag, String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint(
        error == null
            ? '[$tag] WARN $message'
            : '[$tag] WARN $message — $error',
      );
    }
  }

  /// Error — recoverable failure plus an optional stack trace.
  /// Stripped from release builds.
  ///
  /// In release builds the call is a no-op; route surface-able errors
  /// through your UI / Crashlytics / Sentry pipeline instead.
  static void error(
    String tag,
    String message,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint(
        stackTrace == null
            ? '[$tag] ERROR $message — $error'
            : '[$tag] ERROR $message — $error\n$stackTrace',
      );
    }
  }
}
