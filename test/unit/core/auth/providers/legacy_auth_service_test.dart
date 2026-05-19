import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/core/auth/auth_service.dart';
import 'package:saso_willen_edition/core/auth/providers/legacy_auth_service.dart';
import 'package:saso_willen_edition/core/storage/secure_storage.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient httpClient;
  late _MockSecureStorage storage;
  late LegacyAuthService service;

  setUp(() {
    httpClient = _MockHttpClient();
    storage = _MockSecureStorage();
    service = LegacyAuthService(storage, httpClient: httpClient);
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
  });

  String? failureMessage(AuthResult r) => r is AuthFailure ? r.message : null;

  group('LegacyAuthService.login URL validation', () {
    test('returns HTTPS error for plaintext HTTP non-loopback URL', () async {
      final result = await service.login(
        serverUrl: 'http://saso.example.com',
        username: 'u',
        password: 'p',
      );
      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('Server URL must use HTTPS'));
      verifyNever(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      );
    });
  });

  group('LegacyAuthService.login HTTP failure paths', () {
    test('non-200 surfaces HTTP status + body snippet', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('user not found', 404));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      expect(result, isA<AuthFailure>());
      expect(
        failureMessage(result),
        allOf(contains('HTTP 404'), contains('user not found')),
      );
      verifyNever(() => storage.write(any(), any()));
    });

    test(
      '200 without Set-Cookie surfaces explicit missing-cookie error',
      () async {
        when(
          () => httpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('{"jwt":"eyJ..."}', 200));

        final result = await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'u',
          password: 'p',
        );

        expect(result, isA<AuthFailure>());
        expect(
          failureMessage(result),
          allOf(contains('HTTP 200'), contains('Set-Cookie')),
        );
        verifyNever(() => storage.write(any(), any()));
      },
    );

    test('TimeoutException becomes a network-timeout failure', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => throw TimeoutException('forced'));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('Network timeout'));
    });

    test('generic exception becomes a network-error failure', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('connection refused'));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      expect(result, isA<AuthFailure>());
      expect(
        failureMessage(result),
        allOf(contains('Network error'), contains('connection refused')),
      );
    });

    test('long response body is collapsed and truncated', () async {
      final huge = 'A' * 1000;
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(huge, 500));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      final msg = failureMessage(result)!;
      // We expect the snippet to be capped well under the raw body length.
      expect(msg.length, lessThan(huge.length));
      expect(msg, contains('…'));
    });
  });

  group('LegacyAuthService.login success', () {
    test('200 + Set-Cookie persists the cookie and returns success', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          'ok',
          200,
          headers: {'set-cookie': 'PHPSESSID=abc123; Path=/; HttpOnly'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'p',
      );

      expect(result, isA<AuthSuccess>());
      expect((result as AuthSuccess).userId, 'alice');
      expect(result.sessionCookie, 'PHPSESSID=abc123');
      expect(service.isAuthenticated, isTrue);
      verify(() => storage.write(any(), 'PHPSESSID=abc123')).called(1);
    });

    test('302 + Set-Cookie is also treated as success', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '',
          302,
          headers: {'set-cookie': 'session=xyz; Path=/'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'p',
      );

      expect(result, isA<AuthSuccess>());
      expect((result as AuthSuccess).sessionCookie, 'session=xyz');
    });
  });

  group('LegacyAuthService.login URL construction', () {
    test('posts to {base}/auth/start with form-urlencoded body', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('', 200, headers: {'set-cookie': 's=1'}),
      );

      await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'secret',
      );

      final captured = verify(
        () => httpClient.post(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      final uri = captured[0] as Uri;
      final headers = captured[1] as Map<String, String>;
      final body = captured[2] as Map<String, String>;
      expect(uri.toString(), 'https://saso.example.com/auth/start');
      expect(headers['Content-Type'], 'application/x-www-form-urlencoded');
      expect(body, {'id': 'alice', 'password': 'secret'});
    });
  });
}
