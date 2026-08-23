import 'package:drift/drift.dart';

import '../budget/budget_calculations.dart';
import '../database/database.dart';
import '../database/enums.dart';
import '../notifications/notification_service.dart';

/// Orçamento completo com itens já carregados — usado na tela de detalhe
/// e na duplicação (ver CLAUDE.md, "Duplicar orçamento anterior").
class BudgetWithItems {
  const BudgetWithItems({required this.budget, required this.items});

  final Budget budget;
  final List<BudgetItem> items;

  BudgetTotals get totals => BudgetTotals.fromItems(
        items: items
            .map((i) => BudgetLineItem(quantity: i.quantity, unitPriceCents: i.unitPriceCents))
            .toList(),
        discountCents: budget.discountCents,
      );
}

/// Dado de entrada para criar/duplicar um item de orçamento — o total é
/// sempre recalculado pelo repositório, nunca confiado ao chamador (ver
/// CLAUDE.md, "Dinheiro é `int` em centavos").
class BudgetItemInput {
  const BudgetItemInput({
    required this.description,
    required this.unit,
    required this.quantity,
    required this.unitPriceCents,
    this.includesMaterial = false,
  });

  final String description;
  final ServiceUnit unit;
  final double quantity;
  final int unitPriceCents;
  final bool includesMaterial;
}

/// Repositório de orçamentos (ver CLAUDE.md, "Retenção precisa de
/// mecanismo, não só de métrica" — status é o mecanismo central aqui).
class BudgetsRepository {
  BudgetsRepository(this._db);

  final AppDatabase _db;

  /// Observa todos os orçamentos de um cliente, mais recentes primeiro.
  Stream<List<Budget>> watchByClient(String clientId) {
    return (_db.select(_db.budgets)
          ..where((b) => b.clientId.equals(clientId) & b.deletedAt.isNull())
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
        .watch();
  }

  /// Quantos orçamentos (de qualquer cliente) estão parados em "Enviado"
  /// há 3 dias ou mais — mesma regra do chip "Aguardando há Xd" em
  /// `budgets_screen.dart`, usada pelo resumo da Home (ver CLAUDE.md,
  /// "Retenção precisa de mecanismo, não só de métrica"). Consulta única
  /// (não reativa) — mesma razão de `ClientsRepository.countActive`.
  Future<int> countAwaitingResponse() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    final rows = await (_db.select(_db.budgets)
          ..where((b) =>
              b.status.equalsValue(BudgetStatus.sent) &
              b.deletedAt.isNull() &
              b.updatedAt.isSmallerOrEqualValue(cutoff)))
        .get();
    return rows.length;
  }

  /// Observa um orçamento com seus itens.
  Stream<BudgetWithItems?> watchById(String id) {
    final budgetQuery = _db.select(_db.budgets)..where((b) => b.id.equals(id));
    return budgetQuery.watchSingleOrNull().asyncMap((budget) async {
      if (budget == null) return null;
      final items = await (_db.select(_db.budgetItems)
            ..where((i) => i.budgetId.equals(id) & i.deletedAt.isNull()))
          .get();
      return BudgetWithItems(budget: budget, items: items);
    });
  }

