import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        // Os botões ocupam a largura toda (48px de altura, regra do
        // design), então o `OverflowBar` do `AlertDialog` sempre os
        // empilha. Sem este espaçamento eles ficam colados, e "Cancelar"
        // encosta em "Confirmar" — perigoso quando a confirmação é
        // destrutiva e o toque é de mão suja/de luva.
        actionsOverflowButtonSpacing: AppSpacing.sm,
        actions: [
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          if (isDestructive)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(confirmLabel),
            )
          else
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
