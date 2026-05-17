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
    compileSdk = flutter.compileSdkVersion
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
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
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
