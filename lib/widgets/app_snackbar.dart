import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// O que a ação significou — não a cor em si. O ícone muda de forma
/// (check/lixeira/alerta) em vez de só cor, pra não depender só de cor
/// pra transmitir o significado (acessibilidade) e pra ficar legível em
/// qualquer combinação de tema.
enum AppSnackBarVariant { success, destructive, warning }

/// Feedback padrão de ação (ver docs/APP_FACTORY_CORE.md, UI Components).
/// Nunca montar `SnackBar(content: Text(...))` cru numa tela — sempre
/// aqui, pra toda confirmação de salvar/excluir no app ter o mesmo ícone
/// e peso visual, em vez de cada tela reinventar o próprio texto solto.
class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarVariant variant = AppSnackBarVariant.success,
  }) {
    final icon = switch (variant) {
      AppSnackBarVariant.success => Icons.check_circle_outline,
      AppSnackBarVariant.destructive => Icons.delete_outline,
      AppSnackBarVariant.warning => Icons.error_outline,
    };
    final onSnackBarColor = Theme.of(context).colorScheme.onInverseSurface;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, size: 20, color: onSnackBarColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
