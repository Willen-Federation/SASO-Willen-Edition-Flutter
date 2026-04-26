import '../feature_flag_service.dart';

/// Debug provider: all flags return true regardless of key.
/// Active in debug builds only — never shipped to production.
class DebugFlagProvider implements FlagProvider {
  @override
  String get name => 'DebugFlagProvider';

  @override
  Future<void> initialize() async {}

  @override
  FlagResolution<bool> resolveBool(String key, bool defaultValue) =>
      const FlagResolution(value: true, reason: 'DEBUG_OVERRIDE');

  @override
  FlagResolution<String> resolveString(String key, String defaultValue) =>
      FlagResolution(value: defaultValue, reason: 'DEBUG_OVERRIDE');
}
