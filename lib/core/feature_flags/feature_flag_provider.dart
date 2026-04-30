import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import 'feature_flag_service.dart';

part 'feature_flag_provider.g.dart';

@riverpod
FeatureFlagService featureFlagService(Ref ref) => FeatureFlagService.instance;

/// Convenient typed accessor for boolean feature flags.
@riverpod
bool featureFlag(Ref ref, String key) {
  final service = ref.watch(featureFlagServiceProvider);
  return service.getBool(key);
}

/// Typed accessors for commonly used flags.
extension FeatureFlagProviderX on Ref {
  bool get isRestApiEnabled =>
      FeatureFlagService.instance.getBool(FeatureFlags.restApiV1);
  bool get isFcmEnabled =>
      FeatureFlagService.instance.getBool(FeatureFlags.pushFcm);
  bool get isSnsEnabled =>
      FeatureFlagService.instance.getBool(FeatureFlags.pushSns);
  bool get isOidcEnabled =>
      FeatureFlagService.instance.getBool(FeatureFlags.authOidc);
  bool get isFirebaseAuthEnabled =>
      FeatureFlagService.instance.getBool(FeatureFlags.authFirebase);
}
