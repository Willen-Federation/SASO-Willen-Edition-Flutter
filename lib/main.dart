import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/feature_flags/feature_flag_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Issue #126 — Portrait-only operation across iPhone / iPad / Android.
  //
  // SASO Willen Edition is a handheld inventory terminal: barcode scanning
  // is performed one-handed, the camera viewfinder and forms are laid out
  // vertically, and we have not designed/verified landscape layouts for
  // the scanner overlay, soft-keyboard forms, or settings drill-downs.
  // Locking the preferred orientations here is the cross-platform
  // counterpart to the iOS `UISupportedInterfaceOrientations` declaration
  // in `ios/Runner/Info.plist` and Android's
  // `android:screenOrientation="portrait"` on `MainActivity`.
  //
  // `portraitUp` + `portraitDown` is intentional: the OS naturally avoids
  // rotating to upside-down on iPhones with a Home indicator, while still
  // allowing rotation on iPads / split-view scenarios where the system
  // honours auto-rotate. To strictly forbid upside-down across the board,
  // remove `portraitDown` — but be aware that this also blocks the
  // accessibility "rotation lock = upside-down" feature.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
