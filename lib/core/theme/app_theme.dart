import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// Material 3 minimum touch target size (48 dp).
  ///
  /// Used by [IconButton] via [iconButtonTheme] to guarantee that every icon
  /// button — including those wrapped in [Badge] or sized down by ancestor
  /// padding — meets the Android accessibility baseline. iOS HIG asks for
  /// ≥44 pt, so this 48 dp value is the larger common denominator that
  /// satisfies both platforms (see issues #149 / #134).
  static const Size _minTouchTarget = Size(48, 48);

  /// Shared [IconButton] theme: enforces the 48×48 dp minimum tap region.
  static final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(minimumSize: _minTouchTarget),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    // Adapt control density to the host platform's accessibility settings
    // (e.g. Android "Display size = Larger") so touch targets scale up rather
    // than shrinking below the Material 48 dp baseline.
    visualDensity: VisualDensity.adaptivePlatformDensity,
    iconButtonTheme: _iconButtonTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    // Issue #131 — register semantic colour tokens (success / warning /
    // error / info) as a ThemeExtension so callers can read them via
    // `context.semanticColors` without scattering hardcoded Colors.green
    // etc. across the codebase.
    extensions: <ThemeExtension<dynamic>>[AppSemanticColors.light()],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    iconButtonTheme: _iconButtonTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    // Issue #131 — dark-mode variant of the semantic colour tokens.
    extensions: <ThemeExtension<dynamic>>[AppSemanticColors.dark()],
  );
}
