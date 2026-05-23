import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised Material 3 typescale + Noto Sans JP integration.
///
/// SASO Willen Edition is a Japanese-locale-first inventory app
/// (`locale: const Locale('ja')` in [SasoApp]). Android's default Roboto
/// font does not contain CJK glyphs, so the system silently falls back to
/// the device's bundled Noto Sans CJK build — but the fallback timing and
/// resolved weight differ between vendors (Pixel vs. Samsung vs. Sony),
/// producing inconsistent visual weight for product names that mix
/// Japanese and ASCII characters.
///
/// Issue #150 (Epic #139, Google Play v1.0 prep) calls for tokenising the
/// `TextTheme` so:
///
/// 1. Japanese text renders with a known, consistent typeface across
///    OEMs (Noto Sans JP via `google_fonts`).
/// 2. Every call site uses Material 3 typescale tokens
///    ([TextTheme.bodyMedium], [TextTheme.titleLarge], etc.) instead of
///    hard-coded `fontSize`. Material 3 tokens scale automatically with
///    the user's Display Size accessibility preference — hard-coded
///    `fontSize` does not.
/// 3. Theme overrides funnel through one place so dark mode and future
///    locale-specific tweaks have a single source of truth.
///
/// `GoogleFonts.notoSansJpTextTheme` fetches the font from fonts.google.com
/// at runtime on first use and caches it to disk. If the device is offline
/// before that first fetch completes, Flutter falls back to the platform
/// default (which is exactly the current behaviour), so no regression is
/// possible.
abstract final class AppTextTheme {
  /// Resolves the [TextTheme] for the given base — pass the brightness-
  /// appropriate [ColorScheme]-derived defaults from [ThemeData] and the
  /// helper layers Noto Sans JP on top.
  ///
  /// We start from Material 3's default English typescale (taken from the
  /// supplied [base]) so font sizes, weights, and line heights match the
  /// spec, then swap the typeface for Noto Sans JP via
  /// [GoogleFonts.notoSansJpTextTheme]. The font face change preserves
  /// every other property of [base].
  static TextTheme resolve(TextTheme base) {
    return GoogleFonts.notoSansJpTextTheme(base);
  }
}
