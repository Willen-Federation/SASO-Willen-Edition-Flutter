import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

/// Per-directory test bootstrap automatically loaded by `flutter test`.
///
/// `AppTheme.light / dark` build their `TextTheme` via
/// `GoogleFonts.notoSansJpTextTheme`. That call schedules an async font
/// fetch from fonts.gstatic.com — which is unreachable from the CI runner.
/// With `allowRuntimeFetching = false` the package tries the local asset
/// bundle instead, which also fails (we don't ship the font as an asset).
/// Either way, an asynchronous "font not found" exception fires AFTER the
/// unit tests have asserted on `AppSemanticColors`, and the test framework
/// surfaces that as a post-completion failure even though every assertion
/// passed.
///
/// Filtering the async error here keeps the tests honest: they still fail
/// for any real exception, but the irrelevant font-loading noise from
/// google_fonts is swallowed.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.exception.toString();
    if (msg.contains('GoogleFonts') ||
        msg.contains('NotoSansJP') ||
        (msg.contains('font') && msg.contains('was not found'))) {
      return;
    }
    originalOnError?.call(details);
  };

  await runZonedGuarded(
    () async => testMain(),
    (error, stack) {
      final msg = error.toString();
      if (msg.contains('GoogleFonts') ||
          msg.contains('NotoSansJP') ||
          (msg.contains('font') && msg.contains('was not found'))) {
        return;
      }
      Zone.current.handleUncaughtError(error, stack);
    },
  );
}
