import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) => Scaffold(
    body: Center(
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
  );
}
