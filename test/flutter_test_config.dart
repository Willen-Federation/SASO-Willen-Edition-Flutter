import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Per-directory test bootstrap automatically loaded by `flutter test`.
///
/// Disables `google_fonts` runtime fetching so unit tests that pump
/// [AppTheme.light] / [AppTheme.dark] don't hit fonts.gstatic.com from
/// the CI runner (which is sandboxed). The package falls back to the
/// platform default font silently, which is what tests already assert
/// against.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
