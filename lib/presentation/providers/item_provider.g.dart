// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemByIdHash() => r'543ac3995a09da23617ef2808ab2d81dcb168b5c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [itemById].
@ProviderFor(itemById)
const itemByIdProvider = ItemByIdFamily();

/// See also [itemById].
class ItemByIdFamily extends Family<AsyncValue<Item>> {
  /// See also [itemById].
  const ItemByIdFamily();

  /// See also [itemById].
  ItemByIdProvider call(String id) {
    return ItemByIdProvider(id);
  }

  @override
  ItemByIdProvider getProviderOverride(covariant ItemByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemByIdProvider';
}

/// See also [itemById].
class ItemByIdProvider extends AutoDisposeFutureProvider<Item> {
  /// See also [itemById].
  ItemByIdProvider(String id)
    : this._internal(
        (ref) => itemById(ref as ItemByIdRef, id),
        from: itemByIdProvider,
        name: r'itemByIdProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$itemByIdHash,
        dependencies: ItemByIdFamily._dependencies,
        allTransitiveDependencies: ItemByIdFamily._allTransitiveDependencies,
        id: id,
      );

  ItemByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(FutureOr<Item> Function(ItemByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ItemByIdProvider._internal(
        (ref) => create(ref as ItemByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Item> createElement() {
    return _ItemByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemByIdRef on AutoDisposeFutureProviderRef<Item> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ItemByIdProviderElement extends AutoDisposeFutureProviderElement<Item>
    with ItemByIdRef {
  _ItemByIdProviderElement(super.provider);

  @override
  String get id => (origin as ItemByIdProvider).id;
}

String _$itemSearchHash() => r'915cb838dbfb411aaa7f68789f7e2a2295351b52';

/// See also [itemSearch].
@ProviderFor(itemSearch)
const itemSearchProvider = ItemSearchFamily();

/// See also [itemSearch].
class ItemSearchFamily extends Family<AsyncValue<List<Item>>> {
  /// See also [itemSearch].
  const ItemSearchFamily();

  /// See also [itemSearch].
  ItemSearchProvider call({String? query, String? categoryId}) {
    return ItemSearchProvider(query: query, categoryId: categoryId);
  }

  @override
  ItemSearchProvider getProviderOverride(
    covariant ItemSearchProvider provider,
  ) {
    return call(query: provider.query, categoryId: provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemSearchProvider';
}

/// See also [itemSearch].
class ItemSearchProvider extends AutoDisposeFutureProvider<List<Item>> {
  /// See also [itemSearch].
  ItemSearchProvider({String? query, String? categoryId})
    : this._internal(
        (ref) => itemSearch(
          ref as ItemSearchRef,
          query: query,
          categoryId: categoryId,
        ),
        from: itemSearchProvider,
        name: r'itemSearchProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$itemSearchHash,
        dependencies: ItemSearchFamily._dependencies,
        allTransitiveDependencies: ItemSearchFamily._allTransitiveDependencies,
        query: query,
        categoryId: categoryId,
      );

  ItemSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.categoryId,
  }) : super.internal();

  final String? query;
  final String? categoryId;

  @override
  Override overrideWith(
    FutureOr<List<Item>> Function(ItemSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemSearchProvider._internal(
        (ref) => create(ref as ItemSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Item>> createElement() {
    return _ItemSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemSearchProvider &&
        other.query == query &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemSearchRef on AutoDisposeFutureProviderRef<List<Item>> {
  /// The parameter `query` of this provider.
  String? get query;

  /// The parameter `categoryId` of this provider.
  String? get categoryId;
}

class _ItemSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<Item>>
    with ItemSearchRef {
  _ItemSearchProviderElement(super.provider);

  @override
  String? get query => (origin as ItemSearchProvider).query;
  @override
  String? get categoryId => (origin as ItemSearchProvider).categoryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
