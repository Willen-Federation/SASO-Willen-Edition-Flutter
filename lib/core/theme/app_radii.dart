import 'package:flutter/widgets.dart';

/// Corner-radius design tokens for SASO Willen Edition.
///
/// Use these instead of `BorderRadius.circular(<literal>)` so cards,
/// dialogs, badges, and surfaces all share the same set of radii.
///
/// | Token | Value | Typical use                                  |
/// | ----- | ----- | -------------------------------------------- |
/// | sm    | 4 px  | Inline accents, small chips, status pills    |
/// | md    | 8 px  | Buttons, small surfaces, snackbars           |
/// | lg    | 12 px | Cards, modal sheets, banners                 |
abstract final class AppRadii {
  static const Radius sm = Radius.circular(4);
  static const Radius md = Radius.circular(8);
  static const Radius lg = Radius.circular(12);

  /// Convenience [BorderRadius] for [sm] applied to all corners.
  static const BorderRadius smAll = BorderRadius.all(sm);

  /// Convenience [BorderRadius] for [md] applied to all corners.
  static const BorderRadius mdAll = BorderRadius.all(md);

  /// Convenience [BorderRadius] for [lg] applied to all corners.
  static const BorderRadius lgAll = BorderRadius.all(lg);
}
