import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/entities/item_status.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:saso_willen_edition/presentation/widgets/item/item_status_badge.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('ja')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('ja'), Locale('en')],
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('ItemStatusBadge', () {
    testWidgets('renders the localized Japanese label for each status', (
      tester,
    ) async {
      const expected = <ItemStatus, String>{
        ItemStatus.active: 'アクティブ',
        ItemStatus.archived: 'アーカイブ',
        ItemStatus.discontinued: '廃盤',
        ItemStatus.pending: '保留中',
        ItemStatus.inStorage: '保管中',
        ItemStatus.inUse: '利用中',
        ItemStatus.forSale: '販売中',
        ItemStatus.reserved: '仮押さえ',
        ItemStatus.shipped: '発送済み',
      };

      for (final entry in expected.entries) {
        await tester.pumpWidget(_wrap(ItemStatusBadge(status: entry.key)));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
      }
    });

    testWidgets('falls back to English when locale is en', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ItemStatusBadge(status: ItemStatus.forSale),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('For sale'), findsOneWidget);
    });

    testWidgets('compact mode renders with smaller typography', (tester) async {
      await tester.pumpWidget(
        _wrap(const ItemStatusBadge(status: ItemStatus.shipped, compact: true)),
      );
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.text('発送済み'));
      expect(text.style?.fontSize, 11);
    });

    // Issue #151 / #132 — TalkBack & VoiceOver must announce the badge.
    testWidgets('exposes a semantic label for screen readers', (tester) async {
      await tester.pumpWidget(
        _wrap(const ItemStatusBadge(status: ItemStatus.inUse)),
      );
      await tester.pumpAndSettle();

      // The badge wraps its content in a Semantics widget whose `label`
      // mirrors the visible status text — that's what TalkBack and
      // VoiceOver announce. We assert on the widget tree directly so
      // the test doesn't need `ensureSemantics()` (which can interact
      // unpredictably with Material's own semantic nodes).
      final node = tester.widget<Semantics>(
        find
            .ancestor(of: find.text('利用中'), matching: find.byType(Semantics))
            .first,
      );
      expect(node.properties.label, '利用中');
    });
  });
}
