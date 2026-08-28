import 'package:drift/drift.dart';

import '../database/database.dart';
import 'budgets_repository.dart';

/// Modelo de orçamento com seus itens já carregados — usado na lista
/// de "Meus Modelos" e ao aplicar num orçamento novo.
class BudgetTemplateWithItems {
  const BudgetTemplateWithItems({required this.template, required this.items});

  final BudgetTemplate template;
  final List<BudgetTemplateItem> items;
}

/// Repositório de modelos de orçamento (ver
/// docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 14). Um modelo nasce
/// sempre a partir de um orçamento existente — nunca editado depois de
/// criado, ver `budget_templates_table.dart` pra justificativa completa.
class BudgetTemplatesRepository {
  BudgetTemplatesRepository(this._db);

  final AppDatabase _db;

  /// Observa todos os modelos, mais recentes primeiro.
  Stream<List<BudgetTemplate>> watchAll() {
    return (_db.select(_db.budgetTemplates)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Cria um modelo a partir de um orçamento existente (nome + itens +
  /// condições) — snapshot no momento da criação, não uma referência
  /// viva ao orçamento original.
  Future<BudgetTemplate> createFromBudget({
    required String budgetId,
    required String name,
  }) async {
    final budget = await (_db.select(_db.budgets)..where((b) => b.id.equals(budgetId)))
        .getSingle();
    final items = await (_db.select(_db.budgetItems)
          ..where((i) => i.budgetId.equals(budgetId) & i.deletedAt.isNull()))
        .get();

    final now = DateTime.now();
    final template = await _db.into(_db.budgetTemplates).insertReturning(
          BudgetTemplatesCompanion.insert(
            name: name,
            notes: Value(budget.notes),
            jobDescription: Value(budget.jobDescription),
            discountCents: Value(budget.discountCents),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    for (final item in items) {
      await _db.into(_db.budgetTemplateItems).insert(
            BudgetTemplateItemsCompanion.insert(
              templateId: template.id,
              description: item.description,
              unit: item.unit,
              quantity: item.quantity,
              unitPriceCents: item.unitPriceCents,
              includesMaterial: Value(item.includesMaterial),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    }

    return template;
  }

  /// Carrega um modelo com seus itens.
  Future<BudgetTemplateWithItems?> getWithItems(String templateId) async {
    final template = await (_db.select(_db.budgetTemplates)
          ..where((t) => t.id.equals(templateId)))
        .getSingleOrNull();
    if (template == null) return null;
    final items = await (_db.select(_db.budgetTemplateItems)
          ..where((i) => i.templateId.equals(templateId) & i.deletedAt.isNull()))
        .get();
    return BudgetTemplateWithItems(template: template, items: items);
  }

  /// Aplica um modelo a um orçamento (rascunho recém-criado): copia
  /// itens, desconto, observações e descrição da obra. O orçamento
  /// precisa já existir (ver `BudgetsRepository.create`) — este método
  /// só popula o que já foi criado vazio, mesma ordem usada em
  /// `BudgetsRepository.duplicate`.
  Future<void> applyToBudget({
    required String templateId,
    required String budgetId,
  }) async {
    final data = await getWithItems(templateId);
    if (data == null) return;

    final budgetsRepo = BudgetsRepository(_db);
    for (final item in data.items) {
      await budgetsRepo.addItem(
        budgetId,
        BudgetItemInput(
          description: item.description,
          unit: item.unit,
          quantity: item.quantity,
          unitPriceCents: item.unitPriceCents,
          includesMaterial: item.includesMaterial,
        ),
      );
    }

    await budgetsRepo.updateDetails(
      budgetId,
      notes: data.template.notes,
      jobDescription: data.template.jobDescription,
    );
    if (data.template.discountCents > 0) {
      await budgetsRepo.updateDiscount(budgetId, data.template.discountCents);
    }
  }

  /// Exclusão lógica do modelo (itens ficam órfãos mas preservados,
  /// mesmo padrão de `BudgetsRepository.softDelete`).
  Future<bool> softDelete(String id) async {
    final count = await (_db.update(_db.budgetTemplates)..where((t) => t.id.equals(id)))
        .write(BudgetTemplatesCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }
}
