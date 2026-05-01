import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:saso_willen_edition/data/datasources/remote/discovery_api_client.dart';

void main() {
  group('DiscoveryApiClient.discover', () {
    test('parses 200 response', () async {
      late Uri seenUri;
      final mock = MockClient((req) async {
        seenUri = req.url;
        return http.Response(
          jsonEncode({
            'serverName': 'SASO Test',
            'version': '1.0.0',
            'mobileSetupUrl': 'https://saso.example.com/m/setup',
            'authStrategy': 'default-only',
            'providers': [
              {
                'id': 1,
                'name': 'Auth0',
                'type': 'oidc',
                'isDefault': true,
                'enabled': true,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = DiscoveryApiClient(httpClient: mock);
      final result = await client.discover('saso.example.com');

      expect(seenUri.toString(),
          'https://saso.example.com/api/v1/mobile/discovery');
      expect(result.serverName, 'SASO Test');
      expect(result.authStrategy, 'default-only');
      expect(result.providers, hasLength(1));
      expect(result.providers.first.name, 'Auth0');
    });

    test('rejects http:// for public hosts', () async {
      final mock = MockClient((_) async => http.Response('{}', 200));
      final client = DiscoveryApiClient(httpClient: mock);

      expect(
        () => client.discover('http://saso.example.com'),
        throwsA(isA<DiscoveryFailure>().having(
          (e) => e.kind, 'kind', DiscoveryFailureKind.invalidUrl,
        )),
      );
    });

    test('allows http:// for localhost', () async {
      late Uri seenUri;
      final mock = MockClient((req) async {
        seenUri = req.url;
        return http.Response(
          jsonEncode({
            'serverName': 'dev',
            'version': '0',
            'mobileSetupUrl': 'http://localhost:8080/m/setup',
            'authStrategy': 'local-only',
            'providers': <Map<String, dynamic>>[],
          }),
          200,
        );
      });
      final client = DiscoveryApiClient(httpClient: mock);
      final result = await client.discover('http://localhost:8080');

      expect(seenUri.scheme, 'http');
      expect(result.authStrategy, 'local-only');
    });

    test('reports unreachable on connection error', () async {
      final mock = MockClient((_) => throw const FakeSocketException('boom'));
      final client = DiscoveryApiClient(httpClient: mock);
      expect(
        () => client.discover('https://saso.example.com'),
        throwsA(isA<DiscoveryFailure>().having(
          (e) => e.kind, 'kind', DiscoveryFailureKind.unreachable,
        )),
      );
    });

    test('reports wrongServer on non-200', () async {
      final mock = MockClient((_) async => http.Response('not found', 404));
      final client = DiscoveryApiClient(httpClient: mock);
      expect(
        () => client.discover('https://saso.example.com'),
        throwsA(isA<DiscoveryFailure>().having(
          (e) => e.kind, 'kind', DiscoveryFailureKind.wrongServer,
        )),
      );
    });

    test('rejects empty input', () async {
      final mock = MockClient((_) async => http.Response('{}', 200));
      final client = DiscoveryApiClient(httpClient: mock);
      expect(
        () => client.discover('   '),
        throwsA(isA<DiscoveryFailure>().having(
          (e) => e.kind, 'kind', DiscoveryFailureKind.invalidUrl,
        )),
      );
    });
  });
}

class FakeSocketException implements Exception {
  const FakeSocketException(this.message);
  final String message;
  @override
  String toString() => 'SocketException: $message';
}
