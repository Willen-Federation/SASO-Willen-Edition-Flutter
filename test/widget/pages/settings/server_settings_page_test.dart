// PR-B2: verifies that the deprecation surfaces for ApiMode.legacy render as
// designed — banner above the chooser when legacy is the active mode, and the
// legacy radio living inside a collapsed "Compatibility mode (deprecated)"
// expansion tile instead of the primary radio row.
//
// The settings page renders REST mode as a banner with no chooser at all
// (that's the production / shipped state), so the visibility tests below
// exercise mock mode + legacy mode: those are the two cases where the
// chooser actually appears on screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/auth/auth_service.dart';
import 'package:saso_willen_edition/core/feature_flags/feature_flag_service.dart';
import 'package:saso_willen_edition/core/feature_flags/providers/debug_flag_provider.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:saso_willen_edition/presentation/pages/settings/server_settings_page.dart';
import 'package:saso_willen_edition/presentation/providers/auth_state_provider.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

Widget _wrap(Widget child, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
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

  group('ServerSettingsPage — ApiMode deprecation UI (PR-B2)', () {
    testWidgets('in mock mode the primary radios show only mock and rest, '
        'and legacy lives inside a collapsed compatibility section', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
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

      // Deprecation banner must NOT show when not in legacy mode.
      expect(find.byKey(const Key('legacy_deprecation_banner')), findsNothing);

      // Compatibility section header is rendered…
      expect(
        find.byKey(const Key('compatibility_mode_section')),
        findsOneWidget,
      );

      // …but its radio child is hidden until the user expands it. The
      // primary radio area lists only Mock + REST.
      expect(find.text('Mock (no server needed)'), findsOneWidget);
      expect(find.text('REST v1'), findsOneWidget);
      // "Legacy (deprecated)" radio label not visible while collapsed.
      expect(find.text('Legacy (deprecated)'), findsNothing);
    });

    testWidgets(
      'expanding the compatibility section reveals the legacy radio',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 2000));
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

        await tester.tap(find.byKey(const Key('compatibility_mode_section')));
        await tester.pumpAndSettle();

        expect(find.text('Legacy (deprecated)'), findsOneWidget);
      },
    );

    testWidgets(
      'in legacy mode the deprecation banner is shown above the chooser',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 2000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap(const ServerSettingsPage(), [
            serverConfigNotifierProvider.overrideWith(
              // ignore: deprecated_member_use_from_same_package
              () => _FakeServerConfig(ApiMode.legacy),
            ),
            authStateNotifierProvider.overrideWith(
              () => _FakeAuthStateNotifier(),
            ),
          ]),
        );
        await tester.pumpAndSettle();

        // Banner visible.
        expect(
          find.byKey(const Key('legacy_deprecation_banner')),
          findsOneWidget,
        );

        // Compatibility section is initially expanded so the user can see
        // their current selection without an extra tap.
        expect(find.text('Legacy (deprecated)'), findsOneWidget);
      },
    );
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
