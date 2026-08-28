import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Estilo de campo de entrada do design system Safety Industrial.
///
/// Campo **preenchido**, com barra inferior que engrossa e fica âmbar no
/// foco, e altura mínima de 56px para dar área de toque generosa.
///
/// Duas escolhas aqui vieram de um erro concreto, e não convém desfazer
/// sem entender o porquê:
///
/// 1. **O preenchimento é `surfaceContainerHigh`, mais escuro que o fundo
///    da página.** A primeira versão usava `surfaceContainerLow` — a
///    mesma cor do `scaffoldBackgroundColor` —, então os campos ficavam
///    literalmente invisíveis nos formulários: sobrava só o rótulo
///    flutuando no vazio. Qualquer cor escolhida aqui precisa contrastar
///    **tanto** com o fundo da página (`surfaceContainerLow`) **quanto**
///    com card e bottom sheet (`surfaceContainerLowest`, branco).
/// 2. **A barra inferior é visível já em repouso.** Os modelos usam
///    `border-transparent` até o foco, mas ali o campo tem largura menor
///    e fica dentro de um card branco; no app, com o campo ocupando a
///    linha inteira, sem a barra não havia nada dizendo onde tocar. Para
///    o público do app (pouca familiaridade digital, uso ao sol), o custo
///    de um contorno a mais é menor que o de um campo que não parece
///    campo.
class AppInputTheme {
  const AppInputTheme._();

  /// `h-14` nos modelos.
  static const double minHeight = 56;

  static InputDecorationTheme build() {
    // Cantos arredondados só em cima: o preenchimento "assenta" sobre a
    // barra de foco, em vez de flutuar como uma caixa solta.
    const radius = BorderRadius.only(
      topLeft: Radius.circular(AppRadius.xs),
      topRight: Radius.circular(AppRadius.xs),
    );

    UnderlineInputBorder border(Color color, double width) =>
        UnderlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      constraints: const BoxConstraints(minHeight: minHeight),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      // Largura 1 em todos os estados (mudando só a cor) para o campo não
      // "pular" ao ganhar foco.
      border: border(AppColors.outline, 1),
      enabledBorder: border(AppColors.outline, 1),
      focusedBorder: border(AppColors.safetyAmber, 1),
      errorBorder: border(AppColors.error, 1),
      focusedErrorBorder: border(AppColors.error, 1),
      disabledBorder: border(AppColors.outlineVariant, 1),
      labelStyle: AppTypography.bodyMedium.copyWith(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.onSurfaceVariant,
      ),
      floatingLabelStyle: AppTypography.labelMedium.copyWith(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.safetyAmber,
      ),
      hintStyle: AppTypography.bodyLarge.copyWith(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.onSurfaceVariant,
      ),
      helperStyle: AppTypography.bodySmall.copyWith(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.onSurfaceVariant,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.error,
      ),
      prefixIconColor: AppColors.onSurfaceVariant,
      suffixIconColor: AppColors.onSurfaceVariant,
    );
  }
}
