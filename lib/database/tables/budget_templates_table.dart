import 'package:drift/drift.dart';

import '../enums.dart';
import 'entity_mixin.dart';

/// Modelo de orçamento reutilizável — ver
/// docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 14 ("Modelos de
/// Orçamento", P1/PRO). Nasce sempre a partir de um orçamento existente
/// ("Salvar como modelo"), nunca editado depois de criado — pra ajustar,
/// o profissional exclui e salva um modelo novo a partir de um orçamento
/// atualizado. Isso evita duplicar toda a UI de adicionar/editar item
/// só para modelos.
///
/// Sem paywall por enquanto: o roadmap marca como recurso Pro, mas o
/// módulo Purchases/Subscriptions só existe a partir da Fase 4 — travar
/// agora seria placebo sem infraestrutura real por trás.
class BudgetTemplates extends Table with EntityMixin {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();
  TextColumn get jobDescription => text().nullable()();
  IntColumn get discountCents => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Item de linha do modelo — mesma forma de `BudgetItems`, mas sem
/// `budgetId` (pertence a um `BudgetTemplates`, não a um orçamento).
class BudgetTemplateItems extends Table with EntityMixin {
  TextColumn get templateId => text().references(BudgetTemplates, #id)();
  TextColumn get description => text().withLength(min: 1, max: 200)();
  TextColumn get unit => textEnum<ServiceUnit>()();
  RealColumn get quantity => real()();
  IntColumn get unitPriceCents => integer()();
  BoolColumn get includesMaterial =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
