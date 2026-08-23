import 'package:drift/drift.dart';

import 'budgets_table.dart';
import 'entity_mixin.dart';

/// Pagamento recebido contra um orçamento — semente do "controle de
/// pagamentos" do plano Pro (ver CLAUDE.md, monetização). Um orçamento
/// pode ter vários pagamentos parciais (ex.: entrada + parcela final);
/// "pendente" nunca é guardado, é sempre `total do orçamento - soma dos
/// pagamentos` (ver `BudgetWithItems.pendingCents`).
class Payments extends Table with EntityMixin {
  TextColumn get budgetId => text().references(Budgets, #id)();
  IntColumn get amountCents => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
