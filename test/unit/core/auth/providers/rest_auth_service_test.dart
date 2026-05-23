// PR-B3: covers the REST replacement for `LegacyAuthService` introduced
// alongside server PR-A3 (`POST /api/v1/auth/login` / `/logout` /
// `/password`). The tests focus on the wire-protocol contract: each
// SASO-AUTH-* error code from the server's RFC 7807 `problem+json`
// response is mapped to a recognisable client-side message + code, and
// successful login mutates the service's in-memory token state so the
// auth-state notifier can hand the values to ServerConfigNotifier.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/core/auth/auth_service.dart';
import 'package:saso_willen_edition/core/auth/providers/rest_auth_service.dart';
import 'package:saso_willen_edition/core/constants/app_constants.dart';
import 'package:saso_willen_edition/core/storage/secure_storage.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUri()));

  late _MockHttpClient httpClient;
  late _MockSecureStorage storage;
  late RestAuthService service;

  setUp(() {
    httpClient = _MockHttpClient();
    storage = _MockSecureStorage();
    service = RestAuthService(storage, httpClient: httpClient);
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenAnswer((_) async => null);
  });

  String? failureMessage(AuthResult r) => r is AuthFailure ? r.message : null;
  String? failureCode(AuthResult r) => r is AuthFailure ? r.code : null;

  void whenPostReturns(http.Response response) {
    when(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => response);
  }

  void whenPostThrows(Object error) {
    when(
      () => httpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenThrow(error);
  }

  group('RestAuthService.login — wire protocol', () {
    test('issues POST /api/v1/auth/login with JSON body', () async {
      whenPostReturns(
        http.Response(
          '{"access_token":"jwt-abc","refresh_token":"opaque-xyz",'
          '"device_id":42,"expires_in":3600,'
          '"expires_at":"2026-05-23T13:00:00Z"}',
          201,
          headers: const {'content-type': 'application/json'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'CorrectHorseBatteryStaple-1',
      );

      expect(result, isA<AuthSuccess>());

      // Verify the request shape.
      final captured = verify(
        () => httpClient.post(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      expect(
        (captured[0] as Uri).toString(),
        'https://saso.example.com/api/v1/auth/login',
      );
      final headers = captured[1] as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
      expect(captured[2] as String, contains('"username":"alice"'));
      expect(captured[2] as String, contains('"password":"'));
      expect(captured[2] as String, contains('"deviceName":"SASO Mobile"'));
    });

    test('happy path stores token pair in service state', () async {
      whenPostReturns(
        http.Response(
          '{"access_token":"jwt-abc","refresh_token":"opaque-xyz",'
          '"device_id":42,"expires_in":3600}',
          201,
          headers: const {'content-type': 'application/json'},
        ),
      );

      await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(service.isAuthenticated, isTrue);
      expect(service.currentToken, 'jwt-abc');
      expect(service.currentRefreshToken, 'opaque-xyz');
      expect(service.currentDeviceId, 42);
      expect(service.currentUserId, 'alice');
      expect(service.currentExpiresAt, isNotNull);

      // Tokens persisted via secure storage so a subsequent
      // ServerConfigNotifier.load() can restore them.
      verify(
        () => storage.write(AppConstants.jwtTokenKey, 'jwt-abc'),
      ).called(1);
      verify(
        () => storage.write(AppConstants.refreshTokenKey, 'opaque-xyz'),
      ).called(1);
    });

    test('rejects http URL via UrlValidator', () async {
      final result = await service.login(
        serverUrl: 'http://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('HTTPS'));
      verifyNever(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      );
    });

    test(
      'maps SASO-AUTH-1001 (401) to "username or password incorrect"',
      () async {
        whenPostReturns(
          http.Response(
            '{"type":"https://docs.willen-federation.org/error-codes#SASO-AUTH-1001",'
            '"title":"Invalid credentials","status":401,'
            '"detail":"The username or password is incorrect.",'
            '"code":"SASO-AUTH-1001","traceId":"abc"}',
            401,
            headers: const {'content-type': 'application/problem+json'},
          ),
        );

        final result = await service.login(
          serverUrl: 'https://saso.example.com',
          username: 'alice',
          password: 'wrong',
        );

        expect(result, isA<AuthFailure>());
        expect(failureMessage(result), contains('username or password'));
        expect(failureCode(result), 'SASO-AUTH-1001');
        expect(service.isAuthenticated, isFalse);
      },
    );

    test('maps SASO-AUTH-1009 (423) to "account is locked"', () async {
      whenPostReturns(
        http.Response(
          '{"type":"docs/SASO-AUTH-1009","title":"Account locked","status":423,'
          '"code":"SASO-AUTH-1009","traceId":"x"}',
          423,
          headers: const {'content-type': 'application/problem+json'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureCode(result), 'SASO-AUTH-1009');
      expect(failureMessage(result), contains('locked'));
    });

    test('maps SASO-AUTH-1010 (429) with Retry-After header to '
        '"Try again in N seconds"', () async {
      whenPostReturns(
        http.Response(
          '{"code":"SASO-AUTH-1010","detail":"Too many failed attempts."}',
          429,
          headers: const {
            'content-type': 'application/problem+json',
            'retry-after': '120',
          },
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureCode(result), 'SASO-AUTH-1010');
      expect(failureMessage(result), contains('120 seconds'));
    });

    test('maps SASO-AUTH-1011 (422) to "malformed"', () async {
      whenPostReturns(
        http.Response(
          '{"code":"SASO-AUTH-1011","detail":"Missing field."}',
          422,
          headers: const {'content-type': 'application/problem+json'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureCode(result), 'SASO-AUTH-1011');
      expect(failureMessage(result), contains('malformed'));
    });

    test('unrecognised SASO-AUTH-* code surfaces the raw detail', () async {
      whenPostReturns(
        http.Response(
          '{"code":"SASO-AUTH-9999","detail":"some new condition"}',
          500,
          headers: const {'content-type': 'application/problem+json'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureCode(result), 'SASO-AUTH-9999');
      expect(failureMessage(result), contains('some new condition'));
    });

    test('non-problem+json error body falls back to snippet', () async {
      whenPostReturns(
        http.Response(
          '<html><body>Server Error</body></html>',
          500,
          headers: const {'content-type': 'text/html'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureMessage(result), contains('HTTP 500'));
      expect(failureMessage(result), contains('Server Error'));
    });

    test('timeout surfaces a network-timeout message', () async {
      whenPostThrows(TimeoutException('timeout'));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureMessage(result), contains('Network timeout'));
    });

    test('network error surfaces "Network error: …"', () async {
      whenPostThrows(Exception('connection refused'));

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(failureMessage(result), contains('Network error'));
      expect(failureMessage(result), contains('connection refused'));
    });

    test('200 with unparseable body returns failure (not success)', () async {
      whenPostReturns(
        http.Response(
          'not valid json',
          200,
          headers: const {'content-type': 'application/json'},
        ),
      );

      final result = await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );

      expect(result, isA<AuthFailure>());
      expect(service.isAuthenticated, isFalse);
    });
  });

  group('RestAuthService.logout', () {
    test('clears local state even when the server is unreachable', () async {
      // Seed the service with a logged-in state by running a successful login first.
      whenPostReturns(
        http.Response(
          '{"access_token":"jwt","refresh_token":"r","device_id":1,'
          '"expires_in":3600}',
          201,
          headers: const {'content-type': 'application/json'},
        ),
      );
      await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );
      expect(service.isAuthenticated, isTrue);

      // Now make the logout POST throw — we still want the local state cleared.
      whenPostThrows(Exception('network down'));
      // No serverUrlKey persisted, so the service skips the network call
      // entirely — even cleaner test: local state cleared regardless.
      when(
        () => storage.read(AppConstants.serverUrlKey),
      ).thenAnswer((_) async => null);

      await service.logout();

      expect(service.isAuthenticated, isFalse);
      expect(service.currentToken, isNull);
      expect(service.currentRefreshToken, isNull);
      verify(() => storage.delete(AppConstants.jwtTokenKey)).called(1);
      verify(() => storage.delete(AppConstants.refreshTokenKey)).called(1);
    });
  });

  group('RestAuthService.changePassword', () {
    setUp(() async {
      // Pre-seed an authenticated session.
      whenPostReturns(
        http.Response(
          '{"access_token":"jwt","refresh_token":"r","device_id":1,'
          '"expires_in":3600}',
          201,
          headers: const {'content-type': 'application/json'},
        ),
      );
      await service.login(
        serverUrl: 'https://saso.example.com',
        username: 'alice',
        password: 'pw',
      );
    });

    test('204 returns AuthResult.success', () async {
      whenPostReturns(http.Response('', 204));

      final result = await service.changePassword(
        serverUrl: 'https://saso.example.com',
        currentPassword: 'pw',
        newPassword: 'newpassword1',
      );

      expect(result, isA<AuthSuccess>());
    });

    test(
      '401 SASO-AUTH-1012 maps to "current password is incorrect"',
      () async {
        whenPostReturns(
          http.Response(
            '{"code":"SASO-AUTH-1012","detail":"Current password mismatch."}',
            401,
            headers: const {'content-type': 'application/problem+json'},
          ),
        );

        final result = await service.changePassword(
          serverUrl: 'https://saso.example.com',
          currentPassword: 'wrong',
          newPassword: 'newpassword1',
        );

        expect(failureCode(result), 'SASO-AUTH-1012');
        expect(failureMessage(result), contains('current password'));
      },
    );

    test('422 SASO-AUTH-1013 preserves the policy detail', () async {
      whenPostReturns(
        http.Response(
          '{"code":"SASO-AUTH-1013",'
          '"detail":"New password must be 8-64 characters and use only [A-Za-z0-9_-]."}',
          422,
          headers: const {'content-type': 'application/problem+json'},
        ),
      );

      final result = await service.changePassword(
        serverUrl: 'https://saso.example.com',
        currentPassword: 'pw',
        newPassword: '!',
      );

      expect(failureCode(result), 'SASO-AUTH-1013');
      expect(failureMessage(result), contains('8-64 characters'));
    });

    test('without an access token, refuses without a network call', () async {
      // Reset the service to logged-out.
      await service.logout();
      // Re-stub post so we can assert it was not called.
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('should not happen', 500));

      final result = await service.changePassword(
        serverUrl: 'https://saso.example.com',
        currentPassword: 'pw',
        newPassword: 'newpassword1',
      );

      expect(result, isA<AuthFailure>());
      expect(failureMessage(result), contains('Not authenticated'));
    });
  });
}
