import 'package:flutter/foundation.dart';
import '../../data/models/config_bundle_model.dart';
import '../constants/app_constants.dart';
import 'providers/debug_flag_provider.dart';
import 'providers/remote_flag_provider.dart';

/// Resolution result following OpenFeature specification.
class FlagResolution<T> {
  const FlagResolution({
    required this.value,
    required this.reason,
    this.variant,
  });

  final T value;
  final String reason;
  final String? variant;
}

/// OpenFeature-compatible provider interface.
abstract interface class FlagProvider {
  Future<void> initialize();
  FlagResolution<bool> resolveBool(String key, bool defaultValue);
  FlagResolution<String> resolveString(String key, String defaultValue);
  String get name;
}

/// Central feature flag service following OpenFeature spec.
/// Debug builds use DebugFlagProvider (all flags ON).
/// Release builds use RemoteFlagProvider (Firebase Remote Config).
class FeatureFlagService {
  FeatureFlagService._();

  static final FeatureFlagService instance = FeatureFlagService._();

  late FlagProvider _provider;
  bool _initialized = false;

  /// Flags received from the server's /api/v1/mobile/config bundle.
  /// Takes precedence over Firebase / debug defaults when present.
  Map<String, bool> _serverBundleFlags = {};

  Future<void> initialize() async {
    if (_initialized) return;

    _provider = kDebugMode ? DebugFlagProvider() : RemoteFlagProvider();
    await _provider.initialize();
    _initialized = true;

    if (kDebugMode) {
      debugPrint('[FeatureFlags] Using ${_provider.name} (debug mode)');
    }
  }

  bool getBool(String key) {
    assert(_initialized, 'FeatureFlagService not initialized');
    if (_serverBundleFlags.containsKey(key)) return _serverBundleFlags[key]!;
    final defaultVal = FeatureFlags.defaults[key] ?? false;
    return _provider.resolveBool(key, defaultVal).value;
  }

  /// Apply feature flags from the server's /api/v1/mobile/config bundle.
  /// Server-managed flags override Firebase Remote Config and debug defaults,
  /// but local on-device overrides (QA) still take precedence.
  void applyServerConfigBundle(ConfigBundleModel bundle) {
    _serverBundleFlags = {
      for (final flag in bundle.featureFlags) flag.key: flag.enabled,
    };
    debugPrint(
      '[FeatureFlags] Server config bundle v${bundle.version} applied'
      ' (${_serverBundleFlags.length} flags)',
    );
  }

  String getString(String key, String defaultValue) {
    assert(_initialized, 'FeatureFlagService not initialized');
    return _provider.resolveString(key, defaultValue).value;
  }

  /// Override the provider — used in tests.
  void setProviderForTesting(FlagProvider provider) {
    _provider = provider;
    _initialized = true;
  }
}
