#!/usr/bin/env bash
set -euo pipefail
cd "/c/Users/Windows/Documents/RACTECH - DESENVOLVEDORA DE APPS/APP-FACTORY-CONSTRUCAO/obrion-orcamentos"

echo "=== status ==="
git status --short

echo "=== add ==="
git add \
  android/app/build.gradle.kts \
  android/settings.gradle.kts \
  pubspec.yaml \
  pubspec.lock \
  lib/main.dart \
  CHANGELOG.md \
  CLAUDE.md

echo "=== commit ==="
git commit -m "feat: integra Firebase Crashlytics + Analytics (Fase 0); fecha Fases 0 e 1

- Adiciona firebase_core, firebase_crashlytics e firebase_analytics ao pubspec.
- Plugins Gradle com.google.gms.google-services e com.google.firebase.crashlytics aplicados.
- main(): Firebase.initializeApp() no boot; FlutterError.onError e PlatformDispatcher.onError redirecionados para o Crashlytics (cobre erros de Flutter e erros assíncronos de plataforma).
- google-services.json do projeto Firebase obrion-orcamentos commitado na raiz do Android (so identificador do app, nao e segredo).
- Sem firebase_options.dart ainda: so Android por ora. Quando entrar iOS/web, rodar flutterfire configure.

CHANGELOG/CLAUDE: marca PDF, compartilhamento, detalhes, duplicar/excluir, home util e Firebase; corrige tabela de roadmap duplicada; Fases 0 e 1 fechadas, proxima parada e Validacao."

echo "=== log ==="
git log --oneline -3
