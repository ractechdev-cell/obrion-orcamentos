import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_semantic_colors.dart';
import 'app_typography.dart';
import 'components/button_theme.dart';
import 'components/chip_theme.dart';
import 'components/feedback_theme.dart';
import 'components/input_theme.dart';
import 'components/navigation_theme.dart';
import 'components/surface_theme.dart';

/// Tema único da família Obrion (ver docs/APP_FACTORY_CORE.md, módulo
/// Theme). Nenhuma tela deve referenciar cor fora daqui — sempre
/// `Theme.of(context).colorScheme.*` ou `context.semanticColors.*`.
///
/// Baseado no design system **Safety Industrial**
/// (`docs/stitch_document_theme_generator/safety_industrial/DESIGN.md`).
/// Palavras-chave: pragmático, robusto, confiável — alto contraste para
/// leitura ao sol e alvos de toque grandes para mão de luva.
///
/// Este arquivo apenas **compõe**: cada família de componente mora em
/// `components/`, para que ajustar botão não exija abrir o arquivo que
/// também define input, card e navegação.
class AppTheme {
  const AppTheme._();

  /// `ColorScheme` do design. Todos os papéis são fixados explicitamente
  /// a partir de [AppColors] em vez de derivados por `fromSeed`: o
  /// design system define cada tom à mão, e deixar o Material 3 gerá-los
  /// produziria tons próximos, porém diferentes dos modelos.
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceTint: AppColors.surfaceTint,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.onInverseSurface,
    inversePrimary: AppColors.inversePrimary,
    scrim: AppColors.scrim,
    shadow: AppColors.shadow,
  );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(),
      // O fundo do app é o tom `surface-container-low`, não o branco
      // puro: nos modelos os cards brancos se destacam *sobre* um fundo
      // levemente acinzentado. Fundo branco apagaria essa separação.
      scaffoldBackgroundColor: AppColors.surfaceContainerLow,
      extensions: const [AppSemanticColors.light],

      appBarTheme: AppNavigationTheme.appBar(),
      navigationBarTheme: AppNavigationTheme.navigationBar(),
      tabBarTheme: AppNavigationTheme.tabBar(),

      elevatedButtonTheme: AppButtonTheme.elevated(),
      outlinedButtonTheme: AppButtonTheme.outlined(),
      textButtonTheme: AppButtonTheme.text(),
      floatingActionButtonTheme: AppButtonTheme.fab(),
      iconButtonTheme: AppButtonTheme.icon(),

      inputDecorationTheme: AppInputTheme.build(),
      chipTheme: AppChipTheme.build(),

      cardTheme: AppSurfaceTheme.card(),
      dialogTheme: AppSurfaceTheme.dialog(),
      bottomSheetTheme: AppSurfaceTheme.bottomSheet(),
      dividerTheme: AppSurfaceTheme.divider(),
      listTileTheme: AppSurfaceTheme.listTile(),

      snackBarTheme: AppFeedbackTheme.snackBar(),
      progressIndicatorTheme: AppFeedbackTheme.progress(),
      checkboxTheme: AppFeedbackTheme.checkbox(),
      switchTheme: AppFeedbackTheme.switchTheme(),
      radioTheme: AppFeedbackTheme.radio(),
    );
  }
}
