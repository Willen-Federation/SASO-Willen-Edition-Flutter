import 'dart:async';

import 'package:saso_willen_edition/core/theme/text_theme.dart';

/// Per-directory test bootstrap automatically loaded by `flutter test`.
///
/// `AppTheme.light / dark` build their `TextTheme` via
/// `GoogleFonts.notoSansJpTextTheme`, which fetches the font over HTTP on
/// first use. The CI runner is sandboxed without network egress, so the
/// fetch fails asynchronously *after* unit tests assert and the framework
/// reports the noise as a post-completion failure even though every
/// assertion passes. Flipping [AppTextTheme.skipFontFetchForTests] to true
/// makes [AppTextTheme.resolve] return the platform-default typescale —
/// which matches the offline-first production behaviour until the font
/// download completes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppTextTheme.skipFontFetchForTests = true;
  await testMain();
}
