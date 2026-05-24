import 'package:flutter/material.dart';

/// Screen-width breakpoints used across the app.
///
/// Phones are below [mobile]; tablets sit between [mobile] and [desktop];
/// desktops/web exceed [desktop]. The thresholds match the Material 3
/// window size class boundaries (compact / medium+expanded / large+).
///
/// See: https://m3.material.io/foundations/layout/applying-layout/window-size-classes
class Breakpoints {
  const Breakpoints._();

  /// Below this width: compact (phones, foldable closed).
  static const double mobile = 600;

  /// At or above this width but below [desktop]: medium / expanded
  /// (tablets in portrait, foldable unfolded, large phones in landscape).
  static const double tablet = 840;

  /// At or above this width: large / extra-large (desktop, large tablets in
  /// landscape).
  static const double desktop = 1200;
}

enum ScreenSize { mobile, tablet, desktop }

/// Resolves [ScreenSize] from the current [BuildContext] and exposes helpers
/// such as [adaptiveColumns] for grid layouts and [maxContentWidth] for
/// centred-card layouts.
class Responsive {
  const Responsive._(this.size, this.width);

  final ScreenSize size;
  final double width;

  static Responsive of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.desktop) return Responsive._(ScreenSize.desktop, w);
    if (w >= Breakpoints.mobile) return Responsive._(ScreenSize.tablet, w);
    return Responsive._(ScreenSize.mobile, w);
  }

  bool get isMobile => size == ScreenSize.mobile;
  bool get isTablet => size == ScreenSize.tablet;
  bool get isDesktop => size == ScreenSize.desktop;
  bool get isAtLeastTablet => !isMobile;

  int adaptiveColumns({int mobile = 2, int tablet = 4, int desktop = 6}) =>
      switch (size) {
        ScreenSize.mobile => mobile,
        ScreenSize.tablet => tablet,
        ScreenSize.desktop => desktop,
      };

  double maxContentWidth({
    double mobile = double.infinity,
    double tablet = 640,
    double desktop = 800,
  }) => switch (size) {
    ScreenSize.mobile => mobile,
    ScreenSize.tablet => tablet,
    ScreenSize.desktop => desktop,
  };
}

/// Centres its [child] within a column whose width is capped to
/// [maxWidth]. On phones the cap defaults to infinity (full bleed).
class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final cap = maxWidth ?? r.maxContentWidth();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Master/detail layout that collapses to a single pane on phones.
///
/// On tablets and desktops the [master] is shown on the left at a fixed width
/// while [detail] fills the remaining space. On phones only [master] is shown
/// — callers should push [detail] onto the navigator instead.
class TwoPaneScaffold extends StatelessWidget {
  const TwoPaneScaffold({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 360,
    this.appBar,
  });

  final Widget master;
  final Widget detail;
  final double masterWidth;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    if (!r.isAtLeastTablet) {
      return Scaffold(appBar: appBar, body: master);
    }
    return Scaffold(
      appBar: appBar,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: masterWidth, child: master),
          const VerticalDivider(width: 1),
          Expanded(child: detail),
        ],
      ),
    );
  }
}
