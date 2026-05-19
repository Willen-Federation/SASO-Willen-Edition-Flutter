import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/domain/entities/category.dart';
import 'package:saso_willen_edition/domain/entities/item.dart';
import 'package:saso_willen_edition/domain/entities/item_status.dart';
import 'package:saso_willen_edition/domain/repositories/item_repository.dart';
import 'package:saso_willen_edition/domain/value_objects/item_id.dart';
import 'package:saso_willen_edition/presentation/providers/api_client_provider.dart';
import 'package:saso_willen_edition/presentation/providers/item_provider.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ItemId.parse('99019999'));
    registerFallbackValue(ItemStatus.active);
  });

  Item fakeItem({ItemStatus status = ItemStatus.active}) => Item(
    id: ItemId.parse('24010001'),
    name: 'テスト商品',
    category: const Category(id: 'cat001', name: 'テストカテゴリ'),
    registeredAt: DateTime(2024),
    status: status,
  );

  ProviderContainer makeContainer(ItemRepository repo) {
    return ProviderContainer(
      overrides: [itemRepositoryProvider.overrideWith((_) async => repo)],
    );
  }

  group('ItemStatusUpdater', () {
    test('changeStatus delegates to repository.updateStatus and resolves the '
        'AsyncValue with data', () async {
      final repo = _MockItemRepository();
      when(
        () => repo.updateStatus(any(), any()),
      ).thenAnswer((_) async => fakeItem(status: ItemStatus.forSale));

      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(itemStatusUpdaterProvider.notifier)
          .changeStatus('24010001', ItemStatus.forSale);

      final state = container.read(itemStatusUpdaterProvider);
      expect(state, const AsyncData<void>(null));

      final captured =
          verify(() => repo.updateStatus(captureAny(), captureAny())).captured;
      expect((captured[0] as ItemId).value, '24010001');
      expect(captured[1], ItemStatus.forSale);
    });

    test('changeStatus surfaces repository failures as AsyncError', () async {
      final repo = _MockItemRepository();
      when(() => repo.updateStatus(any(), any())).thenThrow(Exception('boom'));

      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(itemStatusUpdaterProvider.notifier)
          .changeStatus('24010001', ItemStatus.archived);

      final state = container.read(itemStatusUpdaterProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error.toString(), contains('boom'));
    });
  });
}
