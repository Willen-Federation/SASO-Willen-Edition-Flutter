import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

import 'helpers/fake_http_client.dart';

void main() {
  test('connectWithPairingToken exchanges pairing code for tokens', () async {
    http.Request? observed;
    final backend = FakeBackend({
      'POST /api/v1/mobile/connect': (http.Request req) {
        observed = req;
        return http.Response(
          jsonEncode({
            'access_token': 'access.jwt',
            'refresh_token': 'refresh.opaque',
            'token_type': 'Bearer',
            'expires_in': 3600,
            'device_id': 1,
            'device_name': 'iPhone 17',
            'expires_at': '2026-05-17T01:00:00Z',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      },
    });

    final client = RestV1ApiClient(
      serverUrl: 'https://example.test',
      jwtToken: '',
      httpClient: backend.toClient(),
    );

    final pair = await client.connectWithPairingToken(
      pairingToken: 'pairing-code-xyz',
      deviceName: 'iPhone 17',
    );

    expect(pair.accessToken, 'access.jwt');
    expect(pair.refreshToken, 'refresh.opaque');
    expect(observed, isNotNull);
    expect(
      observed!.headers['Authorization'],
      isNull,
      reason: 'initial pairing must NOT carry a Bearer token',
    );
    final body = jsonDecode(observed!.body) as Map<String, dynamic>;
    expect(body['token'], 'pairing-code-xyz');
    expect(body['deviceName'], 'iPhone 17');
  });

  test('refreshAccessToken rotates the pair', () async {
    final backend = FakeBackend({
      'POST /api/v1/mobile/token/refresh': (http.Request req) {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['refresh_token'], 'old-refresh');
        return http.Response(
          jsonEncode({
            'access_token': 'new.access',
            'refresh_token': 'new.refresh',
            'token_type': 'Bearer',
            'expires_in': 3600,
            'device_id': 1,
            'device_name': 'iPhone 17',
            'expires_at': '2026-05-17T02:00:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      },
    });

    final client = RestV1ApiClient(
      serverUrl: 'https://example.test',
      jwtToken: 'expired',
      httpClient: backend.toClient(),
    );

    final pair = await client.refreshAccessToken('old-refresh');
    expect(pair.accessToken, 'new.access');
    expect(pair.refreshToken, 'new.refresh');
  });
}
