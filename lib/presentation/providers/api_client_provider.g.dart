// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sasoApiClientHash() => r'c2001fe9233574389e26bd477db6bd716b7bb44e';

/// See also [sasoApiClient].
@ProviderFor(sasoApiClient)
final sasoApiClientProvider = AutoDisposeProvider<SasoApiClient>.internal(
  sasoApiClient,
  name: r'sasoApiClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sasoApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SasoApiClientRef = AutoDisposeProviderRef<SasoApiClient>;
String _$itemRepositoryHash() => r'8967cffd9d42dac5b2187dd90adc35f099e613f2';

/// See also [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider =
    AutoDisposeFutureProvider<ItemRepository>.internal(
      itemRepository,
      name: r'itemRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$itemRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemRepositoryRef = AutoDisposeFutureProviderRef<ItemRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
