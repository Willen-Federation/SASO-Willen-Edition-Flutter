import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_provider_config.freezed.dart';

// ===========================================================================
// Server discovery payload — `GET /api/v1/auth/providers`
// ===========================================================================
//
// The server returns a document describing every enabled login mechanism in
// one shot (see openapi.yaml `AuthProviderDiscovery`):
//
//   {
//     "serverName": "SASO Warehouse",
//     "version": "1.0.0-alpha",
//     "mobileSetupUrl": "https://saso.example.com/m/setup",
//     "authStrategy": "user-choice",
//     "providers": [
//       {"id": 1, "name": "Local", "type": "local", "isDefault": true, "enabled": true},
//       {"id": 2, "name": "Corporate SSO", "type": "oidc", "isDefault": false, "enabled": true},
//       {
//         "id": 3, "name": "Auth0", "type": "auth0",
//         "isDefault": false, "enabled": true,
//         "config": {"domain": "tenant.auth0.com", "clientId": "abc123"}
//       }
//     ]
//   }
//
// `config` is an optional per-provider map of public identifiers (non-secret).
// Auth0 needs `domain` + `clientId` so the native SDK can drive Universal
// Login. Without those values the client cannot render an Auth0 button.
//
// The Flutter login page consumes this and renders three independent
// sections: a credential form (when `local` is present), one button per
// non-local provider (that delegates to the server's `/m/setup` flow), and
// the QR/manual token panel (always available).

/// How the server expects the client to present the chooser.
enum AuthStrategy {
  /// No external IdPs configured — username/password only.
  localOnly,

  /// Exactly one IdP marked default — the client may skip the chooser.
  defaultOnly,

  /// Multiple IdPs configured — render a chooser screen.
  userChoice,
}

AuthStrategy _strategyFromWire(String? raw) => switch (raw) {
  'local-only' => AuthStrategy.localOnly,
  'default-only' => AuthStrategy.defaultOnly,
  'user-choice' => AuthStrategy.userChoice,
  _ => AuthStrategy.localOnly,
};

/// Provider kind reported by the server's discovery payload.
///
/// `local` is the built-in username/password flow (POST `/auth/start`).
/// Everything else is a third-party IdP reached through the server's
/// `/m/setup?provider_id=…` browser flow — the client does not embed
/// per-provider OAuth / SAML config and never sees the client secret.
enum AuthProviderType {
  local,
  oidc,
  saml,
  firebase,
  auth0,
  cognito,
  unknown;

  static AuthProviderType fromWire(String raw) => switch (raw) {
    'local' => AuthProviderType.local,
    'oidc' => AuthProviderType.oidc,
    'saml' => AuthProviderType.saml,
    'firebase' => AuthProviderType.firebase,
    'auth0' => AuthProviderType.auth0,
    'cognito' => AuthProviderType.cognito,
    _ => AuthProviderType.unknown,
  };
}

@freezed
abstract class AuthProviderSummary with _$AuthProviderSummary {
  const factory AuthProviderSummary({
    required int id,
    required String name,
    required AuthProviderType type,
    required bool isDefault,
    required bool enabled,
    // Per-provider public config (e.g. Auth0 `domain` / `clientId`). Only
    // non-secret identifiers belong here — secrets stay on the server.
    @Default(<String, String>{}) Map<String, String> config,
  }) = _AuthProviderSummary;
}

@freezed
abstract class ServerAuthDiscovery with _$ServerAuthDiscovery {
  const factory ServerAuthDiscovery({
    @Default('') String serverName,
    @Default('') String version,
    @Default('') String mobileSetupUrl,
    @Default(AuthStrategy.localOnly) AuthStrategy authStrategy,
    @Default(<AuthProviderSummary>[]) List<AuthProviderSummary> providers,
  }) = _ServerAuthDiscovery;

  /// Used when discovery has not yet run, or failed — only the built-in
  /// local login is offered so the user can still authenticate against a
  /// server that doesn't expose `/api/v1/auth/providers`.
  static const ServerAuthDiscovery localOnly = ServerAuthDiscovery(
    providers: [
      AuthProviderSummary(
        id: 0,
        name: 'Local',
        type: AuthProviderType.local,
        isDefault: true,
        enabled: true,
      ),
    ],
  );

