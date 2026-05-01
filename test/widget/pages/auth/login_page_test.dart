import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/auth/auth_provider_config.dart';
import 'package:saso_willen_edition/core/auth/auth_service.dart';
import 'package:saso_willen_edition/presentation/pages/auth/login_page.dart';
import 'package:saso_willen_edition/presentation/providers/auth_state_provider.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

Widget _wrap(Widget child, List<Override> overrides) {
  return ProviderScope(overrides: overrides, child: MaterialApp(home: child));
}

void main() {
  group('LoginPage — provider badge and UI variants', () {
    testWidgets('shows credential form for legacy provider', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(const AuthProviderConfig.legacy()),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('username_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.text('標準ログイン'), findsOneWidget);
    });

    testWidgets('shows browser button for oidc provider', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(
              const AuthProviderConfig.oidc(issuer: 'https://sso.example.com'),
            ),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('browser_login_button')), findsOneWidget);
      expect(find.byKey(const Key('username_field')), findsNothing);
      expect(find.text('OIDC / SSO'), findsOneWidget);
    });

    testWidgets('shows browser button for auth0 provider', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(
              const AuthProviderConfig.auth0(
                domain: 'ex.auth0.com',
                clientId: 'cid',
              ),
            ),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('browser_login_button')), findsOneWidget);
      expect(find.text('Auth0'), findsOneWidget);
    });

    testWidgets('shows SSO button for SAML provider', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(
              const AuthProviderConfig.saml(
                loginUrl: 'https://idp.example.com/sso',
              ),
            ),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('browser_login_button')), findsOneWidget);
      expect(find.text('SAML SSO'), findsOneWidget);
      expect(find.text('SSOでログイン'), findsOneWidget);
    });

    testWidgets('shows credential form for firebase provider', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(
              const AuthProviderConfig.firebase(projectId: 'proj'),
            ),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('username_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.text('Firebase 認証'), findsOneWidget);
    });

    testWidgets('shows QR pairing link on all providers', (tester) async {
      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(const AuthProviderConfig.legacy()),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('qr_pairing_button')), findsOneWidget);
    });

    testWidgets('manual token section toggled by tap', (tester) async {
      // Set a taller viewport so all list items are rendered at once.
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          authProviderConfigNotifierProvider.overrideWith(
            () => _FakeConfigNotifier(const AuthProviderConfig.legacy()),
          ),
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfigNotifier(),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // Initially hidden.
      expect(find.byKey(const Key('manual_token_field')), findsNothing);

      // Tap toggle.
      await tester.tap(find.byKey(const Key('manual_token_toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('manual_token_field')), findsOneWidget);
      expect(find.byKey(const Key('manual_token_submit')), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeConfigNotifier extends AuthProviderConfigNotifier {
  _FakeConfigNotifier(this._initial);
  final AuthProviderConfig _initial;

  @override
  AuthProviderConfig build() => _initial;
}

class _FakeServerConfigNotifier extends ServerConfigNotifier {
  @override
  ServerConfig build() => const ServerConfig(
    baseUrl: 'https://saso.example.com',
    apiMode: ApiMode.rest,
  );
}

class _FakeAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();

  @override
  Future<AuthResult> loginWithCredentials({
    required String username,
    required String password,
  }) async => const AuthResult.failure(message: 'test');

  @override
  Future<AuthResult> loginWithBrowser() async =>
      const AuthResult.failure(message: 'test');
}
