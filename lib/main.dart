import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/feature_flags/feature_flag_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Issue #146 — Android 15 edge-to-edge enforcement.
  //
  // Starting with Android 15 (API 35) the system draws app content behind
  // the status bar and gesture-navigation bar by default; the legacy
  // `windowDrawsSystemBarBackgrounds=false` opt-out is ignored. We
  // explicitly opt in to `SystemUiMode.edgeToEdge` so behaviour is
  // consistent on older Android versions and iOS as well, and request
  // transparent system bars so the app's background colour shows
  // through. `systemNavigationBarContrastEnforced=false` disables the
  // automatic scrim Android otherwise paints behind the gesture bar,
  // which would defeat the transparent setting. Individual pages wrap
  // their `Scaffold` body in `SafeArea` to keep content clear of the
  // system bars and gesture inset.
  //
  // See: https://developer.android.com/about/versions/15/behavior-changes-15#edge-to-edge
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Firebase: FCM + Remote Config + Auth
  // Requires GoogleService-Info.plist (iOS) and google-services.json (Android)
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured — app continues in mock/offline mode
  }

  // Feature flags: Debug→all ON, Release→Firebase Remote Config
  await FeatureFlagService.instance.initialize();

  runApp(const ProviderScope(child: SasoApp()));
}
