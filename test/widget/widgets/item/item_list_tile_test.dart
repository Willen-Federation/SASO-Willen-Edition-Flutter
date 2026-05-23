import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/domain/entities/category.dart';
import 'package:saso_willen_edition/domain/entities/item.dart';
import 'package:saso_willen_edition/domain/value_objects/item_id.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:saso_willen_edition/presentation/widgets/item/item_list_tile.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('ja'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('ja'), Locale('en')],
  home: Scaffold(body: child),
);

Item _fakeItem() => Item(
  id: ItemId.parse('25010001'),
  name: 'テストアイテム',
  category: const Category(id: 'cat1', name: 'カテゴリ'),
  registeredAt: DateTime(2025, 6),
);

/// Locate the explicit `Semantics(label: ...)` wrapper that ItemListTile
/// installs around its `Card`. There are many other implicit Semantics
/// nodes in the widget tree (ListTile, Card, InkWell etc.); we want the
/// one with a non-null label that starts with the item name.
Semantics _outerSemantics(WidgetTester tester) =>
    tester.widgetList<Semantics>(find.byType(Semantics)).firstWhere(
      (s) =>
          s.properties.label != null &&
          s.properties.label!.startsWith('テストアイテム'),
    );

void main() {
  group('ItemListTile semantics (Issue #151 / #132)', () {
    testWidgets(
      'announces a combined name + status label for screen readers',
      (tester) async {
        await tester.pumpWidget(
          _wrap(ItemListTile(item: _fakeItem(), onTap: () {})),
        );
        await tester.pumpAndSettle();

        // The composed semantic label is one continuous utterance so
        // TalkBack/VoiceOver don't read fragments separately.
        final node = _outerSemantics(tester);
        expect(
          node.properties.label,
          startsWith('テストアイテム, 0 バリエーション, 在庫 0,'),
        );
        expect(node.properties.button, isTrue);
      },
    );

    testWidgets('label is still announced when onTap is null', (tester) async {
      await tester.pumpWidget(_wrap(ItemListTile(item: _fakeItem())));
      await tester.pumpAndSettle();

      // Even read-only tiles announce their name + state so a screen
      // reader user can navigate the list, but they don't claim
      // `button: true` because there's no tap to invoke.
      final node = _outerSemantics(tester);
      expect(node.properties.label, startsWith('テストアイテム,'));
      expect(node.properties.button, isFalse);
    });
  });
}
