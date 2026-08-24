plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "br.com.ractech.obrion.orcamentos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Exigido pelo flutter_local_notifications (lembrete de orçamento
        // aguardando resposta — ver CLAUDE.md, "Retenção precisa de
        // mecanismo") a partir da versão atual do pacote.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.com.ractech.obrion.orcamentos"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Exigido pelo flutter_local_notifications.
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Religado em 23/08/2026 — o motivo original de desligar (build
            // local lento nesta máquina) não existe mais desde que os
            // releases passaram a rodar na nuvem (GitHub Actions). Testar de
            // verdade num aparelho depois de cada mudança aqui: o R8 pode
            // cortar/renomear algo que só quebra em runtime, não no build.
            // Se algo parar de funcionar depois disto, o primeiro passo pra
            // diagnosticar é voltar isMinifyEnabled = false temporariamente
            // pra confirmar se a causa é o R8, e então adicionar uma regra
            // específica em proguard-rules.pro pro que quebrou.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Exigido pelo flutter_local_notifications (coreLibraryDesugaring acima).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
