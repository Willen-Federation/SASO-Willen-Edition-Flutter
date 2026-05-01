import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../presentation/providers/server_config_provider.dart';

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
    await ref.read(serverConfigNotifierProvider.notifier).load();
    final config = ref.read(serverConfigNotifierProvider);
    final secure = ref.read(secureStorageProvider);
    final jwt = await secure.read(AppConstants.jwtTokenKey);

    // First-run gate: if the user has not completed mobile registration
    // (no JWT yet) and the app is configured to use a real server, send
    // them to /register. Mock mode is the developer default and skips it.
    final needsRegistration = jwt == null && config.apiMode != ApiMode.mock;

    if (!mounted) return;
    context.go(needsRegistration ? '/register' : '/home');
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
