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

    // 3. No server URL: must configure first.
    if (config.baseUrl.isEmpty) {
      context.go('/settings');
      return;
    }

    // 4. Discover which auth provider the server has enabled.
    final providerConfig =
        await AuthDiscoveryService().discover(config.baseUrl);
    if (!mounted) return;
    ref.read(authProviderConfigNotifierProvider.notifier).set(providerConfig);

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
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64),
          SizedBox(height: 16),
          Text(
            'SASO Willen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 32),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}
