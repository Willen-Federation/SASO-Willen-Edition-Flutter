import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saso_willen_edition/presentation/layout/responsive.dart';

void main() {
  Widget probe(Size size, ValueSetter<Responsive> capture) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) {
          capture(Responsive.of(context));
          return const SizedBox.shrink();
        },
      ),
    );
  }

  testWidgets('mobile size resolves to ScreenSize.mobile', (tester) async {
    Responsive? r;
    await tester.pumpWidget(probe(const Size(390, 844), (x) => r = x));
    expect(r!.size, ScreenSize.mobile);
    expect(r!.adaptiveColumns(), 2);
    expect(r!.isAtLeastTablet, isFalse);
  });

  testWidgets('tablet size resolves to ScreenSize.tablet', (tester) async {
    Responsive? r;
    await tester.pumpWidget(probe(const Size(800, 1100), (x) => r = x));
    expect(r!.size, ScreenSize.tablet);
    expect(r!.adaptiveColumns(), 4);
    expect(r!.isAtLeastTablet, isTrue);
  });

  testWidgets('desktop size resolves to ScreenSize.desktop', (tester) async {
    Responsive? r;
    await tester.pumpWidget(probe(const Size(1440, 900), (x) => r = x));
    expect(r!.size, ScreenSize.desktop);
    expect(r!.adaptiveColumns(), 6);
  });

  Widget twoPaneAt(Size size) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: const TwoPaneScaffold(
            master: Text('master'),
            detail: Text('detail'),
          ),
        ),
      );

  testWidgets('TwoPaneScaffold collapses on phones', (tester) async {
    await tester.pumpWidget(twoPaneAt(const Size(390, 844)));
    expect(find.text('master'), findsOneWidget);
    expect(find.text('detail'), findsNothing);
  });

  testWidgets('TwoPaneScaffold shows both panes on tablets', (tester) async {
    await tester.pumpWidget(twoPaneAt(const Size(1024, 1366)));
    expect(find.text('master'), findsOneWidget);
    expect(find.text('detail'), findsOneWidget);
  });
}
