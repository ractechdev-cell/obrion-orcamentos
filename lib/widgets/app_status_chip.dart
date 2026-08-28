import 'package:flutter/material.dart';

import '../database/enums.dart';
import '../theme/app_radius.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';

/// Selo tonal de estado — "Enviado", "Aceito", "Vence amanhã".
///
/// Segue a regra de legibilidade do DESIGN.md: **fundo de baixa saturação
/// com texto de alta saturação**, o que mantém o contraste do texto sob
/// sol forte sem que o selo brigue por atenção com o conteúdo do card.
///
/// Antes disso existir, cada tela montava seu próprio `Container` com
/// `BoxDecoration` — a lista de orçamentos tinha um, e qualquer tela nova
/// repetiria o padrão com tons ligeiramente diferentes.
enum AppStatusTone { neutral, info, success, warning, danger, brand }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
    this.pill = false,
  });

  /// Deriva o tom a partir do estado do orçamento — mantém a associação
  /// estado→cor num lugar só, em vez de repetida em cada tela que exibe
  /// um orçamento.
  factory AppStatusChip.budget(BudgetStatus status, {bool pill = false}) {
    return AppStatusChip(
      label: switch (status) {
        BudgetStatus.draft => 'Rascunho',
        BudgetStatus.sent => 'Enviado',
        BudgetStatus.accepted => 'Aceito',
        BudgetStatus.declined => 'Recusado',
      },
      tone: switch (status) {
        BudgetStatus.draft => AppStatusTone.neutral,
        BudgetStatus.sent => AppStatusTone.info,
        BudgetStatus.accepted => AppStatusTone.success,
        BudgetStatus.declined => AppStatusTone.danger,
      },
      pill: pill,
    );
  }

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  /// `true` deixa o selo totalmente arredondado. O padrão (`false`) usa
  /// canto pequeno, como os selos de estado dos modelos — pílula fica
  /// reservada para contagens e variações ("+12% vs mês ant.").
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

    final (Color background, Color foreground) = switch (tone) {
      AppStatusTone.neutral => (
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
        ),
      AppStatusTone.info => (semantic.infoContainer, semantic.onInfoContainer),
      AppStatusTone.success => (
          semantic.successContainer,
          semantic.success,
        ),
      AppStatusTone.warning => (
          semantic.warningContainer,
          semantic.onWarningContainer,
        ),
      AppStatusTone.danger => (
          semantic.dangerContainer,
          semantic.onDangerContainer,
        ),
      AppStatusTone.brand => (
          scheme.surfaceContainerHigh,
          scheme.primary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          pill ? AppRadius.full : AppRadius.xs,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          // `Flexible` + `ellipsis`: o rótulo vem de dado do usuário em
          // alguns usos ("Enviado há 2h"), e um nome longo não pode
          // estourar a linha do card.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
