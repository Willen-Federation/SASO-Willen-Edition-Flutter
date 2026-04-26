import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App launch', () {
    testWidgets('starts on splash page then navigates to home', (tester) async {
      await pumpAppInMockMode(tester);

      // Splash page loads
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsAny);

      // Auto-navigates to home after splash
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('search_fab')), findsOneWidget);
    });

    testWidgets('home page shows mock mode banner', (tester) async {
      await pumpAppInMockMode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.textContaining('モックモード'), findsOneWidget);
    });
  });
}
