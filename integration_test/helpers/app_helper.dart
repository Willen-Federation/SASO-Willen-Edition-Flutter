import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/app.dart';
import 'package:saso_willen_edition/presentation/providers/server_config_provider.dart';

class _MockModeConfig extends ServerConfigNotifier {
  @override
  ServerConfig build() => const ServerConfig(apiMode: ApiMode.mock);
}

/// Pumps the full app in mock mode for integration tests.
Future<void> pumpAppInMockMode(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        serverConfigNotifierProvider.overrideWith(() => _MockModeConfig()),
      ],
      child: const SasoApp(),
    ),
  );
}
