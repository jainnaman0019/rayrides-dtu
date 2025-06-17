plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_ride_app"
    compileSdk = 35  // Explicit value instead of flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Explicit NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8  // Changed from 11 to 1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"  // Changed from 11 to 1.8
    }

    defaultConfig {
        applicationId = "com.example.flutter_ride_app"
        minSdk = 21  // Explicit value instead of flutter.minSdkVersion
        targetSdk = 35  // Explicit value instead of flutter.targetSdkVersion
        versionCode = 1  // Explicit value instead of flutter.versionCode
        versionName = "1.0"  // Explicit value instead of flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}