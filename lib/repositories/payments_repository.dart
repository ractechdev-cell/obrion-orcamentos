import 'package:drift/drift.dart';

import '../database/database.dart';

/// Repositório de pagamentos (ver CLAUDE.md, monetização — "controle de
/// pagamentos" do plano Pro). Um orçamento pode ter vários pagamentos
/// parciais; "pendente" nunca é uma coluna própria, é sempre `total do
/// orçamento - soma dos pagamentos` (calculado, não guardado).
class PaymentsRepository {
  PaymentsRepository(this._db);

  final AppDatabase _db;

  /// Observa todos os pagamentos de um orçamento, mais recentes primeiro.
  Stream<List<Payment>> watchByBudget(String budgetId) {
    return (_db.select(_db.payments)
          ..where((p) => p.budgetId.equals(budgetId) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .watch();
  }

  /// Registra um pagamento recebido.
  Future<Payment> create({
    required String budgetId,
    required int amountCents,
    String? notes,
  }) {
    final now = DateTime.now();
    return _db.into(_db.payments).insertReturning(
          PaymentsCompanion.insert(
            budgetId: budgetId,
            amountCents: amountCents,
            notes: Value(notes),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Remove logicamente um pagamento (ex.: registrado por engano).
  Future<bool> softDelete(String id) async {
    final count = await (_db.update(_db.payments)..where((p) => p.id.equals(id)))
        .write(PaymentsCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }
}
