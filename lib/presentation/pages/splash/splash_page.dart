import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_discovery_service.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Load persisted server config (URL, API mode, refresh token, etc.).
    await ref.read(serverConfigNotifierProvider.notifier).load();
    if (!mounted) return;

    final config = ref.read(serverConfigNotifierProvider);

    // 2. Mock mode: skip auth entirely.
    if (config.apiMode == ApiMode.mock) {
      context.go('/home');
      return;
    }

    // 3. No server URL: show Getting Started onboarding on first launch.
    if (config.baseUrl.isEmpty) {
      context.go('/onboarding');
      return;
    }

    // 4. Discover which auth providers the server has enabled.
    final discovery = await AuthDiscoveryService().discover(config.baseUrl);
    if (!mounted) return;
    ref.read(serverAuthDiscoveryNotifierProvider.notifier).set(discovery);

    // 5. Attempt to restore credentials from secure storage (JWT / cookie).
    await ref.read(authStateNotifierProvider.notifier).loadStoredCredentials();
    if (!mounted) return;

    final authState = ref.read(authStateNotifierProvider);
    if (authState.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash has no AppBar, so Flutter does not auto-clear the notch /
    // Dynamic Island area for us. Wrap the body in SafeArea so the logo
    // never collides with system insets on iPhone X+ / Android cutouts.
    //
    // Pair this with AnnotatedRegion so the status bar icons stay dark on
    // the light (Scaffold background) splash; without this, devices that
    // launched the app in dark UI mode keep light icons and become
    // invisible against the white background.
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/branding/saso-full-512.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
