import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/budget/budget_calculations.dart';

void main() {
  group('BudgetItemCalculation.itemTotalCents', () {
    test('multiplies quantity by unit price and rounds to nearest cent', () {
      // 12.5 m² × R$ 25,00 (2500 centavos) = R$ 312,50 (31250 centavos)
      expect(
        BudgetItemCalculation.itemTotalCents(quantity: 12.5, unitPriceCents: 2500),
        31250,
      );
    });

    test('rounds half up (never down) on exact .5 cent boundary', () {
      // 0.5 × 1 centavo = 0.5 centavos → arredonda para 1 (meio para cima)
      expect(
        BudgetItemCalculation.itemTotalCents(quantity: 0.5, unitPriceCents: 1),
        1,
      );
      // 1.5 × 1 centavo = 1.5 centavos → arredonda para 2
      expect(
        BudgetItemCalculation.itemTotalCents(quantity: 1.5, unitPriceCents: 1),
        2,
      );
    });

    test('never returns a double — always an exact int', () {
      final result = BudgetItemCalculation.itemTotalCents(quantity: 3.333, unitPriceCents: 1000);
      expect(result, isA<int>());
    });
  });

  group('BudgetTotals.fromItems', () {
    test('sums item totals correctly (no floating point drift)', () {
      // 0.1 + 0.2 != 0.3 em double — mas em centavos (int) sempre bate.
      final items = [
        const BudgetLineItem(quantity: 1, unitPriceCents: 10), // 10 centavos
        const BudgetLineItem(quantity: 1, unitPriceCents: 20), // 20 centavos
      ];
      final totals = BudgetTotals.fromItems(items: items);

      expect(totals.subtotalCents, 30);
      expect(totals.totalCents, 30);
    });

    test('applies discount correctly', () {
      final items = [
        const BudgetLineItem(quantity: 10, unitPriceCents: 5000), // R$ 500,00
      ];
      final totals = BudgetTotals.fromItems(items: items, discountCents: 10000);

      expect(totals.subtotalCents, 50000);
      expect(totals.discountCents, 10000);
      expect(totals.totalCents, 40000);
    });

    test('never lets total go negative even if discount exceeds subtotal', () {
      final items = [
        const BudgetLineItem(quantity: 1, unitPriceCents: 1000),
      ];
      final totals = BudgetTotals.fromItems(items: items, discountCents: 999999);

      expect(totals.totalCents, 0);
    });

    test('sums many small items without accumulating floating point error', () {
      // Simula 100 itens de R$ 0,33 (33 centavos) — total exato = 3300
      final items = List.generate(
        100,
        (_) => const BudgetLineItem(quantity: 1, unitPriceCents: 33),
      );
      final totals = BudgetTotals.fromItems(items: items);

      expect(totals.subtotalCents, 3300);
    });
  });
}
