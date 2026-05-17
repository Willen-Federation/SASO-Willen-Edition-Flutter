import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:saso_willen_edition/presentation/widgets/common/offline_indicator.dart';

void main() {
  testWidgets('Offline indicator is invisible while connectivity is unknown', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ja'), Locale('en')],
        home: Scaffold(body: Center(child: OfflineIndicator())),
      ),
    );

    // Connectivity plugin is unavailable in widget tests, so the indicator
    // initialises in the "online" state (no pictogram shown). That's the
    // expected default for a freshly-paired iPhone 17 / Pixel 7a.
    await tester.pump();
    expect(find.byIcon(Icons.cloud_off), findsNothing);
  });
}
