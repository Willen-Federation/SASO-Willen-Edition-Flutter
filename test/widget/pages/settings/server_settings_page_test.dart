import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/auth/auth_service.dart';
import 'package:saso_willen_edition/core/feature_flags/feature_flag_service.dart';
import 'package:saso_willen_edition/core/feature_flags/providers/debug_flag_provider.dart';
import 'package:saso_willen_edition/core/theme/app_theme.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:saso_willen_edition/presentation/pages/settings/server_settings_page.dart';
import 'package:saso_willen_edition/presentation/providers/auth_state_provider.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

Widget _wrap(Widget child, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  ),
);

void main() {
  setUpAll(() {
    // Settings page reads FeatureFlagService.instance during initState; the
    // service throws an assertion until initialized. We don't exercise any
    // flag-driven branches here, so a DebugFlagProvider (returns defaults)
    // is enough to satisfy the singleton.
    FeatureFlagService.instance.setProviderForTesting(DebugFlagProvider());
  });

  group('ServerSettingsPage — privacy policy (#122)', () {
    testWidgets(
      'privacy policy tile is rendered in mock mode so it is reachable '
      'before the user logs in',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 3000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const ServerSettingsPage(), [
            serverConfigNotifierProvider.overrideWith(
              () => _FakeServerConfig(ApiMode.mock),
            ),
            authStateNotifierProvider.overrideWith(
              () => _FakeAuthStateNotifier(),
            ),
          ]),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('privacy_policy_tile')), findsOneWidget);
        expect(find.text('Privacy Policy'), findsOneWidget);
      },
    );

    testWidgets('privacy policy tile is also rendered in REST mode', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(const ServerSettingsPage(), [
          serverConfigNotifierProvider.overrideWith(
            () => _FakeServerConfig(ApiMode.rest),
          ),
          authStateNotifierProvider.overrideWith(
            () => _FakeAuthStateNotifier(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('privacy_policy_tile')), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeServerConfig extends ServerConfigNotifier {
  _FakeServerConfig(this._mode);
  final ApiMode _mode;

  @override
  ServerConfig build() =>
      ServerConfig(baseUrl: 'https://saso.example.com', apiMode: _mode);
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
