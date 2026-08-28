import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Título de seção com filete inferior — o "PENDÊNCIAS" do painel.
///
/// Caixa alta e filete são o que separa seções nos modelos, já que o
/// design não usa sombra nem cartão para agrupar (ver "Elevation & Depth"
/// no DESIGN.md).
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.uppercase = true,
  });

  final String title;

  /// Ação à direita do título (ex.: "Ver todos").
  final Widget? trailing;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                uppercase ? title.toUpperCase() : title,
                style: theme.textTheme.titleMedium?.copyWith(
                  letterSpacing: uppercase ? 0.5 : null,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
