import 'package:flutter/material.dart';

/// Selo de recurso Premium (ver docs/APP_FACTORY_CORE.md, UI Components).
/// Puramente visual nesta fase — o módulo Purchases/Subscriptions
/// (estado real do plano) só entra na Fase 3 (ver CLAUDE.md, roadmap).
/// Nunca implementar checagem "sou premium?" aqui: este widget só exibe,
/// quem decide mostrar é a tela, a partir do estado central do Core.
class AppPremiumBadge extends StatelessWidget {
  const AppPremiumBadge({super.key, this.label = 'Pro'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 14, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
