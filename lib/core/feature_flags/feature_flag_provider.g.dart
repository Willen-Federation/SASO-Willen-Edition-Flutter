// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$featureFlagServiceHash() =>
    r'785a2bdc9e6ff086a6051a75ff1b17811dd50e45';

/// See also [featureFlagService].
@ProviderFor(featureFlagService)
final featureFlagServiceProvider =
    AutoDisposeProvider<FeatureFlagService>.internal(
      featureFlagService,
      name: r'featureFlagServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$featureFlagServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeatureFlagServiceRef = AutoDisposeProviderRef<FeatureFlagService>;
String _$featureFlagHash() => r'5dfc0a130fc4f8eac2034a44641ef64c48c2c0dc';

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

/// Convenient typed accessor for boolean feature flags.
///
/// Copied from [featureFlag].
@ProviderFor(featureFlag)
const featureFlagProvider = FeatureFlagFamily();

/// Convenient typed accessor for boolean feature flags.
///
/// Copied from [featureFlag].
class FeatureFlagFamily extends Family<bool> {
  /// Convenient typed accessor for boolean feature flags.
  ///
  /// Copied from [featureFlag].
  const FeatureFlagFamily();

  /// Convenient typed accessor for boolean feature flags.
  ///
  /// Copied from [featureFlag].
  FeatureFlagProvider call(String key) {
    return FeatureFlagProvider(key);
  }

  @override
  FeatureFlagProvider getProviderOverride(
    covariant FeatureFlagProvider provider,
  ) {
    return call(provider.key);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'featureFlagProvider';
}

/// Convenient typed accessor for boolean feature flags.
///
/// Copied from [featureFlag].
class FeatureFlagProvider extends AutoDisposeProvider<bool> {
  /// Convenient typed accessor for boolean feature flags.
  ///
  /// Copied from [featureFlag].
  FeatureFlagProvider(String key)
    : this._internal(
        (ref) => featureFlag(ref as FeatureFlagRef, key),
        from: featureFlagProvider,
        name: r'featureFlagProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$featureFlagHash,
        dependencies: FeatureFlagFamily._dependencies,
        allTransitiveDependencies: FeatureFlagFamily._allTransitiveDependencies,
        key: key,
      );

  FeatureFlagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String key;

  @override
  Override overrideWith(bool Function(FeatureFlagRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FeatureFlagProvider._internal(
        (ref) => create(ref as FeatureFlagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _FeatureFlagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeatureFlagProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeatureFlagRef on AutoDisposeProviderRef<bool> {
  /// The parameter `key` of this provider.
  String get key;
}

class _FeatureFlagProviderElement extends AutoDisposeProviderElement<bool>
    with FeatureFlagRef {
  _FeatureFlagProviderElement(super.provider);

  @override
  String get key => (origin as FeatureFlagProvider).key;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
