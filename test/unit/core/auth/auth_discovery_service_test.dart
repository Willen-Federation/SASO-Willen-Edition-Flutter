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
    expect(
      result.externalProviders.map((p) => p.name).toList(),
      ['Google', 'Okta'],
    );
  });

  test('fills in local-only fallback when server returns empty providers', () async {
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
  });

  test('probes the correct URL', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async => http.Response(
        '{"serverName":"","version":"","mobileSetupUrl":"","authStrategy":"local-only","providers":[]}',
        200,
      ),
    );

    await service.discover('https://saso.example.com');

    final captured = verify(
      () => client.get(captureAny(), headers: captureAny(named: 'headers')),
    ).captured;
    expect(
      (captured[0] as Uri).toString(),
      'https://saso.example.com/api/v1/auth/providers',
    );
  });
}
