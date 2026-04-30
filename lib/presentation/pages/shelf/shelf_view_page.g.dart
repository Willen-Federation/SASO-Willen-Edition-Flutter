// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_view_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shelfDataHash() => r'9a4fc33394d6a526c4c778ec22d76cbcfb77e790';

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

/// See also [shelfData].
@ProviderFor(shelfData)
const shelfDataProvider = ShelfDataFamily();

/// See also [shelfData].
class ShelfDataFamily
    extends Family<AsyncValue<({String label, List<Item> items})>> {
  /// See also [shelfData].
  const ShelfDataFamily();

  /// See also [shelfData].
  ShelfDataProvider call(String shelfId) {
    return ShelfDataProvider(shelfId);
  }

  @override
  ShelfDataProvider getProviderOverride(covariant ShelfDataProvider provider) {
    return call(provider.shelfId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shelfDataProvider';
}

/// See also [shelfData].
class ShelfDataProvider
    extends AutoDisposeFutureProvider<({String label, List<Item> items})> {
  /// See also [shelfData].
  ShelfDataProvider(String shelfId)
    : this._internal(
        (ref) => shelfData(ref as ShelfDataRef, shelfId),
        from: shelfDataProvider,
        name: r'shelfDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$shelfDataHash,
        dependencies: ShelfDataFamily._dependencies,
        allTransitiveDependencies: ShelfDataFamily._allTransitiveDependencies,
        shelfId: shelfId,
      );

  ShelfDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shelfId,
  }) : super.internal();

  final String shelfId;

  @override
  Override overrideWith(
    FutureOr<({String label, List<Item> items})> Function(ShelfDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShelfDataProvider._internal(
        (ref) => create(ref as ShelfDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shelfId: shelfId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<({String label, List<Item> items})>
  createElement() {
    return _ShelfDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShelfDataProvider && other.shelfId == shelfId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shelfId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShelfDataRef
    on AutoDisposeFutureProviderRef<({String label, List<Item> items})> {
  /// The parameter `shelfId` of this provider.
  String get shelfId;
}

class _ShelfDataProviderElement
    extends AutoDisposeFutureProviderElement<({String label, List<Item> items})>
    with ShelfDataRef {
  _ShelfDataProviderElement(super.provider);

  @override
  String get shelfId => (origin as ShelfDataProvider).shelfId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
