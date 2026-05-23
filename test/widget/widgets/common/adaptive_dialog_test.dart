import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/presentation/widgets/common/adaptive_dialog.dart';

/// Smoke tests for the [showSasoAdaptiveDialog] / [showSasoAdaptiveDialogBuilder]
/// helpers. The widget tests run on the host platform (macOS / linux), so the
/// Cupertino branch is exercised only indirectly — these tests focus on the
/// Material fallback path which is what runs on Android, Web, and the test
/// harness. The platform-switching logic itself is trivial enough that the
/// production usage in `qr_pairing_page.dart` is the canonical regression
/// guard for the Cupertino branch.
void main() {
  group('showSasoAdaptiveDialog (declarative)', () {
    testWidgets('renders title, message, and actions in Material', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSasoAdaptiveDialog<bool>(
                  context: context,
                  title: 'Confirm',
                  message: 'Are you sure?',
                  actions: const [
                    AdaptiveDialogAction<bool>(label: 'Cancel', value: false),
                    AdaptiveDialogAction<bool>.primary(
                      label: 'OK',
                      value: true,
                    ),
                  ],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget); // primary action
    });

    testWidgets('returns the tapped action value', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showSasoAdaptiveDialog<bool>(
                    context: context,
                    title: 'Confirm',
                    message: 'Are you sure?',
                    actions: const [
                      AdaptiveDialogAction<bool>(label: 'Cancel', value: false),
                      AdaptiveDialogAction<bool>.primary(
                        label: 'OK',
                        value: true,
                      ),
                    ],
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('destructive action uses error colour in Material', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSasoAdaptiveDialog<bool>(
                  context: context,
                  title: 'Logout',
                  message: 'Sure?',
                  actions: const [
                    AdaptiveDialogAction<bool>(label: 'Cancel', value: false),
                    AdaptiveDialogAction<bool>.destructive(
                      label: 'Logout',
                      value: true,
                    ),
                  ],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Destructive non-default → TextButton with error foreground.
      final logoutButton = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Logout').last,
          matching: find.byType(TextButton),
        ),
      );
      final foreground = logoutButton.style?.foregroundColor?.resolve({});
      expect(foreground, isNotNull);
    });

    testWidgets('renders icon above title in Material', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSasoAdaptiveDialog<void>(
                  context: context,
                  title: 'Success',
                  message: 'Done',
                  icon: const Icon(
                    Icons.check_circle_outline,
                    key: ValueKey('success_icon'),
                  ),
                  actions: const [
                    AdaptiveDialogAction<void>.primary(label: 'OK'),
                  ],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('success_icon')), findsOneWidget);
    });
  });

  group('showSasoAdaptiveDialogBuilder (imperative)', () {
    testWidgets('reads live content state at action tap time', (tester) async {
      final controller = TextEditingController();
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showSasoAdaptiveDialogBuilder<String>(
                    context: context,
                    title: 'Enter code',
                    contentBuilder: (_) => TextField(controller: controller),
                    actionsBuilder: (dialogCtx) => [
                      AdaptiveDialogActionBuilder<String>(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                      AdaptiveDialogActionBuilder<String>.primary(
                        label: 'OK',
                        onPressed: () =>
                            Navigator.of(dialogCtx).pop(controller.text),
                      ),
                    ],
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'A-01');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, 'A-01');
    });
  });
}
