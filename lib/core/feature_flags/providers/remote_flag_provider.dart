import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_constants.dart';
import '../feature_flag_service.dart';

/// Firebase Remote Config provider.
/// Infrastructure team controls flags via Firebase Console.
/// Flags update in real-time without app restart.
class RemoteFlagProvider implements FlagProvider {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  @override
  String get name => 'RemoteFlagProvider (Firebase)';

  @override
  Future<void> initialize() async {
    await _config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(minutes: 5),
      ),
    );

    await _config.setDefaults(
      FeatureFlags.defaults.map((k, v) => MapEntry(k, v)),
    );

    try {
      await _config.fetchAndActivate();
    } catch (e) {
      debugPrint('[FeatureFlags] Remote fetch failed, using defaults: $e');
    }

    // Real-time flag updates from infrastructure
    _config.onConfigUpdated.listen((_) async {
      await _config.activate();
      debugPrint('[FeatureFlags] Remote config updated');
    });
  }

  @override
  FlagResolution<bool> resolveBool(String key, bool defaultValue) =>
      FlagResolution(value: _config.getBool(key), reason: 'REMOTE_CONFIG');

  @override
  FlagResolution<String> resolveString(String key, String defaultValue) =>
      FlagResolution(
        value: _config.getString(key).isEmpty
            ? defaultValue
            : _config.getString(key),
        reason: 'REMOTE_CONFIG',
      );
}
