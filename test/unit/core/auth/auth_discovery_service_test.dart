import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/core/auth/auth_discovery_service.dart';
import 'package:saso_willen_edition/core/auth/auth_provider_config.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient client;
  late AuthDiscoveryService service;

  setUp(() {
    client = _MockHttpClient();
    service = AuthDiscoveryService(httpClient: client);
  });

  test('returns local-only sentinel for empty serverUrl', () async {
    final result = await service.discover('');
    expect(result.authStrategy, AuthStrategy.localOnly);
    expect(result.hasLocalLogin, isTrue);
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('returns local-only sentinel for malformed URL', () async {
    final result = await service.discover('not-a-url');
    expect(result.authStrategy, AuthStrategy.localOnly);
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('returns local-only fallback on 404', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('Not Found', 404));

    final result = await service.discover('https://saso.example.com');
    expect(result.authStrategy, AuthStrategy.localOnly);
    expect(result.hasLocalLogin, isTrue);
  });

  test('returns local-only fallback on network exception', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenThrow(Exception('network error'));

    final result = await service.discover('https://saso.example.com');
    expect(result.authStrategy, AuthStrategy.localOnly);
  });

  // ---------------------------------------------------------------------------
  // discoverWithOutcome — structured failure reasons
  //
  // The outcome record exposes WHY discovery fell back so admin / settings
  // surfaces can distinguish operational misconfiguration (server APP_KEY
  // missing) from genuine network or parse issues. The bare `discover()`
  // wrapper stays backward-compatible by returning just `outcome.discovery`.
  // ---------------------------------------------------------------------------

  test('outcome reports invalidUrl for empty serverUrl', () async {
    final outcome = await service.discoverWithOutcome('');
    expect(outcome.failureReason, AuthDiscoveryFailureReason.invalidUrl);
    expect(outcome.failureDetail, contains('empty'));
    expect(outcome.discovery.hasLocalLogin, isTrue);
  });

  test('outcome reports invalidUrl for malformed URL', () async {
    final outcome = await service.discoverWithOutcome('not-a-url');
    expect(outcome.failureReason, AuthDiscoveryFailureReason.invalidUrl);
    expect(outcome.failureDetail, contains('not-a-url'));
  });

  test('outcome reports networkError on http exception', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenThrow(Exception('boom'));

    final outcome = await service.discoverWithOutcome(
      'https://saso.example.com',
    );
    expect(outcome.failureReason, AuthDiscoveryFailureReason.networkError);
    expect(outcome.failureDetail, contains('boom'));
    expect(outcome.discovery.hasLocalLogin, isTrue);
  });

  test('outcome reports httpNonSuccess on 404', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('Not Found', 404));

    final outcome = await service.discoverWithOutcome(
      'https://saso.example.com',
    );
    expect(outcome.failureReason, AuthDiscoveryFailureReason.httpNonSuccess);
    expect(outcome.failureDetail, contains('404'));
  });

  test(
    'outcome reports serverMisconfigured on 500 with SASO-INFRA-9000 problem+json',
    () async {
      // The exact body shape prod returns when APP_KEY is missing — captured
      // from `curl -i https://saso.sksl.jp/api/v1/auth/providers` on the live
      // server before the repair tool ran.
      const body =
          '{"type":"https://docs.willen-federation.org/error-codes#SASO-INFRA-9000",'
          '"title":"Internal server error","status":500,'
          '"detail":"An unexpected error occurred. Reference: 9373ebfc-9dc6-452d-8e76-2c07acbaab9e.",'
          '"instance":"/api/v1/auth/providers","code":"SASO-INFRA-9000",'
          '"traceId":"9373ebfc-9dc6-452d-8e76-2c07acbaab9e"}';
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(
          body,
          500,
          headers: {'content-type': 'application/problem+json; charset=utf-8'},
        ),
      );

      final outcome = await service.discoverWithOutcome(
        'https://saso.example.com',
      );
      expect(
        outcome.failureReason,
        AuthDiscoveryFailureReason.serverMisconfigured,
      );
      expect(outcome.failureDetail, contains('SASO-INFRA-9000'));
      expect(outcome.failureDetail, contains('9373ebfc'));
      // Critically: even though the server is broken, the credential form
      // still renders via the local-only fallback.
      expect(outcome.discovery.hasLocalLogin, isTrue);
    },
  );

  test(
    'outcome reports httpNonSuccess (not misconfigured) on plain 500 with HTML body',
    () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(
          '<html><body>Server Error</body></html>',
          500,
          headers: {'content-type': 'text/html; charset=utf-8'},
        ),
      );

      final outcome = await service.discoverWithOutcome(
        'https://saso.example.com',
      );
      // Plain 500 without the problem+json content-type is treated as a
      // generic upstream failure — we don't assume it's the APP_KEY issue.
      expect(outcome.failureReason, AuthDiscoveryFailureReason.httpNonSuccess);
      expect(outcome.failureDetail, contains('500'));
    },
  );

  test(
    'outcome reports httpNonSuccess on 500 with problem+json but different code',
    () async {
      // e.g. SASO-INFRA-9001 (DB readiness) — different operational issue,
      // not the APP_KEY one. Should NOT be mis-categorised as misconfigured.
      const body =
          '{"type":"https://docs.willen-federation.org/error-codes#SASO-INFRA-9001",'
          '"title":"Database not ready","status":500,'
          '"code":"SASO-INFRA-9001","traceId":"abc"}';
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(
          body,
          500,
          headers: {'content-type': 'application/problem+json'},
        ),
      );

      final outcome = await service.discoverWithOutcome(
        'https://saso.example.com',
      );
      expect(outcome.failureReason, AuthDiscoveryFailureReason.httpNonSuccess);
    },
  );

  test('outcome reports parseError on 200 with malformed JSON', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('not valid json {{{', 200));

    final outcome = await service.discoverWithOutcome(
      'https://saso.example.com',
    );
    expect(outcome.failureReason, AuthDiscoveryFailureReason.parseError);
    expect(outcome.discovery.hasLocalLogin, isTrue);
  });

  test('outcome reports none on successful discovery', () async {
    const body = '''
{
  "serverName": "Acme",
  "version": "1.2.3",
  "mobileSetupUrl": "https://acme.example.com/m/setup",
  "authStrategy": "user-choice",
  "providers": [
    {"id":1, "name":"Local", "type":"local", "isDefault":false, "enabled":true},
    {"id":2, "name":"Google", "type":"oidc", "isDefault":false, "enabled":true}
  ]
}''';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final outcome = await service.discoverWithOutcome(
      'https://acme.example.com',
    );
    expect(outcome.failureReason, AuthDiscoveryFailureReason.none);
    expect(outcome.failureDetail, isNull);
    expect(outcome.discovery.externalProviders, hasLength(1));
  });

  test(
    'outcome reports none when server replies 200 with empty providers',
    () async {
      const body =
          '{"serverName":"","version":"","mobileSetupUrl":"",'
          '"authStrategy":"user-choice","providers":[]}';
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(body, 200));

      final outcome = await service.discoverWithOutcome(
        'https://saso.example.com',
      );
      // Empty-providers fallback is the *successful* shape — the server
      // explicitly said "no providers configured", we render local-only.
      // This is not a discovery failure.
      expect(outcome.failureReason, AuthDiscoveryFailureReason.none);
      expect(outcome.discovery.hasLocalLogin, isTrue);
    },
  );

  test('parses local-only discovery document', () async {
    const body = '''
{
  "serverName": "SASO",
  "version": "1.0.0",
  "mobileSetupUrl": "https://saso.example.com/m/setup",
  "authStrategy": "local-only",
  "providers": [
    {"id":1, "name":"Local", "type":"local", "isDefault":true, "enabled":true}
  ]
}''';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://saso.example.com');
    expect(result.serverName, 'SASO');
    expect(result.authStrategy, AuthStrategy.localOnly);
    expect(result.hasLocalLogin, isTrue);
    expect(result.externalProviders, isEmpty);
  });

  test('parses user-choice discovery with multiple providers', () async {
    const body = '''
{
  "serverName": "Acme",
  "version": "1.2.3",
  "mobileSetupUrl": "https://acme.example.com/m/setup",
  "authStrategy": "user-choice",
  "providers": [
    {"id":1, "name":"Local", "type":"local", "isDefault":false, "enabled":true},
    {"id":2, "name":"Google", "type":"oidc", "isDefault":false, "enabled":true},
    {"id":3, "name":"Okta", "type":"saml", "isDefault":false, "enabled":true}
  ]
}''';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://acme.example.com');
    expect(result.authStrategy, AuthStrategy.userChoice);
    expect(result.hasLocalLogin, isTrue);
    expect(result.externalProviders, hasLength(2));
    expect(result.externalProviders.map((p) => p.name).toList(), [
      'Google',
      'Okta',
    ]);
  });

  test(
    'fills in local-only fallback when server returns empty providers',
    () async {
      const body = '''
{
  "serverName": "",
  "version": "",
  "mobileSetupUrl": "",
  "authStrategy": "user-choice",
  "providers": []
}''';
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(body, 200));

      final result = await service.discover('https://saso.example.com');
      expect(result.hasLocalLogin, isTrue);
      expect(result.authStrategy, AuthStrategy.localOnly);
    },
  );

  test('probes the correct URL', () async {
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
      (_) async => http.Response(
        '{"serverName":"","version":"","mobileSetupUrl":"","authStrategy":"local-only","providers":[]}',
        200,
      ),
    );

    await service.discover('https://saso.example.com');

    final captured =
        verify(
          () => client.get(captureAny(), headers: captureAny(named: 'headers')),
        ).captured;
    expect(
      (captured[0] as Uri).toString(),
      'https://saso.example.com/api/v1/auth/providers',
    );
  });
}
