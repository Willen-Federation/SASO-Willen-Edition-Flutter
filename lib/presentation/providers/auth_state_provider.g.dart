// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'dca69043d18e3de8c4e683dc86e187cb3ccde780';

/// Selects and instantiates the appropriate [AuthService] based on the
/// currently detected provider config and server URL.
///
/// Copied from [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$authProviderConfigNotifierHash() =>
    r'a3ae664c27195ecb23534591a9626bf5a3637e56';

/// See also [AuthProviderConfigNotifier].
@ProviderFor(AuthProviderConfigNotifier)
final authProviderConfigNotifierProvider = AutoDisposeNotifierProvider<
  AuthProviderConfigNotifier,
  AuthProviderConfig
>.internal(
  AuthProviderConfigNotifier.new,
  name: r'authProviderConfigNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authProviderConfigNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthProviderConfigNotifier = AutoDisposeNotifier<AuthProviderConfig>;
String _$authStateNotifierHash() => r'6b9d5a4ac75c856301ede052fc9ee3123f4f9c46';

/// See also [AuthStateNotifier].
@ProviderFor(AuthStateNotifier)
final authStateNotifierProvider =
    AutoDisposeNotifierProvider<AuthStateNotifier, AuthState>.internal(
      AuthStateNotifier.new,
      name: r'authStateNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthStateNotifier = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