  /// Cria um orçamento vazio (rascunho) para um cliente/projeto.
  Future<Budget> create({
    required String clientId,
    String? projectId,
    String? notes,
  }) {
    final now = DateTime.now();
    return _db.into(_db.budgets).insertReturning(
          BudgetsCompanion.insert(
            clientId: clientId,
            projectId: Value(projectId),
            notes: Value(notes),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Adiciona um item ao orçamento. O total é calculado aqui — nunca
  /// recebido pronto do chamador, para garantir a regra de arredondamento
  /// única (ver `lib/budget/budget_calculations.dart`).
  Future<BudgetItem> addItem(String budgetId, BudgetItemInput input) {
    final now = DateTime.now();
    final totalCents = BudgetItemCalculation.itemTotalCents(
      quantity: input.quantity,
      unitPriceCents: input.unitPriceCents,
    );
    return _db.into(_db.budgetItems).insertReturning(
          BudgetItemsCompanion.insert(
            budgetId: budgetId,
            description: input.description,
            unit: input.unit,
            quantity: input.quantity,
            unitPriceCents: input.unitPriceCents,
            totalCents: totalCents,
            includesMaterial: Value(input.includesMaterial),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Remove logicamente um item do orçamento.
  Future<bool> removeItem(String itemId) async {
    final count = await (_db.update(_db.budgetItems)..where((i) => i.id.equals(itemId)))
        .write(BudgetItemsCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }

  /// Atualiza o desconto do orçamento (em centavos).
  Future<bool> updateDiscount(String budgetId, int discountCents) async {
    final count = await (_db.update(_db.budgets)..where((b) => b.id.equals(budgetId))).write(
      BudgetsCompanion(
        discountCents: Value(discountCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return count > 0;
  }

  /// Atualiza observações e validade — texto que o profissional reaproveita
  /// no PDF ("condições de pagamento", prazo, garantia).
  Future<bool> updateDetails(
    String budgetId, {
    String? notes,
    DateTime? validUntil,
  }) async {
    final count = await (_db.update(_db.budgets)..where((b) => b.id.equals(budgetId))).write(
      BudgetsCompanion(
        notes: Value(notes),
        validUntil: Value(validUntil),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return count > 0;
  }

  /// Avança o status do orçamento em um toque — mecanismo de retenção
  /// central do produto (ver CLAUDE.md).
  Future<bool> updateStatus(String budgetId, BudgetStatus status) async {
    final count = await (_db.update(_db.budgets)..where((b) => b.id.equals(budgetId))).write(
      BudgetsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (count > 0) {
      // Lembrete local de "aguardando resposta" (ver CLAUDE.md,
      // "Retenção precisa de mecanismo") — vive aqui, não em cada tela
      // que chama updateStatus, pra nenhum call site esquecer de
      // agendar/cancelar.
      if (status == BudgetStatus.sent) {
        await NotificationService.scheduleAwaitingResponseReminder(budgetId);
      } else {
        await NotificationService.cancelAwaitingResponseReminder(budgetId);
      }
    }
    return count > 0;
  }

  /// Exclusão lógica do orçamento (não dos itens — eles ficam órfãos mas
  /// preservados para auditoria/backup).
  Future<bool> softDelete(String id) async {
    final count = await (_db.update(_db.budgets)..where((b) => b.id.equals(id)))
        .write(BudgetsCompanion(deletedAt: Value(DateTime.now())));
    if (count > 0) await NotificationService.cancelAwaitingResponseReminder(id);
    return count > 0;
  }

  /// Duplica um orçamento existente (cliente/projeto + itens), sempre
  /// como novo rascunho — "alto uso real" segundo CLAUDE.md.
  Future<Budget> duplicate(String sourceBudgetId) async {
    final source = await (_db.select(_db.budgets)..where((b) => b.id.equals(sourceBudgetId)))
        .getSingle();
    final sourceItems = await (_db.select(_db.budgetItems)
          ..where((i) => i.budgetId.equals(sourceBudgetId) & i.deletedAt.isNull()))
        .get();

    final newBudget = await create(
      clientId: source.clientId,
      projectId: source.projectId,
      notes: source.notes,
    );

    for (final item in sourceItems) {
      await addItem(
        newBudget.id,
        BudgetItemInput(
          description: item.description,
          unit: item.unit,
          quantity: item.quantity,
          unitPriceCents: item.unitPriceCents,
          includesMaterial: item.includesMaterial,
        ),
      );
    }

    if (source.discountCents > 0) {
      await updateDiscount(newBudget.id, source.discountCents);
    }

    return newBudget;
  }
}
