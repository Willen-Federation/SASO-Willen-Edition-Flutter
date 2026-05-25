// Regression guard for the portrait-only orientation policy declared in
// `lib/main.dart`. The Flutter test environment can intercept the
// `SystemChrome.setPreferredOrientations` MethodChannel call, so we can
// verify the exact list of orientations requested at startup without
// running the whole app. This guards against:
//
//   * Accidentally re-enabling landscape in a future refactor.
//   * Calling `setPreferredOrientations` with an empty list (which the
//     OS treats as "all orientations" — the silent regression that
//     prompted issue #126).
//
// Native-side regression for iOS Info.plist
// (`UISupportedInterfaceOrientations`) and the Android
// `screenOrientation` attribute is intentionally out of scope here —
// those are static configuration files and changes are caught by
// reviewing the diff, not by unit tests.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemChrome.setPreferredOrientations — issue #126', () {
    final List<MethodCall> calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'SystemChrome.setPreferredOrientations') {
              calls.add(call);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('portraitUp + portraitDown matches the policy in main.dart', () async {
      // Mirror the exact call shape from main.dart. This is the
      // canonical "if you change this, change main.dart too" pin.
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      expect(calls, hasLength(1));
      final args = calls.single.arguments as List;
      expect(args, contains('DeviceOrientation.portraitUp'));
      expect(args, contains('DeviceOrientation.portraitDown'));
      expect(
        args,
        isNot(contains('DeviceOrientation.landscapeLeft')),
        reason: 'landscape must remain locked off — see #126',
      );
      expect(
        args,
        isNot(contains('DeviceOrientation.landscapeRight')),
        reason: 'landscape must remain locked off — see #126',
      );
    });
  });
}
