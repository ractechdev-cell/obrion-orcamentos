plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "br.com.ractech.obrion.orcamentos"
    compileSdk = 35
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
        targetSdk = 35
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
            // Desligado de novo em 24/08/2026 — religado em 23/08 sem nunca
            // ter sido testado num aparelho real, e foi exatamente o
            // problema previsto neste comentário: app instalado a partir de
            // um build R8 ficava travado em tela branca (Firebase.initializeApp()
            // trava antes de runApp() rodar, sem handler de erro do Flutter
            // ativo ainda — sintoma clássico de classe removida/renomeada
            // pelo R8 que o Firebase precisa achar via reflexão em runtime).
            // Voltar a religar exige: 1) regra de -keep específica pros
            // componentes de descoberta do Firebase em proguard-rules.pro,
            // 2) testar instalando de verdade num aparelho antes de
            // considerar resolvido — nunca só confiar em build verde da CI,
            // que não pega esse tipo de erro (roda flutter test, não o APK).
            isMinifyEnabled = false
            isShrinkResources = false
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
