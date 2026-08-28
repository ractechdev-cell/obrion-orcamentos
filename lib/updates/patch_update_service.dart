import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Serviço de atualização OTA via Shorebird — checa patches disponíveis,
/// baixa e reinicia o app automaticamente quando pronto.
///
/// Por padrão, o Shorebird baixa patches em background no startup mas
/// só aplica no próximo launch. Este serviço contorna isso chamando
/// `update()` (que baixa + instala) e depois reiniciando de verdade via
/// `Restart.restartApp()` (pacote `restart_app`) — mata o processo e o
/// Android relança a Activity sozinho, sem o usuário tocar em nada.
///
/// `SystemNavigator.pop()` **não resolve isso**: só encerra/manda a
/// activity pra segundo plano, não mata o processo, então o Flutter
/// engine nunca recarrega o `libapp.so` com o patch novo — o usuário
/// ainda precisava reabrir manualmente. Achado em teste real no
/// aparelho (28/08/2026).
///
/// **Quando patchear vs release completo:**
/// - Patch: mudança só em código Dart (Widgets, lógica, UI)
/// - Release: mudança em `android/`, `ios/`, plugin nativo, assets,
///   ou upgrade do Flutter engine — ver CLAUDE.md, decisão 6.
/// `restart_app` tem código nativo Android/Kotlin — adicioná-lo pela
/// primeira vez é, ele mesmo, uma mudança nativa (exige release
/// completo uma única vez; depois disso volta a ser tudo patch OTA).
class PatchUpdateService {
  const PatchUpdateService._();

  static final _updater = ShorebirdUpdater();
  static bool _checking = false;

  /// Checa se há patch disponível e, se houver, baixa e reinicia.
  /// Chamado no boot do app. Nunca lança exceção — falha silenciosa.
  ///
  /// Retorna `true` se um patch foi aplicado e o app vai reiniciar,
  /// `false` se não havia patch ou não era possível checar.
  static Future<bool> checkAndUpdate() async {
    if (_checking) return false;
    if (!_updater.isAvailable) return false;
    _checking = true;

    try {
      final currentPatch = await _updater.readCurrentPatch();
      debugPrint(
        '[PatchUpdate] Patch atual: ${currentPatch?.number ?? "nenhum"}',
      );

      // checkForUpdate() retorna UpdateStatus:
      // - upToDate: já está na versão mais nova
      // - outdated: há patch disponível pra baixar
      // - restartRequired: patch já baixado, precisa reiniciar
      // - unavailable: Shorebird não disponível neste build
      final status = await _updater.checkForUpdate();

      debugPrint('[PatchUpdate] Status: ${status.name}');

      switch (status) {
        case UpdateStatus.upToDate:
          _checking = false;
          return false;

        case UpdateStatus.outdated:
          // Há patch disponível — baixa e instala
          debugPrint('[PatchUpdate] Baixando patch...');
          await _updater.update();
          debugPrint('[PatchUpdate] Patch baixado. Reiniciando...');
          await _restartApp();
          return true;

        case UpdateStatus.restartRequired:
          // Patch já baixado, só precisa reiniciar
          debugPrint('[PatchUpdate] Patch já baixado. Reiniciando...');
          await _restartApp();
          return true;

        case UpdateStatus.unavailable:
          _checking = false;
          return false;
      }
    } catch (error, stack) {
      // Nunca pode travar o app por causa de atualização.
      if (kDebugMode) {
        debugPrint('[PatchUpdate] Erro: $error\n$stack');
      }
      _checking = false;
      return false;
    }
  }

  /// Reinicia o processo de verdade (mata e relança a Activity no
  /// Android) — é o que faz o Flutter engine recarregar o patch já
  /// baixado. Nunca lança: se o restart falhar por algum motivo (ex.:
  /// build sandboxed), o app continua rodando com o código antigo em
  /// vez de travar.
  static Future<void> _restartApp() async {
    try {
      await Restart.restartApp();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[PatchUpdate] Restart falhou: $error\n$stack');
      }
    }
  }

  /// Lê o número do patch atual (para exibir na UI).
  static Future<int?> getCurrentPatchNumber() async {
    if (!_updater.isAvailable) return null;
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } catch (_) {
      return null;
    }
  }
}
