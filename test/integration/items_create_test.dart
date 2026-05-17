import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

import 'helpers/fake_http_client.dart';

void main() {
  test('createItem forwards the Idempotency-Key header verbatim', () async {
    String? observedKey;
    final backend = FakeBackend({
      'POST /api/v1/items': (http.Request req) {
        observedKey =
            req.headers['Idempotency-Key'] ?? req.headers['idempotency-key'];
        return http.Response(
          jsonEncode({
            'id': '24050001',
            'name': 'Test',
            'categoryId': '1',
            'features': <Map<String, dynamic>>[],
            'registeredAt': '2026-05-17T00:00:00Z',
            'updatedAt': '2026-05-17T00:00:00Z',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      },
    });

    final client = RestV1ApiClient(
      serverUrl: 'https://example.test',
      jwtToken: 'access',
      httpClient: backend.toClient(),
    );

    await client.createItem({
      'name': 'Test',
      'categoryId': 1,
    }, idempotencyKey: 'deadbeef-1234-4abc-9def-1234567890ab');

    expect(observedKey, 'deadbeef-1234-4abc-9def-1234567890ab');
  });
}
