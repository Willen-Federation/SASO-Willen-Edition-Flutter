import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/auth/auth_provider_config.dart';

void main() {
  group('AuthProviderConfig.fromJson', () {
    test('parses legacy provider', () {
      final result = AuthProviderConfig.fromJson({'provider': 'legacy'});
      expect(result, isA<LegacyAuthConfig>());
    });

    test('parses oidc provider with all fields', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'oidc',
        'config': {
          'issuer': 'https://sso.example.com',
          'clientId': 'my-client',
          'extraScopes': ['offline_access'],
        },
      });
      expect(result, isA<OidcAuthConfig>());
      final oidc = result as OidcAuthConfig;
      expect(oidc.issuer, 'https://sso.example.com');
      expect(oidc.clientId, 'my-client');
      expect(oidc.extraScopes, ['offline_access']);
    });

    test('oidc uses saso-mobile as default clientId', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'oidc',
        'config': {'issuer': 'https://sso.example.com'},
      });
      expect((result as OidcAuthConfig).clientId, 'saso-mobile');
    });

    test('parses saml provider', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'saml',
        'config': {'loginUrl': 'https://idp.example.com/saml/sso'},
      });
      expect(result, isA<SamlAuthConfig>());
      expect(
        (result as SamlAuthConfig).loginUrl,
        'https://idp.example.com/saml/sso',
      );
    });

    test('parses firebase provider', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'firebase',
        'config': {'projectId': 'my-project'},
      });
      expect(result, isA<FirebaseAuthConfig>());
      expect((result as FirebaseAuthConfig).projectId, 'my-project');
    });

    test('parses auth0 provider', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'auth0',
        'config': {'domain': 'example.auth0.com', 'clientId': 'abc123'},
      });
      expect(result, isA<Auth0AuthConfig>());
      final a0 = result as Auth0AuthConfig;
      expect(a0.domain, 'example.auth0.com');
      expect(a0.clientId, 'abc123');
    });

    test('parses cognito provider with hostedUiDomain', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'cognito',
        'config': {
          'userPoolId': 'us-east-1_ABC',
          'clientId': 'cog123',
          'region': 'us-east-1',
          'hostedUiDomain': 'example.auth.us-east-1.amazoncognito.com',
        },
      });
      expect(result, isA<CognitoAuthConfig>());
      final cog = result as CognitoAuthConfig;
      expect(cog.userPoolId, 'us-east-1_ABC');
      expect(cog.clientId, 'cog123');
      expect(cog.region, 'us-east-1');
      expect(cog.hostedUiDomain, 'example.auth.us-east-1.amazoncognito.com');
    });

    test('cognito hostedUiDomain is nullable', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'cognito',
        'config': {
          'userPoolId': 'us-west-2_XYZ',
          'clientId': 'cog456',
          'region': 'us-west-2',
        },
      });
      expect((result as CognitoAuthConfig).hostedUiDomain, isNull);
    });

    test('unknown provider falls back to legacy', () {
      final result = AuthProviderConfig.fromJson({'provider': 'unknown_idp'});
      expect(result, isA<LegacyAuthConfig>());
    });

    test('missing provider field falls back to legacy', () {
      final result = AuthProviderConfig.fromJson({
        'config': <String, dynamic>{},
      });
      expect(result, isA<LegacyAuthConfig>());
    });

    test('empty JSON falls back to legacy', () {
      final result = AuthProviderConfig.fromJson({});
      expect(result, isA<LegacyAuthConfig>());
    });

    test('oidc extraScopes defaults to empty list', () {
      final result = AuthProviderConfig.fromJson({
        'provider': 'oidc',
        'config': {'issuer': 'https://sso.example.com'},
      });
      expect((result as OidcAuthConfig).extraScopes, isEmpty);
    });
  });
}
