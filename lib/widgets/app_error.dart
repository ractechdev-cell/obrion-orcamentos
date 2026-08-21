import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Estado de erro padrão (ver docs/APP_FACTORY_CORE.md, UI Components).
/// Nunca mostrar `Text(error.toString())` cru numa tela — sempre este
/// componente, com opção de tentar de novo.
class AppError extends StatelessWidget {
  const AppError({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Tentar novamente',
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
