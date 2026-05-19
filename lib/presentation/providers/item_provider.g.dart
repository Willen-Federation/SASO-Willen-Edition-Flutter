// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemByIdHash() => r'4f778aff6e02e14abde39822e73ca4f64a288c6c';

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
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
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

String _$itemSearchHash() => r'5909107bffcaee8b40440d3c12a003815fd91680';

/// See also [itemSearch].
@ProviderFor(itemSearch)
const itemSearchProvider = ItemSearchFamily();

/// See also [itemSearch].
class ItemSearchFamily extends Family<AsyncValue<List<Item>>> {
  /// See also [itemSearch].
  const ItemSearchFamily();

  /// See also [itemSearch].
  ItemSearchProvider call({
    String? query,
    String? categoryId,
    String? barcode,
    String? isbn,
    String? labelCode,
  }) {
    return ItemSearchProvider(
      query: query,
      categoryId: categoryId,
      barcode: barcode,
      isbn: isbn,
      labelCode: labelCode,
    );
  }

  @override
  ItemSearchProvider getProviderOverride(
    covariant ItemSearchProvider provider,
  ) {
    return call(
      query: provider.query,
      categoryId: provider.categoryId,
      barcode: provider.barcode,
      isbn: provider.isbn,
      labelCode: provider.labelCode,
    );
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
  ItemSearchProvider({
    String? query,
    String? categoryId,
    String? barcode,
    String? isbn,
    String? labelCode,
  }) : this._internal(
         (ref) => itemSearch(
           ref as ItemSearchRef,
           query: query,
           categoryId: categoryId,
           barcode: barcode,
           isbn: isbn,
           labelCode: labelCode,
         ),
         from: itemSearchProvider,
         name: r'itemSearchProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$itemSearchHash,
         dependencies: ItemSearchFamily._dependencies,
         allTransitiveDependencies: ItemSearchFamily._allTransitiveDependencies,
         query: query,
         categoryId: categoryId,
         barcode: barcode,
         isbn: isbn,
         labelCode: labelCode,
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
    required this.barcode,
    required this.isbn,
    required this.labelCode,
  }) : super.internal();

  final String? query;
  final String? categoryId;
  final String? barcode;
  final String? isbn;
  final String? labelCode;

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
        barcode: barcode,
        isbn: isbn,
        labelCode: labelCode,
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
        other.categoryId == categoryId &&
        other.barcode == barcode &&
        other.isbn == isbn &&
        other.labelCode == labelCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, barcode.hashCode);
    hash = _SystemHash.combine(hash, isbn.hashCode);
    hash = _SystemHash.combine(hash, labelCode.hashCode);

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

  /// The parameter `barcode` of this provider.
  String? get barcode;

  /// The parameter `isbn` of this provider.
  String? get isbn;

  /// The parameter `labelCode` of this provider.
  String? get labelCode;
}

class _ItemSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<Item>>
    with ItemSearchRef {
  _ItemSearchProviderElement(super.provider);

  @override
  String? get query => (origin as ItemSearchProvider).query;
  @override
  String? get categoryId => (origin as ItemSearchProvider).categoryId;
  @override
  String? get barcode => (origin as ItemSearchProvider).barcode;
  @override
  String? get isbn => (origin as ItemSearchProvider).isbn;
  @override
  String? get labelCode => (origin as ItemSearchProvider).labelCode;
}

String _$itemStatusUpdaterHash() => r'02dd3618da267e7d7dd7ab661a8561867780df99';

/// AsyncNotifier that performs status updates on the server and refreshes
/// the affected [itemByIdProvider]. The notifier itself holds no domain
/// state — its `AsyncValue<void>` simply mirrors the in-flight request so
/// callers can react to loading/error transitions.
///
/// Copied from [ItemStatusUpdater].
@ProviderFor(ItemStatusUpdater)
final itemStatusUpdaterProvider =
    AutoDisposeAsyncNotifierProvider<ItemStatusUpdater, void>.internal(
      ItemStatusUpdater.new,
      name: r'itemStatusUpdaterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itemStatusUpdaterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ItemStatusUpdater = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
