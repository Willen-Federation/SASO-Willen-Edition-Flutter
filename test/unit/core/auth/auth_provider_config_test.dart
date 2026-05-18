import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/auth/auth_provider_config.dart';

void main() {
  group('ServerAuthDiscovery.fromJson', () {
    test('parses a minimal local-only payload', () {
      final result = ServerAuthDiscovery.fromJson({
        'serverName': 'SASO Warehouse',
        'version': '1.0.0',
        'mobileSetupUrl': 'https://saso.example.com/m/setup',
        'authStrategy': 'local-only',
        'providers': [
          {
            'id': 1,
            'name': 'Local',
            'type': 'local',
            'isDefault': true,
            'enabled': true,
          },
        ],
      });

      expect(result.serverName, 'SASO Warehouse');
      expect(result.version, '1.0.0');
      expect(result.mobileSetupUrl, 'https://saso.example.com/m/setup');
      expect(result.authStrategy, AuthStrategy.localOnly);
      expect(result.providers, hasLength(1));
      expect(result.providers.first.type, AuthProviderType.local);
      expect(result.hasLocalLogin, isTrue);
      expect(result.externalProviders, isEmpty);
    });

    test('parses default-only with one OIDC provider', () {
      final result = ServerAuthDiscovery.fromJson({
        'serverName': 'Acme',
        'version': '0.9.0',
        'mobileSetupUrl': 'https://acme.example.com/m/setup',
        'authStrategy': 'default-only',
        'providers': [
          {
            'id': 7,
            'name': 'Corporate SSO',
            'type': 'oidc',
            'isDefault': true,
            'enabled': true,
          },
        ],
      });

      expect(result.authStrategy, AuthStrategy.defaultOnly);
      expect(result.hasLocalLogin, isFalse);
      expect(result.externalProviders, hasLength(1));
      expect(result.externalProviders.first.id, 7);
      expect(result.externalProviders.first.type, AuthProviderType.oidc);
    });

    test('parses user-choice with mixed providers', () {
      final result = ServerAuthDiscovery.fromJson({
        'serverName': 'Mixed',
        'version': '1.0.0',
        'mobileSetupUrl': 'https://mixed.example.com/m/setup',
        'authStrategy': 'user-choice',
        'providers': [
          {
            'id': 1,
            'name': 'Local',
            'type': 'local',
            'isDefault': false,
            'enabled': true,
          },
          {
            'id': 2,
            'name': 'Google',
            'type': 'oidc',
            'isDefault': false,
            'enabled': true,
          },
          {
            'id': 3,
            'name': 'Disabled SAML',
            'type': 'saml',
            'isDefault': false,
            'enabled': false,
          },
        ],
      });

      expect(result.authStrategy, AuthStrategy.userChoice);
      expect(result.hasLocalLogin, isTrue);
      // Disabled providers are filtered out of externalProviders.
      expect(result.externalProviders, hasLength(1));
      expect(result.externalProviders.first.name, 'Google');
    });

    test('falls back to local-only on unknown authStrategy', () {
      final result = ServerAuthDiscovery.fromJson({
        'authStrategy': 'bogus',
        'providers': const <Map<String, dynamic>>[],
      });
      expect(result.authStrategy, AuthStrategy.localOnly);
    });

    test('unknown provider type maps to AuthProviderType.unknown', () {
      final result = ServerAuthDiscovery.fromJson({
        'providers': [
          {
            'id': 1,
            'name': 'Mystery',
            'type': 'mystery-idp',
            'isDefault': false,
            'enabled': true,
          },
        ],
      });
      expect(result.providers.first.type, AuthProviderType.unknown);
    });

    test('missing fields fall back to safe defaults', () {
      final result = ServerAuthDiscovery.fromJson(<String, dynamic>{});
      expect(result.serverName, isEmpty);
      expect(result.version, isEmpty);
      expect(result.mobileSetupUrl, isEmpty);
      expect(result.authStrategy, AuthStrategy.localOnly);
      expect(result.providers, isEmpty);
    });
  });

  group('AuthProviderType.fromWire', () {
    test('round-trips known types', () {
      expect(AuthProviderType.fromWire('local'), AuthProviderType.local);
      expect(AuthProviderType.fromWire('oidc'), AuthProviderType.oidc);
      expect(AuthProviderType.fromWire('saml'), AuthProviderType.saml);
      expect(AuthProviderType.fromWire('firebase'), AuthProviderType.firebase);
      expect(AuthProviderType.fromWire('auth0'), AuthProviderType.auth0);
      expect(AuthProviderType.fromWire('cognito'), AuthProviderType.cognito);
    });

    test('unknown strings map to unknown variant', () {
      expect(AuthProviderType.fromWire(''), AuthProviderType.unknown);
      expect(AuthProviderType.fromWire('nope'), AuthProviderType.unknown);
    });
  });
}
