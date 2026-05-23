import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

import 'helpers/fake_http_client.dart';

void main() {
  test('fetchAllItemsRaw drives a multi-page cursor walk', () async {
    final calls = <Uri>[];
    final backend = FakeBackend({
      'GET /api/v1/items': (http.Request req) {
        calls.add(req.url);
        final cursor = req.url.queryParameters['cursor'];
        if (cursor == null) {
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 1, 'name': 'a'},
              ],
              'nextCursor': 1,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (cursor == '1') {
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 2, 'name': 'b'},
              ],
              'nextCursor': 2,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'data': <Map<String, dynamic>>[], 'nextCursor': null}),
          200,
          headers: {'content-type': 'application/json'},
        );
      },
    });

    final client = RestV1ApiClient(
      serverUrl: 'https://example.test',
      jwtToken: 'access',
      httpClient: backend.toClient(),
    );

    final collected = <int>[];
    int? cursor;
    var pages = 0;
    do {
      final page = await client.fetchAllItemsRaw(cursor: cursor, limit: 50);
      collected.addAll(page.items.map((m) => m['id'] as int));
      cursor = page.nextCursor;
      pages++;
    } while (cursor != null);

    expect(pages, greaterThanOrEqualTo(3));
    expect(collected, [1, 2]);
    expect(
      calls.first.queryParameters.containsKey('cursor'),
      isFalse,
      reason: 'first probe must not carry a cursor',
    );
  });

  test(
    'fetchAllItemsRaw still accepts the legacy snake_case next_cursor field',
    () async {
      final backend = FakeBackend({
        'GET /api/v1/items': (http.Request req) {
          final cursor = req.url.queryParameters['cursor'];
          if (cursor == null) {
            return http.Response(
              jsonEncode({
                'data': [
                  {'id': 1, 'name': 'a'},
                ],
                'next_cursor': 7,
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            jsonEncode({'data': <Map<String, dynamic>>[], 'next_cursor': null}),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      });

      final client = RestV1ApiClient(
        serverUrl: 'https://example.test',
        jwtToken: 'access',
        httpClient: backend.toClient(),
      );

      final firstPage = await client.fetchAllItemsRaw();
      expect(firstPage.nextCursor, 7);
    },
  );
}
