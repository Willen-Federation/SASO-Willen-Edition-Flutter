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

ServerAuthDiscovery _discovery({
  required AuthStrategy strategy,
  required List<AuthProviderSummary> providers,
  String serverName = 'Test Server',
  String mobileSetupUrl = 'https://saso.example.com/m/setup',
}) => ServerAuthDiscovery(
  serverName: serverName,
  version: '0.0.0',
  mobileSetupUrl: mobileSetupUrl,
  authStrategy: strategy,
  providers: providers,
);

const _localProvider = AuthProviderSummary(
  id: 1,
  name: 'Local',
  type: AuthProviderType.local,
  isDefault: true,
  enabled: true,
);

void main() {
  group('LoginPage — discovery-driven layout', () {
    testWidgets('shows credential form when local is enabled', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          serverAuthDiscoveryNotifierProvider.overrideWith(
            () => _FakeDiscoveryNotifier(
              _discovery(
                strategy: AuthStrategy.localOnly,
                providers: const [_localProvider],
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

      expect(find.byKey(const Key('username_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.text('ユーザー名でログイン'), findsOneWidget);
    });

    testWidgets(
      'hides credential form when local is absent in legacy API mode',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const LoginPage(), [
            serverAuthDiscoveryNotifierProvider.overrideWith(
              () => _FakeDiscoveryNotifier(
                _discovery(
                  strategy: AuthStrategy.defaultOnly,
                  providers: const [
                    AuthProviderSummary(
                      id: 5,
                      name: 'Corporate SSO',
                      type: AuthProviderType.oidc,
                      isDefault: true,
                      enabled: true,
                    ),
                  ],
                ),
              ),
            ),
            serverConfigNotifierProvider.overrideWith(
              // Legacy mode — discovery is the only signal that should
              // surface the credential form. With no local in discovery
              // we expect the form to be hidden.
              () => _FakeServerConfigNotifier(apiMode: ApiMode.legacy),
            ),
            authStateNotifierProvider.overrideWith(
              () => _FakeAuthStateNotifier(),
            ),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('username_field')), findsNothing);
        expect(find.byKey(const Key('provider_button_5')), findsOneWidget);
        expect(find.text('Corporate SSO'), findsOneWidget);
      },
    );

    testWidgets(
      'shows credential form in REST mode even when discovery omits local',
      (tester) async {
        // Mirrors the current saso.sksl.jp production discovery payload:
        // a single OIDC provider with no `local` entry. /api/v1/auth/login
        // (PR-A3) is still available against this server, so the form
        // MUST render to let the user authenticate with username/password.
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const LoginPage(), [
            serverAuthDiscoveryNotifierProvider.overrideWith(
              () => _FakeDiscoveryNotifier(
                _discovery(
                  strategy: AuthStrategy.userChoice,
                  providers: const [
                    AuthProviderSummary(
                      id: 1,
                      name: 'デフォルトログイン',
                      type: AuthProviderType.oidc,
                      isDefault: false,
                      enabled: true,
                    ),
                  ],
                ),
              ),
            ),
            serverConfigNotifierProvider.overrideWith(
              // REST is the default for _FakeServerConfigNotifier; named
              // here for documentation, matching the production saso.sksl.jp
              // config.
              // ignore: avoid_redundant_argument_values
              () => _FakeServerConfigNotifier(apiMode: ApiMode.rest),
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
        // The OIDC provider button must still be rendered alongside the
        // credential form so the user can pick either path.
        expect(find.byKey(const Key('provider_button_1')), findsOneWidget);
      },
    );

    testWidgets(
      'shows both credential form and provider buttons on user-choice',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const LoginPage(), [
            serverAuthDiscoveryNotifierProvider.overrideWith(
              () => _FakeDiscoveryNotifier(
                _discovery(
                  strategy: AuthStrategy.userChoice,
                  providers: const [
                    _localProvider,
                    AuthProviderSummary(
                      id: 2,
                      name: 'Google',
                      type: AuthProviderType.oidc,
                      isDefault: false,
                      enabled: true,
                    ),
                    AuthProviderSummary(
                      id: 3,
                      name: 'Okta',
                      type: AuthProviderType.saml,
                      isDefault: false,
                      enabled: true,
                    ),
                  ],
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

        expect(find.byKey(const Key('username_field')), findsOneWidget);
        expect(find.byKey(const Key('provider_button_2')), findsOneWidget);
        expect(find.byKey(const Key('provider_button_3')), findsOneWidget);
        expect(find.text('Google'), findsOneWidget);
        expect(find.text('Okta'), findsOneWidget);
      },
    );

    testWidgets('QR pairing + manual token are always present', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          serverAuthDiscoveryNotifierProvider.overrideWith(
            () => _FakeDiscoveryNotifier(
              _discovery(
                strategy: AuthStrategy.localOnly,
                providers: const [_localProvider],
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

      expect(find.byKey(const Key('qr_pairing_button')), findsOneWidget);
      expect(find.byKey(const Key('manual_token_toggle')), findsOneWidget);
    });

    testWidgets(
      'Auth0 button renders when discovery returns enabled Auth0 with config',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const LoginPage(), [
            serverAuthDiscoveryNotifierProvider.overrideWith(
              () => _FakeDiscoveryNotifier(
                _discovery(
                  strategy: AuthStrategy.userChoice,
                  providers: const [
                    _localProvider,
                    AuthProviderSummary(
                      id: 9,
                      name: 'Acme Workforce',
                      type: AuthProviderType.auth0,
                      isDefault: false,
                      enabled: true,
                      config: {
                        'domain': 'acme.auth0.com',
                        'clientId': 'pubClientId123',
                      },
                    ),
                  ],
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

        expect(find.byKey(const Key('auth0_login_button')), findsOneWidget);
        expect(find.text('Acme Workforce'), findsOneWidget);
        // Auth0 must not also appear in the generic provider list — the
        // dedicated button is the only entry point.
        expect(find.byKey(const Key('provider_button_9')), findsNothing);
      },
    );

    testWidgets(
      'Auth0 button is hidden when discovery does not include Auth0',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const LoginPage(), [
            serverAuthDiscoveryNotifierProvider.overrideWith(
              () => _FakeDiscoveryNotifier(
                _discovery(
                  strategy: AuthStrategy.localOnly,
                  providers: const [_localProvider],
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

        expect(find.byKey(const Key('auth0_login_button')), findsNothing);
      },
    );

    testWidgets(
      'Auth0 button is hidden when domain/clientId config is missing',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const LoginPage(), [
            serverAuthDiscoveryNotifierProvider.overrideWith(
              () => _FakeDiscoveryNotifier(
                _discovery(
                  strategy: AuthStrategy.userChoice,
                  providers: const [
                    _localProvider,
                    // Auth0 advertised but no domain/clientId — must not
                    // surface a button the native SDK can't actually use.
                    AuthProviderSummary(
                      id: 9,
                      name: 'Auth0',
                      type: AuthProviderType.auth0,
                      isDefault: false,
                      enabled: true,
                    ),
                  ],
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

        expect(find.byKey(const Key('auth0_login_button')), findsNothing);
      },
    );

    testWidgets('manual token field toggles open', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(const LoginPage(), [
          serverAuthDiscoveryNotifierProvider.overrideWith(
            () => _FakeDiscoveryNotifier(
              _discovery(
                strategy: AuthStrategy.localOnly,
                providers: const [_localProvider],
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

      expect(find.byKey(const Key('manual_token_field')), findsNothing);

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

class _FakeDiscoveryNotifier extends ServerAuthDiscoveryNotifier {
  _FakeDiscoveryNotifier(this._initial);
  final ServerAuthDiscovery _initial;

  @override
  ServerAuthDiscovery build() => _initial;
}

class _FakeServerConfigNotifier extends ServerConfigNotifier {
  _FakeServerConfigNotifier({this.apiMode = ApiMode.rest});

  final ApiMode apiMode;

  @override
  ServerConfig build() =>
      ServerConfig(baseUrl: 'https://saso.example.com', apiMode: apiMode);
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
  Future<AuthResult> loginWithQrToken({
    required String pairingToken,
    required String serverUrl,
  }) async => const AuthResult.failure(message: 'test');
}