  static ServerAuthDiscovery fromJson(Map<String, dynamic> json) {
    final rawProviders = (json['providers'] as List?) ?? const [];
    final providers = <AuthProviderSummary>[];
    for (final entry in rawProviders) {
      if (entry is! Map) continue;
      final map = entry.cast<String, dynamic>();
      final rawConfig = map['config'];
      final config = <String, String>{};
      if (rawConfig is Map) {
        for (final e in rawConfig.entries) {
          final v = e.value;
          if (v is String && v.isNotEmpty) config[e.key.toString()] = v;
        }
      }
      providers.add(
        AuthProviderSummary(
          id: (map['id'] as num?)?.toInt() ?? 0,
          name: (map['name'] as String?) ?? '',
          type: AuthProviderType.fromWire((map['type'] as String?) ?? ''),
          isDefault: (map['isDefault'] as bool?) ?? false,
          enabled: (map['enabled'] as bool?) ?? false,
          config: config,
        ),
      );
    }
    return ServerAuthDiscovery(
      serverName: (json['serverName'] as String?) ?? '',
      version: (json['version'] as String?) ?? '',
      mobileSetupUrl: (json['mobileSetupUrl'] as String?) ?? '',
      authStrategy: _strategyFromWire(json['authStrategy'] as String?),
      providers: providers,
    );
  }
}

extension ServerAuthDiscoveryX on ServerAuthDiscovery {
  /// True when the server exposes the built-in username/password login.
  bool get hasLocalLogin =>
      providers.any((p) => p.enabled && p.type == AuthProviderType.local);

  /// Enabled non-local providers excluding Auth0 (which has its own
  /// dedicated branded button rendered separately via [auth0Provider]).
  List<AuthProviderSummary> get externalProviders => providers
      .where(
        (p) =>
            p.enabled &&
            p.type != AuthProviderType.local &&
            p.type != AuthProviderType.auth0,
      )
      .toList(growable: false);

  /// The first enabled Auth0 provider that also carries the public
  /// `domain` + `clientId` config the native SDK needs. Returns null
  /// when Auth0 is absent, disabled, or misconfigured — callers should
  /// treat null as "do not render an Auth0 button" to honour the
  /// "no server signal → no button" contract.
  AuthProviderSummary? get auth0Provider {
    for (final p in providers) {
      if (p.enabled && p.isAuth0Ready) return p;
    }
    return null;
  }
}

extension AuthProviderSummaryAuth0X on AuthProviderSummary {
  bool get isAuth0Ready =>
      type == AuthProviderType.auth0 &&
      (config['domain']?.isNotEmpty ?? false) &&
      (config['clientId']?.isNotEmpty ?? false);

  String? get auth0Domain =>
      type == AuthProviderType.auth0 ? config['domain'] : null;

  String? get auth0ClientId =>
      type == AuthProviderType.auth0 ? config['clientId'] : null;
}

// ===========================================================================
// Legacy per-provider config (still used by native-SDK auth services)
// ===========================================================================
//
// Pre-discovery code paths (OidcAuthService, FirebaseAuthService, …) take
// a typed config object so they know which issuer / clientId / region to
// pass to their underlying SDK. Discovery no longer constructs these
// (secrets aren't exposed), but the types are retained so the native
// services keep compiling for cases where they're wired up manually.

/// Auth provider configuration consumed by native-SDK auth services.
///
/// The sealed union lets each service pattern-match on its variant without
/// a separate enum. New code should prefer [ServerAuthDiscovery] above —
/// this union exists for the in-app SDK paths only.
@freezed
sealed class AuthProviderConfig with _$AuthProviderConfig {
  const factory AuthProviderConfig.legacy() = LegacyAuthConfig;

  const factory AuthProviderConfig.oidc({
    required String issuer,
    @Default('saso-mobile') String clientId,
    @Default(<String>[]) List<String> extraScopes,
  }) = OidcAuthConfig;

  const factory AuthProviderConfig.saml({required String loginUrl}) =
      SamlAuthConfig;

  const factory AuthProviderConfig.firebase({required String projectId}) =
      FirebaseAuthConfig;

  const factory AuthProviderConfig.auth0({
    required String domain,
    required String clientId,
  }) = Auth0AuthConfig;

  const factory AuthProviderConfig.cognito({
    required String userPoolId,
    required String clientId,
    required String region,
    String? hostedUiDomain,
  }) = CognitoAuthConfig;
}
