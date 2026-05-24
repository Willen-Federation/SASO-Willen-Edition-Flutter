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

# webview_flutter — WebChromeClient / WebViewClient subclasses are
# instantiated via reflection by the platform when loading WebViews;
# R8 must not rename or strip these.
-keep class io.flutter.plugins.webviewflutter.** { *; }
-keep class * extends android.webkit.WebChromeClient { *; }
-keep class * extends android.webkit.WebViewClient { *; }

# connectivity_plus — registers a BroadcastReceiver whose class name is
# referenced from the manifest at runtime.
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# image_picker — FileProvider / Intent extras serialised by name.
-keep class io.flutter.plugins.imagepicker.** { *; }

# url_launcher — Intent serialisation across processes.
-keep class io.flutter.plugins.urllauncher.** { *; }

# shared_preferences — preferences XML deserialised by class name.
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Catch-all for Flutter plugin registrants and the embedding engine
# plugin lifecycle. Defends against transitive plugin classes that are
# referenced reflectively from generated GeneratedPluginRegistrant.
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }

# Parcelable CREATOR fields are read reflectively by the framework when
# unmarshalling Parcels. Without this rule R8 may rename or strip them
# from app-defined Parcelable subclasses.
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
