plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.project.uap"

    // ✅ WAJIB: dependency kamu minta compileSdk 36
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.project.uap"

        // ✅ minSdk tetap aman dari flutter (umumnya 21)
        minSdk = flutter.minSdkVersion

        // ✅ targetSdk disarankan sama dengan compileSdk biar konsisten
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // ⚠️ masih debug signing (buat test apk release).
            // Untuk Play Store nanti ganti ke keystore release.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
