/// Icon-size design tokens for SASO Willen Edition.
///
/// Use these instead of `Icon(..., size: <literal>)` so icons line up
/// across list rows, app bars, empty states, and decorative tiles.
///
/// | Token   | Value  | Typical use                                  |
/// | ------- | ------ | -------------------------------------------- |
/// | small   | 16 px  | Inline icons next to text, status badges     |
/// | medium  | 24 px  | Default Material icon size (lists, buttons)  |
/// | large   | 32 px  | Section headers, prominent leading icons     |
/// | xLarge  | 40 px  | Dashboard tiles, large affordances           |
/// | xxLarge | 48 px  | Modal hero icons                             |
/// | display | 64 px  | Empty-state / error illustrations            |
abstract final class AppIconSize {
  static const double small = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;
  static const double xLarge = 40.0;
  static const double xxLarge = 48.0;
  static const double display = 64.0;
}
