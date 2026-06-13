import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val appApplicationId =
    providers.gradleProperty("NFC_LINK_MANAGER_APPLICATION_ID").orNull
        ?: throw GradleException(
            "Set NFC_LINK_MANAGER_APPLICATION_ID in a local Gradle property before building this app."
        )

val releaseStoreFile = providers.gradleProperty("NFC_LINK_MANAGER_RELEASE_STORE_FILE").orNull
val releaseStorePassword = providers.gradleProperty("NFC_LINK_MANAGER_RELEASE_STORE_PASSWORD").orNull
val releaseKeyAlias = providers.gradleProperty("NFC_LINK_MANAGER_RELEASE_KEY_ALIAS").orNull
val releaseKeyPassword = providers.gradleProperty("NFC_LINK_MANAGER_RELEASE_KEY_PASSWORD").orNull
val hasReleaseSigningConfig =
    !releaseStoreFile.isNullOrBlank() &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()

android {
    namespace = "app.nfclinkmanager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = appApplicationId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningConfig) {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigningConfig) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val hasReleaseTask = allTasks.any { task ->
        task.name.contains("Release", ignoreCase = true)
    }
    if (hasReleaseTask && !hasReleaseSigningConfig) {
        throw GradleException(
            "Release signing is not configured. Set NFC_LINK_MANAGER_RELEASE_STORE_FILE, " +
                "NFC_LINK_MANAGER_RELEASE_STORE_PASSWORD, NFC_LINK_MANAGER_RELEASE_KEY_ALIAS, " +
                "and NFC_LINK_MANAGER_RELEASE_KEY_PASSWORD as local Gradle properties."
        )
    }
}

flutter {
    source = "../.."
}
