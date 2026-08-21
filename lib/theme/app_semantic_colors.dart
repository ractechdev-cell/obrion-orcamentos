import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens semânticos que o Material 3 ColorScheme não modela nativamente
/// (success/warning), completando o conjunto exigido em CLAUDE.md ("Tema":
/// primary, secondary, background, surface, text, error, success, warning).
///
/// Uso: `context.semanticColors.success`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  static const light = AppSemanticColors(
    success: AppSemanticPalette.success,
    onSuccess: AppSemanticPalette.onSuccess,
    successContainer: AppSemanticPalette.successContainer,
    onSuccessContainer: AppSemanticPalette.onSuccessContainer,
    warning: AppSemanticPalette.warning,
    onWarning: AppSemanticPalette.onWarning,
    warningContainer: AppSemanticPalette.warningContainer,
    onWarningContainer: AppSemanticPalette.onWarningContainer,
  );

  static const dark = AppSemanticColors(
    success: AppSemanticPalette.successDark,
    onSuccess: AppSemanticPalette.onSuccessDark,
    successContainer: AppSemanticPalette.successContainerDark,
    onSuccessContainer: AppSemanticPalette.onSuccessContainerDark,
    warning: AppSemanticPalette.warningDark,
    onWarning: AppSemanticPalette.onWarningDark,
    warningContainer: AppSemanticPalette.warningContainerDark,
    onWarningContainer: AppSemanticPalette.onWarningContainerDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}

/// Acesso conveniente aos tokens que o ColorScheme não cobre:
/// `context.semanticColors.success`.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
