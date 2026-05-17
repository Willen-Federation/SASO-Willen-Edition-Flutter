# SASO release-build R8 / ProGuard rules.
#
# Flutter / Dart plugin glue. Reflection from the Flutter engine into
# generated plugin registrants must keep symbol names.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase reflection (analytics, messaging, remote config use
# reflection over generated init providers).
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# AWS Amplify / Cognito SDK uses generic reflection over annotation
# processors. The catch-all keep is heavy but matches AWS's own
# published consumer rules.
-keep class com.amazonaws.** { *; }
-keep class com.amplifyframework.** { *; }
-dontwarn com.amazonaws.**
-dontwarn com.amplifyframework.**

# Auth0 native SDK.
-keep class com.auth0.android.** { *; }
-dontwarn com.auth0.android.**

# flutter_web_auth_2 CallbackActivity — referenced from AndroidManifest
# via fully qualified class name; ensure it survives shrinking.
-keep class com.linusu.flutter_web_auth_2.** { *; }

# mobile_scanner — AVFoundation/Vision Java bridge classes.
-keep class dev.steenbakker.mobile_scanner.** { *; }
