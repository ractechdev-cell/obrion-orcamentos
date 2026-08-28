import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_typography.dart';

/// Barra superior e barra de navegação inferior.
///
/// Nos modelos a barra inferior tem 80px, fundo [AppColors.surface] com
/// borda superior de 1px, e a aba ativa é uma "pastilha" âmbar de canto
/// arredondado com ícone e rótulo em branco — não o indicador oval
/// desbotado que o Material 3 usa por padrão.
class AppNavigationTheme {
  const AppNavigationTheme._();

  static AppBarTheme appBar() => AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        actionsIconTheme: const IconThemeData(color: AppColors.primary),
        shape: const Border(
          bottom: BorderSide(color: AppColors.surfaceOutline, width: 1),
        ),
      );

  static NavigationBarThemeData navigationBar() => NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.safetyAmber,
        height: 80,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.onPrimary
                : AppColors.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.labelMedium.copyWith(
            fontFamily: AppTypography.fontFamily,
            // O rótulo fica *fora* da pastilha âmbar, sobre o fundo claro
            // da barra — por isso âmbar, e não branco, mesmo quando ativo.
            color: states.contains(WidgetState.selected)
                ? AppColors.safetyAmber
                : AppColors.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      );

  static TabBarThemeData tabBar() => TabBarThemeData(
        labelColor: AppColors.safetyAmber,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorColor: AppColors.safetyAmber,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.surfaceOutline,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontFamily: AppTypography.fontFamily,
        ),
        unselectedLabelStyle: AppTypography.labelLarge.copyWith(
          fontFamily: AppTypography.fontFamily,
        ),
      );
}
