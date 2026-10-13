plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ayovaani.ayo_vani"
    compileSdk = 35
    buildToolsVersion = "35.0.0"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ayovaani.ayo_vani"
        // Target modern Android API levels with arm64-v8a ABI requirement
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    androidResources {
        noCompress += listOf(
            "onnx",
            "model",
            "txt",
            "wav",
            "dict",
            "phondata",
            "phonindex",
            "phontab",
            "intonations",
            "manifest",
            "bin"
        )
    }

    buildTypes {
        release {
            // Signing with the debug keys for local deployment and verification
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        jniLibs {
            pickFirsts.add("**/libonnxruntime.so")
            pickFirsts.add("**/libc++_shared.so")
            pickFirsts.add("**/libsherpa-onnx-*.so")
            pickFirsts.add("lib/**/libonnxruntime.so")
            pickFirsts.add("lib/**/libc++_shared.so")
            pickFirsts.add("lib/**/libsherpa-onnx-c-api.so")
            pickFirsts.add("lib/**/libsherpa-onnx-cxx-api.so")
            pickFirsts.add("lib/**/libsherpa-onnx-jni.so")
            pickFirsts.add("lib/**/libsherpa-onnx-*.so")
        }
    }
}

flutter {
    source = "../.."
}
