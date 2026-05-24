import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
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
