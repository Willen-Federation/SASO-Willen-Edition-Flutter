import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

import 'helpers/fake_http_client.dart';

void main() {
  test('lookupBarcode hits /api/v1/barcode/{code} and parses the result',
      () async {
    final backend = FakeBackend({
      'GET /api/v1/barcode/4901234567890': (http.Request req) => http.Response(
            jsonEncode({
              'code': '4901234567890',
              'item_id': 42,
              'name': 'Linked Item',
              'symbology': 'EAN-13',
            }),
            200,
            headers: {'content-type': 'application/json'},
          ),
    });

    final client = RestV1ApiClient(
      serverUrl: 'https://example.test',
      jwtToken: 'access',
      httpClient: backend.toClient(),
    );

    final result = await client.lookupBarcode('4901234567890');
    expect(result.code, '4901234567890');
    expect(result.itemId, 42);
    expect(result.isLinked, isTrue);
  });

  test('lookupBarcode handles standalone barcodes (no item_id)', () async {
    final backend = FakeBackend({
      'GET /api/v1/barcode/0000000000000': (http.Request req) => http.Response(
            jsonEncode({'code': '0000000000000', 'symbology': 'EAN-13'}),
            200,
            headers: {'content-type': 'application/json'},
          ),
    });

    final client = RestV1ApiClient(
      serverUrl: 'https://example.test',
      jwtToken: 'access',
      httpClient: backend.toClient(),
    );

    final result = await client.lookupBarcode('0000000000000');
    expect(result.isLinked, isFalse);
    expect(result.itemId, isNull);
  });
}
