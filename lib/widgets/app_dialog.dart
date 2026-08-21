import 'package:flutter/material.dart';

import 'app_button.dart';

/// Confirmações e alertas padronizados (ver docs/APP_FACTORY_CORE.md, UI
/// Components). Nunca chamar `showDialog` com um `AlertDialog` cru numa
/// tela — sempre via `AppDialog.confirm`/`AppDialog.alert`.
class AppDialog {
  const AppDialog._();

  /// Diálogo de confirmação com ação destrutiva/neutra. Retorna `true` se
  /// o usuário confirmou, `false`/`null` caso contrário.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  /// Diálogo informativo com um único botão de fechar.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String closeLabel = 'Ok',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: closeLabel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
