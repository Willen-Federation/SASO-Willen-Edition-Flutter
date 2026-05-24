import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'text_theme.dart';

abstract final class AppTheme {
  /// Brand seed colour used to derive both the Material [ColorScheme] and
  /// the Cupertino primary tint. Centralised so light/dark/iOS variants
  /// stay aligned.
  static const Color _seedColor = Color(0xFF1565C0);

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

  /// Cupertino theme overlay applied to the Material [ThemeData].
  ///
  /// `MaterialApp` derives a default [CupertinoThemeData] from its Material
  /// theme, but the derived palette loses the brand seed colour because
  /// [ColorScheme.fromSeed] reshuffles roles for Material 3. By passing an
  /// explicit `cupertinoOverrideTheme` we make sure every Cupertino widget
  /// (`CupertinoButton`, `CupertinoSwitch`, `CupertinoAlertDialog`,
  /// `CupertinoPageRoute` swipe-back chrome, etc.) tints with the SASO
  /// brand colour instead of the Material 3 derived primary, and tracks
  /// light/dark brightness alongside the Material theme.
  static CupertinoThemeData _cupertinoOverride(Brightness brightness) {
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: _seedColor,
      // Let the rest of the palette flow from Cupertino's defaults so
      // standard iOS chrome (translucent nav bar, grouped backgrounds,
      // separator colours) stays platform-native — only the accent
      // colour is overridden.
      applyThemeToAll: true,
    );
  }

  static ThemeData get light {
    // Build the base first so we can layer Noto Sans JP on top of the
    // Material 3 typescale that ThemeData would otherwise hand us.
    // ColorScheme.fromSeed gives the M3 typography its colour roles.
    final base = ThemeData(
      useMaterial3: true,
      // Adapt control density to the host platform's accessibility settings
      // (e.g. Android "Display size = Larger") so touch targets scale up
      // rather than shrinking below the Material 48 dp baseline.
      visualDensity: VisualDensity.adaptivePlatformDensity,
      iconButtonTheme: _iconButtonTheme,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      cupertinoOverrideTheme: _cupertinoOverride(Brightness.light),
    );
    return base.copyWith(
      textTheme: AppTextTheme.resolve(base.textTheme),
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
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      iconButtonTheme: _iconButtonTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      cupertinoOverrideTheme: _cupertinoOverride(Brightness.dark),
    );
    return base.copyWith(
      textTheme: AppTextTheme.resolve(base.textTheme),
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
}
