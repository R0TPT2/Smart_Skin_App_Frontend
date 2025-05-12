plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.skin_cancer"
    compileSdk = 35 // Use integer value instead of flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.skin_cancer"
        minSdk = 24 // Minimum supported by TensorFlow Lite Flex
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }

        multiDexEnabled = true // Moved inside defaultConfig [[9]]
    }

    buildTypes {
        getByName("release") { // Correct syntax for build types [[3]]
            isMinifyEnabled = true // Use 'is' prefix for boolean properties
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    aaptOptions {
        noCompress.add("tflite") // Correct syntax for adding extensions [[6]]
    }
}

// Dependencies moved outside android block [[7]]
dependencies {
    implementation("org.tensorflow:tensorflow-lite:2.14.0")
    implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.14.0")
    implementation("androidx.multidex:multidex:2.0.1") // Explicit multidex dependency [[9]]
}

flutter {
    source = "../.."
}