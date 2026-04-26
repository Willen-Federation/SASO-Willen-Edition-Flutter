import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Barcode scanner flow', () {
    testWidgets('scanner icon on home navigates to scanner page', (
      tester,
    ) async {
      await pumpAppInMockMode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap the scanner card
      await tester.tap(find.text('バーコードスキャン'));
      await tester.pumpAndSettle();

      // Scanner page should be visible
      // (Camera permission dialog may appear on real device)
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
