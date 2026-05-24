import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/theme/app_colors.dart';
import 'package:saso_willen_edition/core/theme/app_theme.dart';

void main() {
  group('AppSemanticColors', () {
    test('light factory produces consistent palette', () {
      final light = AppSemanticColors.light();
      expect(light.success, const Color(0xFF1B873F));
      expect(light.warning, const Color(0xFFB45309));
      expect(light.error, const Color(0xFFBA1A1A));
      expect(light.info, const Color(0xFF1565C0));
    });

    test('dark factory produces consistent palette', () {
      final dark = AppSemanticColors.dark();
      expect(dark.success, const Color(0xFF4ADE80));
      expect(dark.warning, const Color(0xFFFBBF24));
      expect(dark.error, const Color(0xFFFFB4AB));
      expect(dark.info, const Color(0xFF60A5FA));
    });

    test('copyWith overrides only specified fields', () {
      final original = AppSemanticColors.light();
      final patched = original.copyWith(success: const Color(0xFF00FF00));
      expect(patched.success, const Color(0xFF00FF00));
      expect(patched.warning, original.warning);
      expect(patched.error, original.error);
      expect(patched.info, original.info);
    });

    test('lerp interpolates between two extensions at t=0.5', () {
      final light = AppSemanticColors.light();
      final dark = AppSemanticColors.dark();
      final mid = light.lerp(dark, 0.5);
      expect(mid.success, Color.lerp(light.success, dark.success, 0.5));
      expect(mid.warning, Color.lerp(light.warning, dark.warning, 0.5));
    });

    test('lerp returns self when other is not AppSemanticColors', () {
      final light = AppSemanticColors.light();
      // Casting via dynamic so we can pass null without a static error;
      // lerp tolerates `null` per ThemeExtension's contract.
      // ignore: avoid_dynamic_calls
      expect(light.lerp(null, 0.5), same(light));
    });
  });

  group('AppTheme registers AppSemanticColors', () {
    test('light theme exposes light AppSemanticColors via extensions', () {
      final theme = AppTheme.light;
      final ext = theme.extension<AppSemanticColors>();
      expect(ext, isNotNull);
      expect(ext!.success, AppSemanticColors.light().success);
    });

    test('dark theme exposes dark AppSemanticColors via extensions', () {
      final theme = AppTheme.dark;
      final ext = theme.extension<AppSemanticColors>();
      expect(ext, isNotNull);
      expect(ext!.success, AppSemanticColors.dark().success);
    });
  });

  group('BuildContext.semanticColors extension', () {
    testWidgets('resolves AppSemanticColors from the surrounding Theme', (
      tester,
    ) async {
      AppSemanticColors? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              captured = context.semanticColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
      expect(captured!.success, AppSemanticColors.light().success);
    });

    testWidgets('returns dark variant when MaterialApp uses dark theme', (
      tester,
    ) async {
      AppSemanticColors? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              captured = context.semanticColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured!.success, AppSemanticColors.dark().success);
    });
  });
}
