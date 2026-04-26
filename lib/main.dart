import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/feature_flags/feature_flag_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
