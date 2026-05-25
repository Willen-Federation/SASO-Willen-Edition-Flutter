// Regression guard for ios/Runner/Info.plist + PrivacyInfo.xcprivacy.
//
// These files are static configuration that App Store Review reads at
// upload time. A typo or a missing key won't fail the Flutter build but
// will produce a TestFlight rejection days later, so we pin the values
// here as plain string checks.
//
// We parse the XML by string-search rather than a real plist parser
// because (a) the test runner has no plist library, and (b) the precise
// text of the keys is what App Review cares about — a structural rewrite
// that broke the literal substring would also break review.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ios/Runner/Info.plist — issue #126 / #138 / #122', () {
    late String plist;

    setUpAll(() async {
      plist = await File('ios/Runner/Info.plist').readAsString();
    });

    test('iPhone is portrait-only', () {
      // Match the block exactly so a future re-add of landscape is
      // caught regardless of whether it lands above or below the
      // existing portrait declaration.
      expect(
        plist.contains(
          '<key>UISupportedInterfaceOrientations</key>\n'
          '\t\t<array>\n'
          '\t\t\t<string>UIInterfaceOrientationPortrait</string>\n'
          '\t\t</array>',
        ),
        isTrue,
        reason: 'iPhone UISupportedInterfaceOrientations must be portrait-only',
      );
    });

    test('iPad disallows landscape', () {
      expect(
        plist,
        isNot(contains('UIInterfaceOrientationLandscapeLeft')),
        reason: 'iPad must not declare landscape (see issue #126)',
      );
      expect(
        plist,
        isNot(contains('UIInterfaceOrientationLandscapeRight')),
        reason: 'iPad must not declare landscape (see issue #126)',
      );
    });

    test(
      'declares NSCameraUsageDescription and NSPhotoLibraryUsageDescription',
      () {
        expect(plist, contains('<key>NSCameraUsageDescription</key>'));
        expect(plist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
      },
    );

    test('declares ITSAppUsesNonExemptEncryption = false', () {
      expect(
        plist.contains(
          '<key>ITSAppUsesNonExemptEncryption</key>\n\t\t<false/>',
        ),
        isTrue,
        reason: 'Export-compliance shortcut required for TestFlight uploads',
      );
    });
  });

  group('ios/Runner/PrivacyInfo.xcprivacy — Apple Privacy Manifest', () {
    late String manifest;

    setUpAll(() async {
      manifest = await File('ios/Runner/PrivacyInfo.xcprivacy').readAsString();
    });

    test('NSPrivacyTracking is false', () {
      expect(
        manifest.contains('<key>NSPrivacyTracking</key>\n    <false/>'),
        isTrue,
        reason:
            'App must not use data for ATT tracking (see '
            'docs/release/app-privacy-mapping.md)',
      );
    });

    test(
      'declares the four Required Reason API categories used by Flutter',
      () {
        expect(manifest, contains('NSPrivacyAccessedAPICategoryUserDefaults'));
        expect(manifest, contains('NSPrivacyAccessedAPICategoryFileTimestamp'));
        expect(manifest, contains('NSPrivacyAccessedAPICategoryDiskSpace'));
        expect(
          manifest,
          contains('NSPrivacyAccessedAPICategorySystemBootTime'),
        );
      },
    );

    test(
      'declares the collected data types matching app-privacy-mapping.md',
      () {
        expect(manifest, contains('NSPrivacyCollectedDataTypeEmailAddress'));
        expect(manifest, contains('NSPrivacyCollectedDataTypeUserID'));
        expect(manifest, contains('NSPrivacyCollectedDataTypeDeviceID'));
        expect(manifest, contains('NSPrivacyCollectedDataTypePhotosorVideos'));
      },
    );
  });

  group('android/app/src/main/AndroidManifest.xml — issue #126', () {
    late String manifest;

    setUpAll(() async {
      manifest = await File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsString();
    });

    test('MainActivity is locked to portrait', () {
      expect(
        manifest,
        contains('android:screenOrientation="portrait"'),
        reason:
            'MainActivity must declare portrait so cold-launch in '
            'landscape orientation is impossible',
      );
    });
  });
}
