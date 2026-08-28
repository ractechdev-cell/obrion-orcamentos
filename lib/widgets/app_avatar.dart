import 'package:flutter/material.dart';

/// Avatar circular com as iniciais do nome — usado na lista de clientes e
/// no cabeçalho da ficha, como nos modelos ("JS", "MO", "CS").
///
/// Iniciais em vez de foto: o app não coleta foto de cliente (coleta
/// mínima, ver LGPD no CLAUDE.md), e um ícone genérico repetido em toda
/// linha da lista não ajudaria a distinguir um cliente do outro.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.icon,
  });

  final String name;
  final double size;

  /// Substitui as iniciais por um ícone — para entradas que não são
  /// pessoa (ex.: linha de empresa no painel de pendências).
  final IconData? icon;

  /// Primeira letra do primeiro e do último nome ("João da Silva" → "JS").
  /// Nome de uma palavra só usa as duas primeiras letras.
  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final single = parts.first;
      return (single.length == 1 ? single : single.substring(0, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: icon == null
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.5, color: scheme.onSurfaceVariant)
          : Text(
              initialsOf(name),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    // A altura de linha padrão (1.5) desloca a inicial
                    // para baixo dentro do círculo; 1.0 centraliza.
                    height: 1,
                    fontSize: size * 0.34,
                  ),
            ),
    );
  }
}
