import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/constants/app_constants.dart';
import 'package:saso_willen_edition/core/feature_flags/feature_flag_service.dart';
import 'package:saso_willen_edition/core/feature_flags/providers/debug_flag_provider.dart';

void main() {
  group('DebugFlagProvider', () {
    late DebugFlagProvider provider;

    setUp(() => provider = DebugFlagProvider());

    test('resolveBool returns true for all defined feature flag keys', () {
      for (final key in FeatureFlags.defaults.keys) {
        final result = provider.resolveBool(key, false);
        expect(result.value, isTrue, reason: '$key should be ON in debug mode');
        expect(result.reason, 'DEBUG_OVERRIDE');
      }
    });

    test('resolveBool returns true for unknown keys', () {
      final result = provider.resolveBool('ff_unknown', false);
      expect(result.value, isTrue);
    });

    test('resolveString returns defaultValue', () {
      const defaultVal = 'fallback';
      final result = provider.resolveString('ff_any', defaultVal);
      expect(result.value, defaultVal);
    });

    test('name is DebugFlagProvider', () {
      expect(provider.name, 'DebugFlagProvider');
    });
  });

  group('FeatureFlagService with DebugFlagProvider', () {
    late FeatureFlagService service;

    setUp(() {
      service = FeatureFlagService.instance;
      service.setProviderForTesting(DebugFlagProvider());
    });

    test('getBool returns true for ff_push_fcm', () {
      expect(service.getBool(FeatureFlags.pushFcm), isTrue);
    });

    test('getBool returns true for ff_auth_oidc', () {
      expect(service.getBool(FeatureFlags.authOidc), isTrue);
    });

    test('getBool returns true for ff_barcode_scanner', () {
      expect(service.getBool(FeatureFlags.barcodeScanner), isTrue);
    });

    test('getBool returns true even for flags that are OFF by default', () {
      expect(service.getBool(FeatureFlags.pushSns), isTrue);
      expect(service.getBool(FeatureFlags.restApiV1), isTrue);
      expect(service.getBool(FeatureFlags.labelPrint), isTrue);
    });
  });

  group('FeatureFlags defaults', () {
    test('push FCM is ON by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.pushFcm], isTrue);
    });

    test('push SNS is OFF by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.pushSns], isFalse);
    });

    test('auth OIDC is ON by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.authOidc], isTrue);
    });

    test('auth Firebase is ON by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.authFirebase], isTrue);
    });

    test('REST API v1 is OFF by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.restApiV1], isFalse);
    });

    test('offline mode is ON by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.offlineMode], isTrue);
    });

    test('barcode scanner is ON by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.barcodeScanner], isTrue);
    });

    test('label print is OFF by default', () {
      expect(FeatureFlags.defaults[FeatureFlags.labelPrint], isFalse);
    });

    test('there are exactly 8 flags', () {
      expect(FeatureFlags.defaults.length, equals(8));
    });
  });
}
