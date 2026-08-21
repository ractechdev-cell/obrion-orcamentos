import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Contêiner de conteúdo padrão (ex.: card de orçamento, de cliente) — ver
/// docs/APP_FACTORY_CORE.md, UI Components. Usa o `cardTheme` central
/// (ver `lib/theme/app_theme.dart`); nunca estilizar `Card` manualmente
/// numa tela.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}
