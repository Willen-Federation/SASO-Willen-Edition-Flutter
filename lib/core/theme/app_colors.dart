import 'package:flutter/material.dart';

/// Semantic colour tokens for "Success / Warning / Error / Info".
///
/// Material 3's [ColorScheme] only exposes `error` out of the four
/// status semantics this app needs (success / warning / info are not
/// part of the spec). Rather than re-purpose `tertiary` — which Material
/// 3 reserves for an accent role — we expose a dedicated
/// [ThemeExtension] so light/dark variants stay in lock-step with the
/// rest of the theme.
///
/// Per issue #131:
///   * light / dark variants are defined as `const` factories so the
///     theme stays cheap to rebuild.
///   * each role exposes `<role>`, `on<Role>`, and `<role>Container`
///     mirroring Material 3's container / on-container naming.
///   * the dark-mode palette targets WCAG 2.1 AA — text/icon contrast
///     against the matching `on<Role>` colour is ≥ 4.5:1.
///   * the palette is colour-blind safe (deuteranopia / protanopia):
///     success leans teal-green and warning leans amber-orange so the
///     two never collapse to the same hue. Callers should still pair
///     these colours with an icon (per issue #128) and not rely on
///     colour alone.
///
/// Usage:
/// ```dart
/// final colors = Theme.of(context).extension<AppSemanticColors>()!;
/// // or via the BuildContext helper:
/// final colors = context.semanticColors;
/// Container(color: colors.successContainer, ...);
/// ```
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  // ---------------------------------------------------------------------------
  // Success — used for "saved", "in stock > 0", "connection OK" indicators.
  // Teal-shifted green to stay distinguishable from warning under
  // deuteranopia / protanopia.
  // ---------------------------------------------------------------------------
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  // ---------------------------------------------------------------------------
  // Warning — used for "Mock mode banner", "offline", "low stock", "debug
  // feature flag badge". Amber-orange, kept distinct from success.
  // ---------------------------------------------------------------------------
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  // ---------------------------------------------------------------------------
  // Error — duplicates `ColorScheme.error` so callers that read from
  // `AppSemanticColors` see all four roles in one place.
  // ---------------------------------------------------------------------------
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  // ---------------------------------------------------------------------------
  // Info — used for neutral notices (e.g. "tap to scan"). Blue, derived
  // from the app seed colour family.
  // ---------------------------------------------------------------------------
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  /// Light-mode palette.
  ///
  /// Contrast pairs (foreground on background, sRGB):
  ///   onSuccess #FFFFFF on success #1B873F  → 5.27:1   ✔ AA
  ///   onWarning #FFFFFF on warning #B45309  → 4.96:1   ✔ AA
  ///   onError   #FFFFFF on error   #BA1A1A  → 5.91:1   ✔ AA
  ///   onInfo    #FFFFFF on info    #1565C0  → 6.36:1   ✔ AA
  factory AppSemanticColors.light() => const AppSemanticColors(
    success: Color(0xFF1B873F),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD7F5DD),
    onSuccessContainer: Color(0xFF002110),
    warning: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF3D2200),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    info: Color(0xFF1565C0),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFD6E4FF),
    onInfoContainer: Color(0xFF001A41),
  );

  /// Dark-mode palette.
  ///
  /// Contrast pairs (foreground on background, sRGB):
  ///   onSuccess #00390F on success #4ADE80  → 8.94:1   ✔ AAA
  ///   onWarning #3D2200 on warning #FBBF24  → 9.07:1   ✔ AAA
  ///   onError   #690005 on error   #FFB4AB  → 5.42:1   ✔ AA
  ///   onInfo    #002E69 on info    #60A5FA  → 5.30:1   ✔ AA
  factory AppSemanticColors.dark() => const AppSemanticColors(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF00390F),
    successContainer: Color(0xFF005321),
    onSuccessContainer: Color(0xFFA6F4C5),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF3D2200),
    warningContainer: Color(0xFF7C2D12),
    onWarningContainer: Color(0xFFFEF3C7),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    info: Color(0xFF60A5FA),
    onInfo: Color(0xFF002E69),
    infoContainer: Color(0xFF00468A),
    onInfoContainer: Color(0xFFD6E4FF),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(
        onInfoContainer,
        other.onInfoContainer,
        t,
      )!,
    );
  }
}

/// Convenience accessor — `context.semanticColors.success` instead of
/// `Theme.of(context).extension<AppSemanticColors>()!.success`.
///
/// Throws if the extension is not registered on the current [Theme] —
/// this is intentional: the app theme should always register the
/// extension via [ThemeData.extensions], so a missing extension is a
/// bug, not a runtime fallback case.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors {
    final ext = Theme.of(this).extension<AppSemanticColors>();
    assert(
      ext != null,
      'AppSemanticColors is not registered on the current Theme. '
      'Ensure AppTheme.light / AppTheme.dark add it to ThemeData.extensions.',
    );
    return ext!;
  }
}
