import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saso_willen_edition/data/datasources/remote/v1/retry_client.dart';

class _ScriptedClient extends http.BaseClient {
  _ScriptedClient(this._responses);

  final List<Future<http.StreamedResponse> Function()> _responses;
  final List<http.BaseRequest> sends = [];
  int _i = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends.add(request);
    final idx = _i.clamp(0, _responses.length - 1);
    _i++;
    final factory = _responses[idx];
    return factory();
  }
}

http.StreamedResponse _ok({int status = 200, String body = ''}) =>
    http.StreamedResponse(
      Stream.value(body.codeUnits),
      status,
      headers: const {'content-type': 'text/plain'},
    );

void main() {
  group('RetryClient', () {
    const zeroDelays = [Duration.zero, Duration.zero, Duration.zero];

    test('GET — succeeds on first try', () async {
      final inner = _ScriptedClient([() async => _ok(body: 'a')]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.get(Uri.parse('http://x/'));

      expect(response.statusCode, 200);
      expect(inner.sends.length, 1);
    });

    test('GET — retries on 500 then succeeds', () async {
      final inner = _ScriptedClient([
        () async => _ok(status: 500),
        () async => _ok(body: 'ok'),
      ]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.get(Uri.parse('http://x/'));

      expect(response.statusCode, 200);
      expect(inner.sends.length, 2);
    });

    test('GET — gives up after 4 attempts on persistent 500', () async {
      final inner = _ScriptedClient([() async => _ok(status: 500)]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.get(Uri.parse('http://x/'));

      expect(response.statusCode, 500);
      expect(inner.sends.length, 4);
    });

    test('GET — does not retry on 4xx', () async {
      final inner = _ScriptedClient([() async => _ok(status: 404)]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.get(Uri.parse('http://x/'));

      expect(response.statusCode, 404);
      expect(inner.sends.length, 1);
    });

    test('GET — retries on SocketException', () async {
      final inner = _ScriptedClient([
        () async => throw const SocketException('down'),
        () async => _ok(body: 'ok'),
      ]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.get(Uri.parse('http://x/'));

      expect(response.statusCode, 200);
      expect(inner.sends.length, 2);
    });

    test('DELETE — retries on 5xx (idempotent)', () async {
      final inner = _ScriptedClient([
        () async => _ok(status: 503),
        () async => _ok(status: 204),
      ]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.delete(Uri.parse('http://x/'));

      expect(response.statusCode, 204);
      expect(inner.sends.length, 2);
    });

    test('POST without Idempotency-Key — does NOT retry on 5xx', () async {
      final inner = _ScriptedClient([() async => _ok(status: 502)]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.post(Uri.parse('http://x/'), body: 'b');

      expect(response.statusCode, 502);
      expect(inner.sends.length, 1);
    });

    test('POST with Idempotency-Key — retries on 5xx', () async {
      final inner = _ScriptedClient([
        () async => _ok(status: 500),
        () async => _ok(status: 201, body: 'created'),
      ]);
      final client = RetryClient(inner, delays: zeroDelays);

      final response = await client.post(
        Uri.parse('http://x/'),
        headers: {'Idempotency-Key': 'k'},
        body: 'b',
      );

      expect(response.statusCode, 201);
      expect(inner.sends.length, 2);
    });

    test('rethrows network error after final attempt', () async {
      final inner = _ScriptedClient([
        () async => throw const SocketException('down'),
      ]);
      final client = RetryClient(inner, delays: zeroDelays);

      expect(
        () => client.get(Uri.parse('http://x/')),
        throwsA(isA<SocketException>()),
      );
    });
  });
}
