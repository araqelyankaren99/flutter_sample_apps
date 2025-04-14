plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_sample_apps"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_sample_apps"
        minSdk = 30
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += setOf("arm64-v8a", "armeabi-v7a", "x86", "x86_64")
        }

        externalNativeBuild {
            cmake {
                cppFlags += listOf("-frtti", "-fexceptions", "-std=c++11")
                arguments += listOf("-DANDROID_STL=c++_shared")
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("../CMakeLists.txt")
        }
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/opencv")
        }
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
