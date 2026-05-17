import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient client;

  setUp(() {
    client = _MockHttpClient();
  });

  Map<String, dynamic> itemJson(String id) => {
    'id': id,
    'name': 'sample',
    'categoryId': '1',
    'registeredAt': '2026-01-01T00:00:00Z',
  };

  test('fetchItem retries once with a refreshed token after a 401', () async {
    final calls = <String>[];
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((
      invocation,
    ) async {
      final headers =
          invocation.namedArguments[#headers] as Map<String, String>;
      final auth = headers['Authorization'] ?? '';
      calls.add(auth);
      if (auth == 'Bearer expired') {
        return http.Response('{}', 401);
      }
      return http.Response(jsonEncode(itemJson('I1')), 200);
    });

    when(
      () => client.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode({
          'access_token': 'fresh',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'refresh_token': 'r2',
          'device_id': 42,
          'device_name': 'test-device',
          'expires_at': '2099-01-01T00:00:00Z',
        }),
        200,
      ),
    );

    String? rotatedAccess;
    String? rotatedRefresh;
    final api = RestV1ApiClient(
      serverUrl: 'https://saso.example.com',
      jwtToken: 'expired',
      refreshToken: 'r1',
      onTokenRefreshed: ({required accessToken, required refreshToken}) {
        rotatedAccess = accessToken;
        rotatedRefresh = refreshToken;
      },
      httpClient: client,
    );

    final item = await api.fetchItem('I1');

    expect(item.id, 'I1');
    expect(calls, ['Bearer expired', 'Bearer fresh']);
    expect(api.jwtToken, 'fresh');
    expect(rotatedAccess, 'fresh');
    expect(rotatedRefresh, 'r2');
  });

  test(
    'fetchItem surfaces the 401 when no refresh token is configured',
    () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{}', 401));

      final api = RestV1ApiClient(
        serverUrl: 'https://saso.example.com',
        jwtToken: 'expired',
        httpClient: client,
      );

      expect(() => api.fetchItem('I1'), throwsA(isA<Object>()));
      verify(() => client.get(any(), headers: any(named: 'headers'))).called(1);
    },
  );

  test(
    'fetchItem surfaces the original 401 when refresh itself fails',
    () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{}', 401));
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{}', 401));

      var refreshCallbackCalled = false;
      final api = RestV1ApiClient(
        serverUrl: 'https://saso.example.com',
        jwtToken: 'expired',
        refreshToken: 'r1',
        onTokenRefreshed: ({required accessToken, required refreshToken}) {
          refreshCallbackCalled = true;
        },
        httpClient: client,
      );

      expect(() => api.fetchItem('I1'), throwsA(isA<Object>()));
      // The refresh endpoint was called but threw via _handleErrors;
      // we should NOT retry the original request, and we should NOT
      // notify the callback (refresh failed).
      expect(refreshCallbackCalled, isFalse);
    },
  );
}
