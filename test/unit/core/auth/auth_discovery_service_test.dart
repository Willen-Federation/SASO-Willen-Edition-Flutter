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

  test('returns legacy for empty serverUrl', () async {
    final result = await service.discover('');
    expect(result, isA<LegacyAuthConfig>());
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('returns legacy for malformed URL', () async {
    final result = await service.discover('not-a-url');
    expect(result, isA<LegacyAuthConfig>());
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('returns legacy on 404', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('Not Found', 404));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<LegacyAuthConfig>());
  });

  test('returns legacy on network exception', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenThrow(Exception('network error'));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<LegacyAuthConfig>());
  });

  test('returns legacy when server returns legacy provider', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('{"provider":"legacy"}', 200));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<LegacyAuthConfig>());
  });

  test('returns OidcAuthConfig when server returns oidc provider', () async {
    const body =
        '{"provider":"oidc","config":{"issuer":"https://sso.example.com"}}';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<OidcAuthConfig>());
    expect((result as OidcAuthConfig).issuer, 'https://sso.example.com');
  });

  test('returns FirebaseAuthConfig when server returns firebase provider', () async {
    const body = '{"provider":"firebase","config":{"projectId":"my-proj"}}';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<FirebaseAuthConfig>());
  });

  test('returns Auth0AuthConfig when server returns auth0 provider', () async {
    const body =
        '{"provider":"auth0","config":{"domain":"ex.auth0.com","clientId":"cid"}}';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<Auth0AuthConfig>());
    expect((result as Auth0AuthConfig).domain, 'ex.auth0.com');
  });

  test('returns CognitoAuthConfig when server returns cognito provider', () async {
    const body =
        '{"provider":"cognito","config":{"userPoolId":"us-east-1_X","clientId":"c","region":"us-east-1"}}';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<CognitoAuthConfig>());
  });

  test('returns SamlAuthConfig when server returns saml provider', () async {
    const body =
        '{"provider":"saml","config":{"loginUrl":"https://idp.example.com/sso"}}';
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final result = await service.discover('https://saso.example.com');
    expect(result, isA<SamlAuthConfig>());
    expect((result as SamlAuthConfig).loginUrl, 'https://idp.example.com/sso');
  });

  test('probes correct URL', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('{"provider":"legacy"}', 200));

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
