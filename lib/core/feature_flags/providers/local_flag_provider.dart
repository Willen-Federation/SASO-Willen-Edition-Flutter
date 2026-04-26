import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../feature_flag_service.dart';

/// Local SharedPreferences-backed provider for device-level overrides.
/// Used in Settings screen to let QA override individual flags on-device.
class LocalFlagProvider implements FlagProvider {
  static const _prefix = 'local_flag_';

  SharedPreferences? _prefs;

  @override
  String get name => 'LocalFlagProvider';

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  FlagResolution<bool> resolveBool(String key, bool defaultValue) {
    final stored = _prefs?.getBool('$_prefix$key');
    return FlagResolution(
      value: stored ?? FeatureFlags.defaults[key] ?? defaultValue,
      reason: stored != null ? 'LOCAL_OVERRIDE' : 'DEFAULT',
    );
  }

  @override
  FlagResolution<String> resolveString(String key, String defaultValue) {
    final stored = _prefs?.getString('$_prefix$key');
    return FlagResolution(
      value: stored ?? defaultValue,
      reason: stored != null ? 'LOCAL_OVERRIDE' : 'DEFAULT',
    );
  }

  Future<void> setFlag(String key, bool value) async =>
      _prefs?.setBool('$_prefix$key', value);

  Future<void> clearFlag(String key) async => _prefs?.remove('$_prefix$key');
}
