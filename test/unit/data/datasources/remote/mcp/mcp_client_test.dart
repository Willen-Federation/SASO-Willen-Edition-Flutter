import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saso_willen_edition/data/datasources/remote/mcp/mcp_client.dart';

http.Response _rpcOk(int id, dynamic result) => http.Response(
  jsonEncode({'jsonrpc': '2.0', 'id': id, 'result': result}),
  200,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('McpClient.callTool() initialization guard', () {
    test('throws StateError if called before initialize()', () async {
      final client = McpClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async => _rpcOk(1, {'ok': true})),
      );

      expect(client.isInitialized, isFalse);
      expect(
        () => client.callTool('search_items', {'query': 'foo'}),
        throwsA(isA<StateError>()),
      );
    });

    test('succeeds after initialize()', () async {
      var requests = 0;
      final client = McpClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((req) async {
          requests++;
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          // First call is initialize, second is tools/call.
          if (body['method'] == 'initialize') {
            return _rpcOk(
              body['id'] as int,
              {'capabilities': <String, dynamic>{}},
            );
          }
          return _rpcOk(body['id'] as int, {'items': []});
        }),
      );

      await client.initialize();
      expect(client.isInitialized, isTrue);

      final result = await client.callTool('search_items', {'query': 'foo'});
      expect(result, isA<Map<String, dynamic>>());
      expect(result['items'], isEmpty);
      expect(requests, 2);
    });

    test(
      'isInitialized stays false if initialize() throws',
      () async {
        final client = McpClient(
          serverUrl: 'https://example.com',
          jwtToken: 'jwt',
          httpClient: MockClient(
            (_) async => http.Response('boom', 500),
          ),
        );

        await expectLater(client.initialize(), throwsA(isA<Exception>()));
        expect(client.isInitialized, isFalse);
        expect(
          () => client.callTool('search_items', {}),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
