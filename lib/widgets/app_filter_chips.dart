import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Uma opção da barra de filtro.
@immutable
class AppFilterOption<T> {
  const AppFilterOption({required this.value, required this.label});

  /// `null` representa "sem filtro" — o chip "Todos"/"Todas".
  final T? value;
  final String label;
}

/// Barra horizontal de chips de filtro — o "Todos | Rascunho | Enviado"
/// da lista de orçamentos e o "Todas | Pintura | Elétrica" da lista de
/// preços.
///
/// Rola na horizontal porque a quantidade de opções é aberta (categorias
/// são texto livre do profissional): quebrar em várias linhas empurraria
/// a lista para baixo de forma imprevisível.
class AppFilterChips<T> extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  });

  final List<AppFilterOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Altura fixa evita que o `ListView` horizontal tente ocupar altura
      // infinita dentro de uma `Column`.
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selected;

          return Center(
            child: ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => onSelected(option.value),
              labelStyle:
                  Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
            ),
          );
        },
      ),
    );
  }
}
