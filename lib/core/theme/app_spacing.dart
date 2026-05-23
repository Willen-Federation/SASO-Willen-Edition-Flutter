/// Spacing design tokens for SASO Willen Edition.
///
/// Follows the Material 3 / Apple HIG 8-pt grid recommendation so the UI
/// keeps a consistent visual rhythm. Use these instead of literal numbers
/// in `EdgeInsets.*`, `SizedBox`, `Padding`, grid spacing, etc.
///
/// | Token | Value | Typical use                                              |
/// | ----- | ----- | -------------------------------------------------------- |
/// | xs    | 4.0   | Tight inline gaps (icon ↔ label, chip rows)              |
/// | sm    | 8.0   | Default vertical rhythm between related controls         |
/// | md    | 16.0  | Standard page / card padding                             |
/// | lg    | 24.0  | Section padding, large card padding                      |
/// | xl    | 32.0  | Empty-state padding, hero spacing                        |
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
