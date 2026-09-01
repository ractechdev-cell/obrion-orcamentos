import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_radius.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';

/// Banner de alerta que aparece no topo da Home quando as notificações
/// estão desabilitadas — essencial para o mecanismo de retenção do app
/// (lembretes de "orçamento aguardando resposta" e "validade próxima").
///
/// Estratégia de UX:
/// - Aparece **sempre** que as notificações estiverem desabilitadas
/// - Não tem botão "x" de fechar — a única forma de sumir é habilitar
/// - Cor amarela/laranja (atenção), não vermelho (erro)
/// - Texto curto e ação clara: "Habilitar" abre as Configurações do sistema
///
/// Decisão de design: ser "chato" é proposital — sem notificações o app
/// perde o principal canal de trazer o usuário de volta (ver CLAUDE.md,
/// "Retenção precisa de mecanismo, não só de métrica"). Profissional que
/// desabilita notificações nunca vê os lembretes de follow-up e esquece
/// os orçamentos pendentes.
class AppNotificationBanner extends StatelessWidget {
  const AppNotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: semantic.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: semantic.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: semantic.onWarningContainer,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notificações desabilitadas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: semantic.onWarningContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Você não receberá lembretes de orçamentos pendentes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: semantic.onWarningContainer.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () => openAppSettings(),
            style: TextButton.styleFrom(
              foregroundColor: semantic.onWarningContainer,
              backgroundColor: semantic.warning.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: const Text('Habilitar'),
          ),
        ],
      ),
    );
  }
}
