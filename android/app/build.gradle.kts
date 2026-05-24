import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release-signing properties loaded from android/key.properties (gitignored).
// Expected keys: storeFile, storePassword, keyAlias, keyPassword.
val keystoreProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        load(propertiesFile.inputStream())
    }
}

android {
    namespace = "jp.willen.saso.saso_willen_edition"
    // Explicit compileSdk pinned to Android 15 (API 35). Google Play requires
    // targetSdk >= 35 for new app submissions and updates from 2025-08-31.
    // See https://developer.android.com/google/play/requirements/target-sdk.
    // Pinning compileSdk to the same level keeps build-time API surface aligned
    // with the runtime target and prevents Flutter SDK upgrades from silently
    // bumping the value.
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Amplify SDK (push notifications, annotations, common-core) uses
        // Java 8 API surface (java.time, etc.) that is not available below
        // API 26 without desugaring. Enabling this lets D8/R8 rewrite those
        // calls so they work down to minSdk 21.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "jp.willen.saso.saso_willen_edition"
        // Explicit SDK levels (issue #140) — do not delegate to
        // `flutter.minSdkVersion` / `flutter.targetSdkVersion` because those
        // track the installed Flutter SDK and would shift unexpectedly on
        // `flutter pub upgrade --major-versions` or Flutter channel changes.
        //
        // minSdk 21 (Android 5.0) — kept in sync with
        // `flutter_launcher_icons.min_sdk_android: 21` in pubspec.yaml.
        // Amplify SDK uses Java 8 API surface (java.time, …) which works on
        // API 21 only via the desugaring enabled above (compileOptions).
        //
        // targetSdk 35 (Android 15) — required by Google Play from 2025-08-31
        // for new submissions and updates.
        // https://developer.android.com/google/play/requirements/target-sdk
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Manifest placeholders required by auth0_flutter and flutter_appauth /
        // net.openid.appauth libraries. The actual Auth0 tenant domain is
        // fetched from the server's /api/v1/auth/providers at runtime, so a
        // build-time placeholder is sufficient for the manifest merger to pass.
        // Override auth0Domain per build flavour / CI when publishing.
        manifestPlaceholders["auth0Domain"] = "placeholder.auth0.com"
        manifestPlaceholders["auth0Scheme"] = "jp.willen.saso"
        manifestPlaceholders["appAuthRedirectScheme"] = "jp.willen.saso"
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Real release-signing config when key.properties is populated.
            // Falls back to the debug keystore for `flutter run --release`
            // when no key.properties exists. Production / Play Store
            // releases MUST be built with a real keystore — see #22.
            signingConfig = if (keystoreProperties["storeFile"] != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // R8 minification + resource shrinking. Removes unused
            // classes / resources and renames symbols, lowering the
            // cost of reverse engineering and shrinking the APK by
            // several MB on this dep set.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for Amplify SDK JARs that use java.time / java.util.function
    // APIs on devices below API 26 (minSdk 21). Must be kept in sync with the
    // AGP version — desugar_jdk_libs 2.x works with AGP 8.9.x.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
