group = "com.perkox.perkox_flutter_sdk"
version = "2.0.0"

plugins {
    id("com.android.library")
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://www.jitpack.io") }
}

android {
    namespace = "com.perkox.perkox_flutter_sdk"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 21
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Perkox Android Native SDK via JitPack
    implementation("com.perkox:perkox-android-sdk-releases:2.0.2")

    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.gms:play-services-ads-identifier:18.0.1")
}
