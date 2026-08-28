import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Estilo de campo de entrada do design system Safety Industrial.
///
/// O design especifica um campo **preenchido, sem contorno**, com uma
/// barra de 2px embaixo que só aparece no foco (`border-b-2
/// border-transparent focus:border-primary` nos modelos) e altura mínima
/// de 56px para dar área de toque generosa na digitação.
///
/// Isso é diferente do `OutlineInputBorder` do Material: aqui o campo se
/// distingue do fundo pelo preenchimento, e o foco é sinalizado por uma
/// única aresta — menos ruído visual numa tela cheia de formulário.
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
      fillColor: AppColors.surfaceContainerLow,
      constraints: const BoxConstraints(minHeight: minHeight),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      // Transparente (não `BorderSide.none`) para que a linha ocupe
      // espaço já no estado normal — sem isso o campo "pula" 2px quando
      // recebe foco.
      border: border(Colors.transparent, 2),
      enabledBorder: border(Colors.transparent, 2),
      focusedBorder: border(AppColors.safetyAmber, 2),
      errorBorder: border(AppColors.error, 2),
      focusedErrorBorder: border(AppColors.error, 2),
      disabledBorder: border(Colors.transparent, 2),
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
