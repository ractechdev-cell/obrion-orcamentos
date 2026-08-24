import 'package:flutter/material.dart';

import '../database/enums.dart';
import '../screens/trade_label.dart';

/// Seleção múltipla de ofício — usada no onboarding e em Ajustes (ver
/// docs/POSICIONAMENTO_E_FEATURES_APP1.md, "camada de ofício"). Muitos
/// profissionais atuam em mais de um ofício, por isso é multiple-choice,
/// não um único valor.
class AppTradeSelector extends StatelessWidget {
  const AppTradeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<Trade> selected;
  final ValueChanged<Set<Trade>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final trade in Trade.values)
          FilterChip(
            avatar: Icon(tradeIcon(trade), size: 18),
            label: Text(tradeLabel(trade)),
            selected: selected.contains(trade),
            onSelected: (value) {
              final next = Set<Trade>.from(selected);
              value ? next.add(trade) : next.remove(trade);
              onChanged(next);
            },
          ),
      ],
    );
  }
}
