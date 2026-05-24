// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'd17a736a9de9427b5d06ba5260920846a121ff33';

/// Returns the local credential-based auth service that talks to the
/// server's `/auth/start/` endpoint with `{id, password}`.
///
/// External providers (OIDC / SAML / Auth0 / Cognito / Firebase) are reached
/// through the server's `/m/setup` browser flow rather than a per-provider
/// native SDK, so this provider does not depend on discovery.
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
String _$serverAuthDiscoveryNotifierHash() =>
    r'e294fc87fe4802507ef6d63d997b1835e289569b';

/// Holds the latest [ServerAuthDiscovery] document received from the server.
///
/// The splash page populates this after calling [AuthDiscoveryService]; the
/// login page reads from it to decide which sections to render (credential
/// form / per-provider buttons / QR + manual token).
///
/// Copied from [ServerAuthDiscoveryNotifier].
@ProviderFor(ServerAuthDiscoveryNotifier)
final serverAuthDiscoveryNotifierProvider = AutoDisposeNotifierProvider<
  ServerAuthDiscoveryNotifier,
  ServerAuthDiscovery
>.internal(
  ServerAuthDiscoveryNotifier.new,
  name: r'serverAuthDiscoveryNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$serverAuthDiscoveryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServerAuthDiscoveryNotifier =
    AutoDisposeNotifier<ServerAuthDiscovery>;
String _$authStateNotifierHash() => r'66a0a803230c0e0fcc6d5266d3791ae8507bf437';

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
