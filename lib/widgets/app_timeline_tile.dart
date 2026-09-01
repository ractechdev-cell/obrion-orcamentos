import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

/// Um evento da linha do tempo do cliente: marcador circular ligado por um
/// fio vertical, com o card do evento ao lado.
///
/// A linha é o que transforma "lista de coisas" em "histórico do cliente".
/// Hoje usada só para orçamentos (ver `ClientDetailScreen`) — cômodos
/// medidos vivem em `HouseScreen`, à parte (decisão 01/09/2026).
class AppTimelineTile extends StatelessWidget {
  const AppTimelineTile({
    super.key,
    required this.icon,
    required this.child,
    this.accent,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  final IconData icon;
  final Widget child;

  /// Cor da borda do marcador e do ícone. Padrão: contorno neutro.
  final Color? accent;

  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  static const double _markerSize = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.onSurfaceVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _markerSize,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // O fio corre por trás do marcador e continua pelo vão
                // até o próximo item; some acima do primeiro e abaixo do
                // último para a linha não "sobrar" nas pontas.
                Positioned(
                  top: isFirst ? _markerSize / 2 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? _markerSize / 2 : null,
                  child: Container(width: 2, color: AppColors.surfaceOutline),
                ),
                Container(
                  width: _markerSize,
                  height: _markerSize,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              // Espaço abaixo do card compõe o vão por onde o fio passa.
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: AppCard(onTap: onTap, child: child),
            ),
          ),
        ],
      ),
    );
  }
}
