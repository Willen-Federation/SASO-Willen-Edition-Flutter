import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/theme/app_theme.dart';

// Issue #149 — Material 3 touch target audit (Android).
//
// These tests pin the theme-level enforcement of the 48×48 dp minimum
// touch target so regressions (e.g. removing `iconButtonTheme` or
// `visualDensity`) are caught by CI rather than only by manual a11y scans.
void main() {
  group('AppTheme touch target enforcement', () {
    for (final entry in <String, ThemeData Function()>{
      'light': () => AppTheme.light,
      'dark': () => AppTheme.dark,
    }.entries) {
      final label = entry.key;
      final theme = entry.value();

      test('$label theme uses VisualDensity.adaptivePlatformDensity', () {
        expect(theme.visualDensity, VisualDensity.adaptivePlatformDensity);
      });

      test('$label theme enforces 48×48 minimum size on IconButton', () {
        final style = theme.iconButtonTheme.style;
        expect(style, isNotNull, reason: 'iconButtonTheme.style must be set');
        final minSize = style!.minimumSize?.resolve(<WidgetState>{});
        expect(minSize, isNotNull);
        expect(minSize!.width, greaterThanOrEqualTo(48));
        expect(minSize.height, greaterThanOrEqualTo(48));
      });
    }
  });

  // Issue #124 — iOS native feel: Cupertino theme overlay must be wired
  // so CupertinoButton / CupertinoAlertDialog / CupertinoPageRoute use
  // the SASO brand seed (0xFF1565C0), not the Material 3 derived
  // primary, and must track Material light/dark brightness.
  group('AppTheme cupertinoOverrideTheme', () {
    test('light theme exposes a Cupertino override with brand primary', () {
      final cupertino = AppTheme.light.cupertinoOverrideTheme;
      expect(cupertino, isNotNull);
      expect(cupertino!.brightness, Brightness.light);
      expect(cupertino.primaryColor, const Color(0xFF1565C0));
    });

    test('dark theme exposes a Cupertino override with dark brightness', () {
      final cupertino = AppTheme.dark.cupertinoOverrideTheme;
      expect(cupertino, isNotNull);
      expect(cupertino!.brightness, Brightness.dark);
      expect(cupertino.primaryColor, const Color(0xFF1565C0));
    });
  });
}
