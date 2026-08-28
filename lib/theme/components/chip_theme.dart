import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Chips de filtro e seleção.
///
/// O design mantém chips **totalmente arredondados** (pílula) justamente
/// para não confundi-los com botão, que usa canto de 8px (ver "Shapes" no
/// DESIGN.md). Selecionado = preenchimento âmbar sólido com texto branco;
/// não selecionado = fundo claro com contorno de 1px.
class AppChipTheme {
  const AppChipTheme._();

  static ChipThemeData build() => ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedColor: AppColors.safetyAmber,
        disabledColor: AppColors.surfaceContainerHigh,
        checkmarkColor: AppColors.onPrimary,
        showCheckmark: false,
        side: const BorderSide(color: AppColors.surfaceOutline, width: 1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: AppTypography.labelLarge.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onSurface,
        ),
        secondaryLabelStyle: AppTypography.labelLarge.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onPrimary,
        ),
      );
}
