import 'package:flutter/foundation.dart';
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
    final defaultVal = FeatureFlags.defaults[key] ?? false;
    return _provider.resolveBool(key, defaultVal).value;
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
