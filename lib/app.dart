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
        // Follow the OS appearance setting (Light / Dark / Automatic on
        // iOS, "Use device theme" on Android). Explicitly set rather than
        // relying on the default so the intent is visible in code review
        // and a future copy-paste into a different MaterialApp doesn't
        // silently drop dark-mode support. Issue #130 / Apple HIG dark
        // appearance requirement.
        // ignore: avoid_redundant_argument_values
        themeMode: ThemeMode.system,
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
        // Issue #133 — Dynamic Type / Display Size audit.
        //
        // The OS-level "Larger Text" (iOS) and "Display size" (Android)
        // settings can push the text scale factor up to ~3.0 on the most
        // accessible end. Letting the scaler run all the way to 3.0
        // breaks dense screens (drill-down lists, scanner overlay,
        // forms) because labels overflow and form fields get clipped.
        // We honour the user's preference *up to* 1.4× — the WCAG 2.2
        // "Resize Text" success criterion (1.4.4) only requires up to
        // 200% scaling without loss of content, so 1.4× preserves the
        // intent while keeping layouts legible. Above 1.4× the OS
        // accessibility "Bold Text" + Display Size settings still apply
        // through the underlying ThemeData.
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final clampedScaler = mediaQuery.textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.4,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScaler),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
