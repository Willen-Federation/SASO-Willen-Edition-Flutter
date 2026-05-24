// Unit tests for OidcAuthService — covers issue #31 (fail-closed expiry).
//
// The flutter_appauth platform channel cannot run in pure-Dart tests, so
// we cover the surface that does not call _appAuth: the `restoreSession`
// rehydration path, the persistence layer, and the `isAuthenticated`
// getter. The legacy bug was a fail-open expiry check that treated a
// rehydrated token with unknown expiry as valid.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saso_willen_edition/core/auth/providers/oidc_auth_service.dart';
import 'package:saso_willen_edition/core/constants/app_constants.dart';
import 'package:saso_willen_edition/core/storage/secure_storage.dart';

class _MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  group('OidcAuthService.restoreSession', () {
    late _MockSecureStorage storage;
    late OidcAuthService svc;

    setUp(() {
      storage = _MockSecureStorage();
      svc = OidcAuthService('https://auth.example.com', storage);
      // Mocktail null-fallback for `write` / `delete` so they can be
      // invoked without throwing on a non-stubbed call.
      when(() => storage.write(any(), any())).thenAnswer((_) async {});
      when(() => storage.delete(any())).thenAnswer((_) async {});
    });

    test(
      'returns false and stays unauthenticated when nothing is stored',
      () async {
        when(() => storage.read(any())).thenAnswer((_) async => null);

        final ok = await svc.restoreSession();

        expect(ok, isFalse);
        expect(svc.isAuthenticated, isFalse);
        expect(svc.currentToken, isNull);
      },
    );

    test(
      'returns true and is authenticated when access token + future expiry are stored',
      () async {
        final future = DateTime.now().add(const Duration(minutes: 30)).toUtc();
        when(
          () => storage.read(AppConstants.jwtTokenKey),
        ).thenAnswer((_) async => 'live-access-token');
        when(
          () => storage.read(AppConstants.oidcRefreshTokenKey),
        ).thenAnswer((_) async => 'live-refresh-token');
        when(
          () => storage.read(AppConstants.oidcUserIdKey),
        ).thenAnswer((_) async => 'user-42');
        when(
          () => storage.read(AppConstants.oidcExpiresAtKey),
        ).thenAnswer((_) async => future.toIso8601String());

        final ok = await svc.restoreSession();

        expect(ok, isTrue);
        expect(svc.isAuthenticated, isTrue);
        expect(svc.currentToken, 'live-access-token');
        expect(svc.currentUserId, 'user-42');
      },
    );

    test(
      'fail-closed: returns false when access token is present but expiry is missing',
      () async {
        // The pre-#31 bug: in-memory _expiresAt defaulted to null, and
        // isAuthenticated returned true for any non-null access token.
        // After #31 this MUST return false even though the access token
        // is non-null, because the expiry is unknown.
        when(
          () => storage.read(AppConstants.jwtTokenKey),
        ).thenAnswer((_) async => 'orphan-access-token');
        when(
          () => storage.read(AppConstants.oidcRefreshTokenKey),
        ).thenAnswer((_) async => null);
        when(
          () => storage.read(AppConstants.oidcUserIdKey),
        ).thenAnswer((_) async => null);
        when(
          () => storage.read(AppConstants.oidcExpiresAtKey),
        ).thenAnswer((_) async => null);

        final ok = await svc.restoreSession();

        expect(ok, isFalse);
        expect(svc.isAuthenticated, isFalse);
        // Dead session must be purged so a later isAuthenticated read
        // (e.g. from a router redirect) doesn't return a stale token.
        expect(svc.currentToken, isNull);
        verify(() => storage.delete(AppConstants.jwtTokenKey)).called(1);
        verify(() => storage.delete(AppConstants.oidcExpiresAtKey)).called(1);
      },
    );

    test(
      'fail-closed: returns false when expiry is in the past and no refresh token exists',
      () async {
        final past = DateTime.now().subtract(const Duration(hours: 1)).toUtc();
        when(
          () => storage.read(AppConstants.jwtTokenKey),
        ).thenAnswer((_) async => 'expired-token');
        when(
          () => storage.read(AppConstants.oidcRefreshTokenKey),
        ).thenAnswer((_) async => null);
        when(
          () => storage.read(AppConstants.oidcUserIdKey),
        ).thenAnswer((_) async => 'user-42');
        when(
          () => storage.read(AppConstants.oidcExpiresAtKey),
        ).thenAnswer((_) async => past.toIso8601String());

        final ok = await svc.restoreSession();

        expect(ok, isFalse);
        expect(svc.isAuthenticated, isFalse);
        expect(svc.currentToken, isNull);
      },
    );

    test(
      'returns false on storage read error and clears in-memory state',
      () async {
        when(() => storage.read(any())).thenThrow(Exception('storage offline'));

        final ok = await svc.restoreSession();

        expect(ok, isFalse);
        expect(svc.isAuthenticated, isFalse);
        expect(svc.currentToken, isNull);
      },
    );

    test(
      'fail-closed: 29-second skew window — token expiring inside skew is treated as expired',
      () async {
        // Skew is 30s; an expiry 10 seconds out is inside the skew, so
        // the token must be rejected even though it has not strictly
        // expired yet.
        final almostExpired =
            DateTime.now().add(const Duration(seconds: 10)).toUtc();
        when(
          () => storage.read(AppConstants.jwtTokenKey),
        ).thenAnswer((_) async => 'about-to-expire');
        when(
          () => storage.read(AppConstants.oidcRefreshTokenKey),
        ).thenAnswer((_) async => null);
        when(
          () => storage.read(AppConstants.oidcUserIdKey),
        ).thenAnswer((_) async => 'user-42');
        when(
          () => storage.read(AppConstants.oidcExpiresAtKey),
        ).thenAnswer((_) async => almostExpired.toIso8601String());

        final ok = await svc.restoreSession();

        expect(ok, isFalse);
        expect(svc.isAuthenticated, isFalse);
      },
    );
  });

  group('OidcAuthService.logout', () {
    test('clears all persisted OIDC keys', () async {
      final storage = _MockSecureStorage();
      when(() => storage.delete(any())).thenAnswer((_) async {});
      final svc = OidcAuthService('https://auth.example.com', storage);

      await svc.logout();

      verify(() => storage.delete(AppConstants.jwtTokenKey)).called(1);
      verify(() => storage.delete(AppConstants.oidcRefreshTokenKey)).called(1);
      verify(() => storage.delete(AppConstants.oidcExpiresAtKey)).called(1);
      verify(() => storage.delete(AppConstants.oidcUserIdKey)).called(1);
      expect(svc.isAuthenticated, isFalse);
      expect(svc.currentToken, isNull);
    });
  });
}
