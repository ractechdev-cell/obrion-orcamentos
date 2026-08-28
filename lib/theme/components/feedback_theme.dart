import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_typography.dart';

/// Componentes de retorno ao usuário: snackbar, indicadores de progresso
/// e seletores booleanos (checkbox, switch, radio).
///
/// Agrupados num arquivo só porque são todos "reação a uma ação" e cada
/// um sozinho não passaria de meia dúzia de linhas — separá-los criaria
/// arquivo sem conteúdo suficiente para justificar a navegação extra.
class AppFeedbackTheme {
  const AppFeedbackTheme._();

  static SnackBarThemeData snackBar() => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onInverseSurface,
        ),
        actionTextColor: AppColors.inversePrimary,
      );

  static ProgressIndicatorThemeData progress() =>
      const ProgressIndicatorThemeData(
        color: AppColors.safetyAmber,
        linearTrackColor: AppColors.surfaceContainerHigh,
        circularTrackColor: Colors.transparent,
      );

  static CheckboxThemeData checkbox() => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.safetyAmber
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
        side: const BorderSide(color: AppColors.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      );

  static SwitchThemeData switchTheme() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.safetyAmber
              : AppColors.surfaceContainerHigh,
        ),
      );

  static RadioThemeData radio() => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.safetyAmber
              : AppColors.outline,
        ),
      );
}
