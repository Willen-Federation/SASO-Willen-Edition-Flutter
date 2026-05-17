// Unit tests for McpClient init-latch — covers issue #20.
//
// The MCP protocol requires an `initialize` handshake before any
// `tools/call`. Pre-fix, callers either forgot to invoke initialize()
// or fired concurrent callTool() requests that raced past the
// handshake. The fix is an idempotent init-latch (`_initFuture`).
// These tests pin the contract:
//   1. Concurrent callTool() invocations trigger exactly one
//      `initialize` request.
//   2. Sequential callTool() invocations after init reuse the latch.
//   3. A failed initialize() clears the latch so the next call retries.
//   4. Explicit initialize() + subsequent callTool() do not duplicate.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/data/datasources/remote/mcp/mcp_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient http_;
  late McpClient client;

  /// Decoded {method, id} for every POST to /mcp. Captured in the
  /// `thenAnswer` body so we can assert on the call ordering.
  late List<Map<String, dynamic>> requests;

  setUp(() {
    http_ = _MockHttpClient();
    requests = [];
    client = McpClient(
      serverUrl: 'https://mcp.example.com',
      jwtToken: 'test-jwt',
      httpClient: http_,
    );
  });

  /// Stub every POST. Capture the request method, return a JSON-RPC
  /// 2.0 success envelope with `result: {}`.
  void stubOk({Duration? delay}) {
    when(
      () => http_.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as String;
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      requests.add(decoded);
      if (delay != null) await Future<void>.delayed(delay);
      return http.Response(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': decoded['id'],
          'result': <String, dynamic>{},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
  }

  test(
    'two concurrent callTool() invocations trigger exactly one initialize',
    () async {
      stubOk(delay: const Duration(milliseconds: 20));

      await Future.wait([
        client.callTool('search_items', {'query': 'a'}),
        client.callTool('search_items', {'query': 'b'}),
      ]);

      // Three POSTs total — one initialize + two tools/call.
      final inits = requests.where((r) => r['method'] == 'initialize').toList();
      final calls = requests.where((r) => r['method'] == 'tools/call').toList();
      expect(
        inits.length,
        1,
        reason: 'concurrent callers must share one handshake',
      );
      expect(calls.length, 2);
    },
  );

  test('initialize comes before any tools/call in the request order', () async {
    stubOk();

    await client.callTool('search_items', {'query': 'a'});

    expect(requests.length, 2);
    expect(requests[0]['method'], 'initialize');
    expect(requests[1]['method'], 'tools/call');
  });

  test(
    'second sequential callTool reuses the latch (no second initialize)',
    () async {
      stubOk();

      await client.callTool('search_items', {'query': 'a'});
      await client.callTool('search_items', {'query': 'b'});

      final inits = requests.where((r) => r['method'] == 'initialize').toList();
      expect(inits.length, 1);
    },
  );

  test(
    'explicit initialize() followed by callTool does not duplicate the handshake',
    () async {
      stubOk();

      await client.initialize();
      await client.callTool('search_items', {'query': 'a'});

      final inits = requests.where((r) => r['method'] == 'initialize').toList();
      expect(inits.length, 1);
    },
  );

  test('failed initialize clears the latch so the next call retries', () async {
    // First post: 503. Subsequent posts: 200.
    var firstCall = true;
    when(
      () => http_.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as String;
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      requests.add(decoded);
      if (firstCall) {
        firstCall = false;
        return http.Response('upstream down', 503);
      }
      return http.Response(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': decoded['id'],
          'result': <String, dynamic>{},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    // First call fails on the 503 init.
    await expectLater(
      client.callTool('search_items', {'query': 'a'}),
      throwsA(isA<Exception>()),
    );

    // Latch was cleared; the next call retries init and proceeds.
    await client.callTool('search_items', {'query': 'b'});

    final inits = requests.where((r) => r['method'] == 'initialize').toList();
    expect(
      inits.length,
      2,
      reason: 'failed init must not permanently wedge the client',
    );
  });
}
