import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_provider_config.freezed.dart';

/// Auth provider configuration returned by GET /api/v1/auth/providers.
///
/// The sealed union lets callers pattern-match on provider type without
/// needing a separate enum; each variant carries only the fields it needs.
@freezed
sealed class AuthProviderConfig with _$AuthProviderConfig {
  /// Traditional session-cookie login via POST /auth/start.
  const factory AuthProviderConfig.legacy() = LegacyAuthConfig;

  /// Generic OIDC / OAuth2 login via flutter_appauth.
  /// Also used for SAML-over-OIDC when the IdP exposes an OIDC discovery doc.
  const factory AuthProviderConfig.oidc({
    required String issuer,
    @Default('saso-mobile') String clientId,
    @Default(<String>[]) List<String> extraScopes,
  }) = OidcAuthConfig;

  /// SAML login using a WebView pointed at the IdP SSO URL.
  const factory AuthProviderConfig.saml({required String loginUrl}) =
      SamlAuthConfig;

  /// Firebase Authentication (email/password or federated via Firebase).
  const factory AuthProviderConfig.firebase({required String projectId}) =
      FirebaseAuthConfig;

  /// Auth0 native SDK (auth0_flutter) — Universal Login.
  const factory AuthProviderConfig.auth0({
    required String domain,
    required String clientId,
  }) = Auth0AuthConfig;

  /// Amazon Cognito native SDK (amplify_auth_cognito) — Hosted UI.
  const factory AuthProviderConfig.cognito({
    required String userPoolId,
    required String clientId,
    required String region,
    String? hostedUiDomain,
  }) = CognitoAuthConfig;

  // ---------------------------------------------------------------------------
  // JSON deserialisation — driven by the top-level "provider" discriminator
  // field; unknown values fall back to legacy.
  // ---------------------------------------------------------------------------

  static AuthProviderConfig fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as String? ?? 'legacy';
    final cfg =
        (json['config'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return switch (provider) {
      'oidc' => AuthProviderConfig.oidc(
        issuer: cfg['issuer'] as String,
        clientId: cfg['clientId'] as String? ?? 'saso-mobile',
        extraScopes:
            (cfg['extraScopes'] as List<dynamic>?)?.cast<String>().toList() ??
            const [],
      ),
      'saml' => AuthProviderConfig.saml(loginUrl: cfg['loginUrl'] as String),
      'firebase' => AuthProviderConfig.firebase(
        projectId: cfg['projectId'] as String,
      ),
      'auth0' => AuthProviderConfig.auth0(
        domain: cfg['domain'] as String,
        clientId: cfg['clientId'] as String,
      ),
      'cognito' => AuthProviderConfig.cognito(
        userPoolId: cfg['userPoolId'] as String,
        clientId: cfg['clientId'] as String,
        region: cfg['region'] as String,
        hostedUiDomain: cfg['hostedUiDomain'] as String?,
      ),
      _ => const AuthProviderConfig.legacy(),
    };
  }
}
