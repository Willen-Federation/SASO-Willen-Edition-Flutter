import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../assets/l10n/app_localizations.dart';
import 'core/push/push_notification_startup.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class SasoApp extends ConsumerWidget {
  const SasoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return PushNotificationStartup(
      child: MaterialApp.router(
        title: 'SASO Willen',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
      ),
    );
  }
}
