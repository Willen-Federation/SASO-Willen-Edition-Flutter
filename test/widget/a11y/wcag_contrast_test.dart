// Regression guard for WCAG 2.1 AA contrast on the color tokens that
// replaced the hardcoded `Colors.amber.shade100` / `Colors.grey.shade*` /
// `Colors.orange.shade*` pairs flagged by issue #152 (D13).
//
// We do not assert ratios for the entire app theme — only the specific
// foreground/background pairs that the issue called out, so that a future
// theme tweak doesn't silently regress them below the 4.5:1 threshold for
// normal text or 3:1 for large text / non-text UI.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/theme/app_theme.dart';

/// WCAG 2.1 contrast ratio. Pure-math helper: relative luminance per
/// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance, ratio per
/// https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio. Range: 1.0 – 21.0.
double _contrastRatio(Color fg, Color bg) {
  double channel(double c) {
    final s = c / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4) as double;
  }

  double luminance(Color c) {
    final r = channel((c.r * 255).roundToDouble());
    final g = channel((c.g * 255).roundToDouble());
    final b = channel((c.b * 255).roundToDouble());
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  final l1 = luminance(fg);
  final l2 = luminance(bg);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('WCAG AA contrast — issue #152 (D13)', () {
    final schemes = <String, ColorScheme>{
      'light': AppTheme.light.colorScheme,
      'dark': AppTheme.dark.colorScheme,
    };

    schemes.forEach((label, scheme) {
      group(label, () {
        // home_page.dart mock-mode banner.
        test('tertiaryContainer / onTertiaryContainer ≥ 4.5:1', () {
          final ratio = _contrastRatio(
            scheme.onTertiaryContainer,
            scheme.tertiaryContainer,
          );
          expect(ratio, greaterThanOrEqualTo(4.5));
        });

        // item_register_page.dart secondary text (book publisher).
        test('onSurfaceVariant / surface ≥ 4.5:1', () {
          final ratio = _contrastRatio(scheme.onSurfaceVariant, scheme.surface);
          expect(ratio, greaterThanOrEqualTo(4.5));
        });

        // offline_indicator.dart badge.
        test('onErrorContainer / errorContainer ≥ 4.5:1', () {
          final ratio = _contrastRatio(
            scheme.onErrorContainer,
            scheme.errorContainer,
          );
          expect(ratio, greaterThanOrEqualTo(4.5));
        });

        // item_register_page.dart drag handle: non-text UI → 3:1 (WCAG 1.4.11).
        test('onSurfaceVariant / surfaceContainerLow ≥ 3:1 (non-text)', () {
          final ratio = _contrastRatio(
            scheme.onSurfaceVariant,
            scheme.surfaceContainerLow,
          );
          expect(ratio, greaterThanOrEqualTo(3.0));
        });
      });
    });
  });
}
