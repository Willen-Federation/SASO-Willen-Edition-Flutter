import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/core/auth/auth_service.dart';
import 'package:saso_willen_edition/core/auth/providers/legacy_auth_service.dart';
import 'package:saso_willen_edition/core/storage/secure_storage.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _FakeRequest extends Fake implements http.BaseRequest {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeRequest()));

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

  http.StreamedResponse streamed(
    int status, {
    String body = '',
    Map<String, String> headers = const {},
  }) => http.StreamedResponse(
    Stream.value(utf8.encode(body)),
    status,
    headers: headers,
  );

  void whenSendReturns(http.StreamedResponse response) {
    when(() => httpClient.send(any())).thenAnswer((_) async => response);
  }

  void whenSendThrows(Object error) {
    when(() => httpClient.send(any())).thenThrow(error);
  }

  group('LegacyAuthService.login URL validation', () {
    test('returns HTTPS error for plaintext HTTP non-loopback URL', () async {
      final result = await service.login(
        serverUrl: 'http://saso.example.com',
        username: 'u',
        password: 'p',
      );
      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('Server URL must use HTTPS'));
      verifyNever(() => httpClient.send(any()));
    });
  });

  group('LegacyAuthService.login HTTP failure paths', () {
    test('non-2xx/3xx surfaces HTTP status + body snippet', () async {
      whenSendReturns(streamed(500, body: 'internal error'));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      expect(result, isA<AuthFailure>());
      expect(
        failureMessage(result),
        allOf(contains('HTTP 500'), contains('internal error')),
      );
      verifyNever(() => storage.write(any(), any()));
    });

    test(
      '200 without Set-Cookie surfaces explicit missing-cookie error',
      () async {
        whenSendReturns(streamed(200, body: '{"jwt":"eyJ..."}'));

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
      whenSendThrows(TimeoutException('forced'));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('Network timeout'));
    });

    test('generic exception becomes a network-error failure', () async {
      whenSendThrows(Exception('connection refused'));

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
      whenSendReturns(streamed(500, body: huge));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'u',
        password: 'p',
      );

      final msg = failureMessage(result)!;
      expect(msg.length, lessThan(huge.length));
      expect(msg, contains('…'));
    });
  });

  group('LegacyAuthService.login redirect handling', () {
    test('303 → /error/1/ is reported as wrong credentials', () async {
      whenSendReturns(
        streamed(
          303,
          headers: {
            'location': 'https://saso.example.com/error/1/',
            'set-cookie': 'PHPSESSID=abc; Path=/; HttpOnly',
          },
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'wrong',
        password: 'creds',
      );

      expect(result, isA<AuthFailure>());
      expect(
        failureMessage(result),
        allOf(contains('redirected'), contains('/error/1/')),
      );
      verifyNever(() => storage.write(any(), any()));
    });

    test('302 to a relative /error/* Location is also detected', () async {
      whenSendReturns(
        streamed(
          302,
          headers: {
            'location': '/error/auth-failed',
            'set-cookie': 'PHPSESSID=abc; Path=/; HttpOnly',
          },
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'wrong',
        password: 'creds',
      );

      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('/error/auth-failed'));
    });

    test(
      '303 + Set-Cookie + non-error Location is treated as success',
      () async {
        whenSendReturns(
          streamed(
            303,
            headers: {
              'location': 'https://saso.example.com/home/',
              'set-cookie': 'PHPSESSID=ok123; Path=/; HttpOnly',
            },
          ),
        );

        final result = await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'alice',
          password: 'p',
        );

        expect(result, isA<AuthSuccess>());
        expect((result as AuthSuccess).sessionCookie, 'PHPSESSID=ok123');
        verify(() => storage.write(any(), 'PHPSESSID=ok123')).called(1);
      },
    );

    test(
      '302 + Set-Cookie with no Location header is still treated as success',
      () async {
        whenSendReturns(
          streamed(302, headers: {'set-cookie': 'session=xyz; Path=/'}),
        );

        final result = await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'alice',
          password: 'p',
        );

        expect(result, isA<AuthSuccess>());
        expect((result as AuthSuccess).sessionCookie, 'session=xyz');
      },
    );

    test(
      '303 with non-error Location but no Set-Cookie surfaces a clear error',
      () async {
        whenSendReturns(
          streamed(
            303,
            headers: {'location': 'https://saso.example.com/home/'},
          ),
        );

        final result = await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'alice',
          password: 'p',
        );

        expect(result, isA<AuthFailure>());
        expect(
          failureMessage(result),
          allOf(
            contains('HTTP 303'),
            contains('Set-Cookie'),
            contains('/home/'),
          ),
        );
      },
    );
  });

  group('LegacyAuthService.login success', () {
    test('200 + Set-Cookie persists the cookie and returns success', () async {
      whenSendReturns(
        streamed(
          200,
          body: 'ok',
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
  });

  group('LegacyAuthService.login request construction', () {
    test(
      'sends POST to {base}/auth/start/ with form-urlencoded body and disables redirect follow',
      () async {
        whenSendReturns(streamed(200, headers: {'set-cookie': 's=1'}));

        await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'alice',
          password: 'secret',
        );

        final captured =
            verify(() => httpClient.send(captureAny())).captured.single
                as http.Request;

        expect(captured.method, 'POST');
        expect(captured.url.toString(), 'https://saso.example.com/auth/start/');
        expect(
          captured.headers['Content-Type'],
          contains('application/x-www-form-urlencoded'),
        );
        expect(captured.bodyFields, {'id': 'alice', 'password': 'secret'});
        expect(
          captured.followRedirects,
          isFalse,
          reason:
              'must keep 3xx visible so the /error/* redirect is observable',
        );
      },
    );
  });

  group('LegacyAuthService.login error-redirect detection variants', () {
    test(
      '303 → /auth/start/error/1/ (newer-style SASO redirect) is detected',
      () async {
        whenSendReturns(
          streamed(
            303,
            headers: {
              'location': 'https://saso.example.com/auth/start/error/1/',
              'set-cookie': 'PHPSESSID=abc; Path=/',
            },
          ),
        );

        final result = await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'wrong',
          password: 'creds',
        );

        expect(result, isA<AuthFailure>());
        expect(failureMessage(result), contains('/auth/start/error/1/'));
        verifyNever(() => storage.write(any(), any()));
      },
    );
  });
}
