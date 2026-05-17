import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
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
        // Issue #21 — register the generated AppLocalizations delegate
        // alongside the Material / Cupertino delegates so any
        // `AppLocalizations.of(context).<key>` lookup resolves against
        // assets/l10n/app_ja.arb (and the en variant). Without this
        // delegate the .arb files exist but are dead.
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja'), Locale('en')],
        locale: const Locale('ja'),
      ),
    );
  }
}
