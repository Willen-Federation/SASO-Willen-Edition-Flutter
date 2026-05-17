// Unit tests for RestV1ApiClient.registerPushToken — covers issue #19.
//
// Pins:
//   1. Request shape — POST /api/v1/mobile/devices/push-token with
//      Bearer header + JSON body {token, platform}.
//   2. 200 success — call resolves without throwing.
//   3. Silent degrade — 404 and 501 do NOT throw (backend not yet
//      deployed). Any other 4xx/5xx surfaces as an exception so the
//      caller can decide what to do.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient http_;
  late RestV1ApiClient client;
  late List<Uri> capturedUris;
  late List<Map<String, String>> capturedHeaders;
  late List<String> capturedBodies;

  setUp(() {
    http_ = _MockHttpClient();
    capturedUris = [];
    capturedHeaders = [];
    capturedBodies = [];
    client = RestV1ApiClient(
      serverUrl: 'https://saso.example.com',
      jwtToken: 'test-jwt',
      httpClient: http_,
    );
  });

  void stubPost(int statusCode, {String body = ''}) {
    when(
      () => http_.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((invocation) async {
      capturedUris.add(invocation.positionalArguments[0] as Uri);
      capturedHeaders.add(
        invocation.namedArguments[#headers] as Map<String, String>,
      );
      capturedBodies.add(invocation.namedArguments[#body] as String);
      return http.Response(body, statusCode);
    });
  }

  test(
    '200: POST hits /api/v1/mobile/devices/push-token with Bearer + JSON body',
    () async {
      stubPost(200);

      await client.registerPushToken(token: 'fcm-token-xyz', platform: 'fcm');

      expect(
        capturedUris.single.toString(),
        'https://saso.example.com/api/v1/mobile/devices/push-token',
      );
      expect(capturedHeaders.single['Authorization'], 'Bearer test-jwt');
      expect(capturedHeaders.single['Content-Type'], 'application/json');
      final body = jsonDecode(capturedBodies.single) as Map<String, dynamic>;
      expect(body, {'token': 'fcm-token-xyz', 'platform': 'fcm'});
    },
  );

  test('404: silently degrades (endpoint not yet deployed)', () async {
    stubPost(404, body: 'Not Found');

    // Must NOT throw — auth flow continues even when backend lags.
    await client.registerPushToken(token: 't', platform: 'apns');
  });

  test(
    '501: silently degrades (endpoint reserved, table not present)',
    () async {
      stubPost(501, body: 'Not Implemented');

      await client.registerPushToken(token: 't', platform: 'apns');
    },
  );

  test(
    '500: surfaces an exception so the caller knows registration failed',
    () async {
      stubPost(500, body: '{"type": "about:blank", "title": "Server error"}');

      await expectLater(
        client.registerPushToken(token: 't', platform: 'fcm'),
        throwsA(anything),
      );
    },
  );

  test('401: surfaces (caller is expected to refresh token + retry)', () async {
    stubPost(401, body: '{"type": "about:blank", "title": "Unauthorized"}');

    await expectLater(
      client.registerPushToken(token: 't', platform: 'fcm'),
      throwsA(anything),
    );
  });
}
