import 'package:drift/drift.dart';

import '../enums.dart';
import 'clients_table.dart';
import 'entity_mixin.dart';
import 'projects_table.dart';

/// Orçamento — `status` é mecanismo de retenção, não só metadado (ver
/// CLAUDE.md, "Retenção precisa de mecanismo, não só de métrica").
/// Totais em centavos (`int`), nunca `double` — ver CLAUDE.md, "Dinheiro é
/// `int` em centavos".
class Budgets extends Table with EntityMixin {
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get projectId =>
      text().nullable().references(Projects, #id)();
  TextColumn get status =>
      textEnum<BudgetStatus>().withDefault(Constant(BudgetStatus.draft.name))();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get validUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Item de linha do orçamento. `quantity` é `double` (medida), mas
/// `unitPriceCents`/`totalCents` são `int` em centavos — arredondamento
/// meio-para-cima, coberto por teste unitário (ver
/// `lib/budget/budget_calculations.dart`).
class BudgetItems extends Table with EntityMixin {
  TextColumn get budgetId => text().references(Budgets, #id)();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  TextColumn get unit => textEnum<ServiceUnit>()();
  RealColumn get quantity => real()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get totalCents => integer()();
  BoolColumn get includesMaterial =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
