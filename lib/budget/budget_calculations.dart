/// Cálculo de orçamento — regra de ouro do CLAUDE.md: dinheiro é `int` em
/// centavos, nunca `double`. Quantidade (medida) continua `double`;
/// arredondamento acontece só na multiplicação quantidade × preço, meio
/// para cima, ao centavo.
class BudgetItemCalculation {
  const BudgetItemCalculation._();

  /// Calcula o total de um item: quantidade (double) × preço unitário
  /// (centavos, int) → total em centavos (int), arredondado meio para
  /// cima ao centavo mais próximo.
  static int itemTotalCents({
    required double quantity,
    required int unitPriceCents,
  }) {
    final raw = quantity * unitPriceCents;
    return raw.round();
  }
}

/// Um item de orçamento já calculado, pronto para somar ao total.
class BudgetLineItem {
  const BudgetLineItem({
    required this.quantity,
    required this.unitPriceCents,
  });

  final double quantity;
  final int unitPriceCents;

  int get totalCents => BudgetItemCalculation.itemTotalCents(
        quantity: quantity,
        unitPriceCents: unitPriceCents,
      );
}

/// Totais do orçamento: soma dos itens menos desconto. Nunca calcular a
/// subtração em `double` — tudo em centavos (`int`) do início ao fim.
class BudgetTotals {
  const BudgetTotals({
    required this.subtotalCents,
    required this.discountCents,
    required this.totalCents,
  });

  final int subtotalCents;
  final int discountCents;
  final int totalCents;

  factory BudgetTotals.fromItems({
    required List<BudgetLineItem> items,
    int discountCents = 0,
  }) {
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.totalCents);
    final total = (subtotal - discountCents).clamp(0, subtotal);
    return BudgetTotals(
      subtotalCents: subtotal,
      discountCents: discountCents,
      totalCents: total,
    );
  }
}
