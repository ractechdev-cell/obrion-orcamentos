import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Estilos de botão do design system Safety Industrial.
///
/// Duas regras vêm do DESIGN.md e não são negociáveis:
/// - **Altura 48px** (`touch-target`) — o público usa o app de luva ou com
///   a mão suja; alvo menor que isso erra o toque.
/// - **Sem elevação** — sombra vira borrão sob sol forte, então o botão se
///   define por preenchimento sólido ou contorno, nunca por sombra.
///
/// A cor da ação principal é [AppColors.safetyAmber] (não [AppColors
/// .primary]): nos modelos o CTA é o âmbar claro da marca, que é o ponto
/// que o olho procura primeiro na tela.
class AppButtonTheme {
  const AppButtonTheme._();

  static const double height = 48;

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
  );

  static const _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  );

  /// Rótulo de botão = `title-md` do design (16/24/600).
  static const _labelStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
  );

  static ElevatedButtonThemeData elevated() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyAmber,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceContainerHighest,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          minimumSize: const Size.fromHeight(height),
          padding: _padding,
          shape: _shape,
          elevation: 0,
          textStyle: _labelStyle,
        ),
      );

  static OutlinedButtonThemeData outlined() => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.safetyAmber,
          minimumSize: const Size.fromHeight(height),
          padding: _padding,
          shape: _shape,
          side: const BorderSide(color: AppColors.safetyAmber, width: 1),
          textStyle: _labelStyle,
        ),
      );

  static TextButtonThemeData text() => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.safetyAmber,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: _shape,
          textStyle: AppTypography.labelLarge.copyWith(
            fontFamily: AppTypography.fontFamily,
          ),
        ),
      );

  /// FAB quadrado de canto arredondado, como nos modelos — o círculo
  /// padrão do Material não aparece em nenhuma tela do design.
  static FloatingActionButtonThemeData fab() => FloatingActionButtonThemeData(
        backgroundColor: AppColors.safetyAmber,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      );

  static IconButtonThemeData icon() => IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primary),
      );
}
