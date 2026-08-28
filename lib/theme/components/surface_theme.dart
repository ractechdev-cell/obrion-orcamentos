import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Superfícies contidas: card, diálogo e bottom sheet.
///
/// O design constrói profundidade por **contorno e tom**, nunca por
/// sombra (ver "Elevation & Depth" no DESIGN.md — sombra some ou vira
/// borrão sob sol forte). Por isso todo card aqui é `elevation: 0` com
/// borda de 1px em [AppColors.surfaceOutline].
class AppSurfaceTheme {
  const AppSurfaceTheme._();

  static CardThemeData card() => CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.surfaceOutline, width: 1),
        ),
      );

  static DialogThemeData dialog() => DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.surfaceOutline, width: 1),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onSurfaceVariant,
        ),
      );

  /// Bottom sheet com raio de 28px no topo e alça de arraste visível,
  /// conforme "Additional Components" no DESIGN.md.
  static BottomSheetThemeData bottomSheet() => const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.outlineVariant,
        dragHandleSize: Size(32, 4),
      );

  static DividerThemeData divider() => const DividerThemeData(
        color: AppColors.surfaceOutline,
        thickness: 1,
        space: 0,
      );

  static ListTileThemeData listTile() => ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: AppTypography.titleMedium.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onSurface,
        ),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onSurfaceVariant,
        ),
        iconColor: AppColors.onSurfaceVariant,
      );
}
