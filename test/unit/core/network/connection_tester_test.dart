import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/core/network/connection_tester.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient client;
  late ConnectionTester tester;

  setUp(() {
    client = _MockHttpClient();
    tester = ConnectionTester(
      httpClient: client,
      timeout: const Duration(milliseconds: 50),
    );
  });

  test('mock mode short-circuits without HTTP', () async {
    final result = await tester.test(
      const ServerConfig(apiMode: ApiMode.mock),
    );
    expect(result, isA<ConnectionTestSuccess>());
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('legacy mode hits /category/list.json with cookie header', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('[]', 200));

    final result = await tester.test(
      const ServerConfig(
        apiMode: ApiMode.legacy,
        baseUrl: 'https://saso.example.com',
        sessionCookie: 'sid=abc',
      ),
    );

    expect(result, isA<ConnectionTestSuccess>());
    final captured =
        verify(
          () => client.get(captureAny(), headers: captureAny(named: 'headers')),
        ).captured;
    expect(
      (captured[0] as Uri).toString(),
      'https://saso.example.com/category/list.json',
    );
    expect((captured[1] as Map<String, String>)['Cookie'], 'sid=abc');
  });

  test('rest mode hits /api/v1/health without bearer header', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('{}', 200));

    final result = await tester.test(
      const ServerConfig(
        apiMode: ApiMode.rest,
        baseUrl: 'https://api.example.com',
        jwtToken: 'tok-1',
      ),
    );

    expect(result, isA<ConnectionTestSuccess>());
    final captured =
        verify(
          () => client.get(captureAny(), headers: captureAny(named: 'headers')),
        ).captured;
    expect(
      (captured[0] as Uri).toString(),
      'https://api.example.com/api/v1/health',
    );
    // Health probe does not send credentials.
    expect(
      (captured[1] as Map<String, String>).containsKey('Authorization'),
      isFalse,
    );
    expect((captured[1] as Map<String, String>)['Accept'], 'application/json');
  });

  test('non-mock mode with empty url returns failure without HTTP', () async {
    final result = await tester.test(
      const ServerConfig(apiMode: ApiMode.legacy, baseUrl: ''),
    );
    expect(result, isA<ConnectionTestFailure>());
    expect((result as ConnectionTestFailure).message, 'URL_MISSING');
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('malformed url returns failure without HTTP', () async {
    final result = await tester.test(
      const ServerConfig(apiMode: ApiMode.legacy, baseUrl: 'not a url'),
    );
    expect(result, isA<ConnectionTestFailure>());
    verifyNever(() => client.get(any(), headers: any(named: 'headers')));
  });

  test('5xx response is reported as failure with status code', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('boom', 503));

    final result = await tester.test(
      const ServerConfig(
        apiMode: ApiMode.legacy,
        baseUrl: 'https://saso.example.com',
      ),
    );

    expect(result, isA<ConnectionTestFailure>());
    expect((result as ConnectionTestFailure).statusCode, 503);
  });

  test('timeout is surfaced as ConnectionTestTimeout', () async {
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
      (_) => Future.delayed(
        const Duration(seconds: 5),
        () => http.Response('', 200),
      ),
    );

    final result = await tester.test(
      const ServerConfig(
        apiMode: ApiMode.legacy,
        baseUrl: 'https://saso.example.com',
      ),
    );

    expect(result, isA<ConnectionTestTimeout>());
  });

  test('exception is surfaced as ConnectionTestFailure', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenThrow(const SocketException('refused'));

    final result = await tester.test(
      const ServerConfig(
        apiMode: ApiMode.legacy,
        baseUrl: 'https://saso.example.com',
      ),
    );

    expect(result, isA<ConnectionTestFailure>());
    expect((result as ConnectionTestFailure).message, contains('refused'));
  });
}

class SocketException implements Exception {
  const SocketException(this.message);
  final String message;
  @override
  String toString() => 'SocketException: $message';
}
