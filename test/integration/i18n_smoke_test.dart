import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';

void main() {
  Future<void> pumpForLocale(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja'), Locale('en')],
        home: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx)!;
            return Scaffold(
              body: Column(
                children: [
                  Text(l10n.qrPairingTitle),
                  Text(l10n.qrPairingInProgress),
                  Text(l10n.qrPairingInstruction),
                  Text(l10n.qrPairingNoServerUrl),
                  Text(l10n.settingsSaved),
                  Text(l10n.offlineBadge),
                  Text(l10n.manageDevicesOnWeb),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Japanese locale renders JA strings', (tester) async {
    await pumpForLocale(tester, const Locale('ja'));
    expect(find.text('QRペアリング'), findsOneWidget);
    expect(find.text('ペアリング中...'), findsOneWidget);
    expect(find.text('オフライン'), findsOneWidget);
    expect(find.text('ペアリング端末をブラウザで管理'), findsOneWidget);
  });

  testWidgets('English locale renders EN strings', (tester) async {
    await pumpForLocale(tester, const Locale('en'));
    expect(find.text('QR Pairing'), findsOneWidget);
    expect(find.text('Pairing...'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Manage paired devices on web'), findsOneWidget);
  });
}
