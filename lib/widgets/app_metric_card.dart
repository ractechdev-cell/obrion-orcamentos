import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Cartão de indicador do painel — "Recebidos este mês", "Aprovados".
///
/// Duas formas, como nos modelos:
/// - [AppMetricCard.featured] — largura cheia, contorno âmbar de 2px e
///   valor em manchete. Só **um** por tela: é o número que responde a
///   pergunta principal do painel ("quanto entrou?").
/// - [AppMetricCard] padrão — meia largura, contorno neutro de 1px, valor
///   em corpo. Entram em par, lado a lado.
class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.badge,
    this.onTap,
  }) : _featured = false;

  const AppMetricCard.featured({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.badge,
    this.onTap,
  }) : _featured = true;

  final String label;
  final String value;
  final IconData? icon;

  /// Cor do número. Padrão: âmbar no destacado, texto normal no comum —
  /// use apenas para dar sentido semântico (ex.: verde em "Aprovados").
  final Color? valueColor;

  /// Selo à direita do rótulo (ex.: "+12% vs mês ant.").
  final Widget? badge;
  final VoidCallback? onTap;

  final bool _featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: _featured ? 20 : 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  _featured ? label.toUpperCase() : label,
                  maxLines: _featured ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: (_featured
                          ? theme.textTheme.labelLarge
                          : theme.textTheme.labelMedium)
                      ?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: _featured ? FontWeight.w700 : null,
                    letterSpacing: _featured ? 0.5 : null,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: AppSpacing.xs),
                badge!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // `FittedBox` protege contra estouro quando o valor cresce
          // (ex.: "R$ 1.234.567,89" num cartão de meia largura numa tela
          // estreita): encolhe o número em vez de cortar ou quebrar.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: (_featured
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                color: valueColor ??
                    (_featured ? AppColors.safetyAmber : scheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(
        _featured ? AppRadius.md : AppRadius.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          _featured ? AppRadius.md : AppRadius.sm,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              _featured ? AppRadius.md : AppRadius.sm,
            ),
            border: Border.all(
              color: _featured
                  ? AppColors.safetyAmber
                  : AppColors.surfaceOutline,
              width: _featured ? 2 : 1,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
