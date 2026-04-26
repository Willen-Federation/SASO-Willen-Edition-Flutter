import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Item lookup flow', () {
    testWidgets('search FAB opens search page', (tester) async {
      await pumpAppInMockMode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('search_fab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_field')), findsOneWidget);
    });

    testWidgets('typing item ID in search field shows results', (tester) async {
      await pumpAppInMockMode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('search_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_field')), 'ネジ');
      // Tap search icon to submit
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsAny);
    });

    testWidgets('entering 8-digit ID navigates directly to detail', (
      tester,
    ) async {
      await pumpAppInMockMode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key('search_fab')));
      await tester.pumpAndSettle();

      // Enter a valid 8-digit item ID from mock data and submit
      await tester.enterText(find.byKey(const Key('search_field')), '26040001');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('item_name')), findsOneWidget);
    });
  });
}
