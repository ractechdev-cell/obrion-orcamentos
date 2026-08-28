import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Um trecho da barra proporcional.
@immutable
class AppBarSegment {
  const AppBarSegment({
    required this.value,
    required this.color,
    required this.label,
  });

  /// Peso do trecho. Não precisa somar 100 — a barra normaliza pelo total.
  final num value;
  final Color color;
  final String label;
}

/// Barra proporcional com legenda — a "Saúde do Negócio" do painel.
///
/// Mostra a divisão entre aprovado e aguardando numa faixa só, em vez de
/// dois números soltos: a proporção é a informação, e ela se lê de
/// relance sem precisar comparar valores mentalmente.
class AppSegmentedBar extends StatelessWidget {
  const AppSegmentedBar({
    super.key,
    required this.segments,
    this.height = 8,
  });

  final List<AppBarSegment> segments;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: height,
            // Sem dado nenhum (total zero) a barra vira uma trilha vazia,
            // em vez de sumir ou dividir por zero.
            child: total <= 0
                ? ColoredBox(color: theme.colorScheme.surfaceContainerHigh)
                : Row(
                    children: [
                      for (final segment in segments)
                        if (segment.value > 0)
                          Expanded(
                            flex: (segment.value / total * 1000).round(),
                            child: ColoredBox(color: segment.color),
                          ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // `Wrap` em vez de `Row`: com rótulos longos numa tela estreita,
        // a legenda quebra de linha em vez de estourar.
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            for (final segment in segments)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: segment.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    segment.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
