import 'package:flutter/material.dart';

import '../database/enums.dart';

/// Rótulo em português do ofício — usado no onboarding, em Ajustes e na
/// Lista de Preços. Mesmo raciocínio de `service_unit_label.dart`: um só
/// lugar para não duplicar o texto em cada tela.
String tradeLabel(Trade trade) {
  switch (trade) {
    case Trade.mason:
      return 'Pedreiro';
    case Trade.painter:
      return 'Pintor';
    case Trade.plasterer:
      return 'Gesseiro';
    case Trade.tiler:
      return 'Azulejista';
    case Trade.electrician:
      return 'Eletricista';
    case Trade.plumber:
      return 'Encanador';
  }
}

IconData tradeIcon(Trade trade) {
  switch (trade) {
    case Trade.mason:
      return Icons.foundation_outlined;
    case Trade.painter:
      return Icons.format_paint_outlined;
    case Trade.plasterer:
      return Icons.layers_outlined;
    case Trade.tiler:
      return Icons.grid_on_outlined;
    case Trade.electrician:
      return Icons.bolt_outlined;
    case Trade.plumber:
      return Icons.plumbing_outlined;
  }
}
