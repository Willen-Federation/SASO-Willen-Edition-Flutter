// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingCountHash() => r'2f7fb6a4e7f24105acf934db4224f127a0801ead';

/// Total count of pending/failed outbox items (registrations + adjustments).
///
/// Copied from [pendingCount].
@ProviderFor(pendingCount)
final pendingCountProvider = AutoDisposeFutureProvider<int>.internal(
  pendingCount,
  name: r'pendingCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pendingCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingCountRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
