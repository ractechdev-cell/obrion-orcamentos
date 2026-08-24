import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/payments_repository.dart';

void main() {
  late AppDatabase database;
  late ClientsRepository clientsRepo;
  late BudgetsRepository budgetsRepo;
  late PaymentsRepository paymentsRepo;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    clientsRepo = ClientsRepository(database);
    budgetsRepo = BudgetsRepository(database);
    paymentsRepo = PaymentsRepository(database);
  });

  tearDown(() => database.close());

  test('creates budget as draft and adds items with computed totals', () async {
    final client = await clientsRepo.create(name: 'Marcos Pintor');
    final budget = await budgetsRepo.create(clientId: client.id);

    expect(budget.status, BudgetStatus.draft);

    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Pintura de parede',
        unit: ServiceUnit.squareMeter,
        quantity: 20,
        unitPriceCents: 2500,
      ),
    );

    final result = await budgetsRepo.watchById(budget.id).first;
    expect(result, isNotNull);
    expect(result!.items, hasLength(1));
    expect(result.items.first.totalCents, 50000); // 20 * 2500
    expect(result.totals.subtotalCents, 50000);
    expect(result.totals.totalCents, 50000);
  });

  test('applies discount to totals correctly', () async {
    final client = await clientsRepo.create(name: 'Ana Eletricista');
    final budget = await budgetsRepo.create(clientId: client.id);

    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Ponto elétrico',
        unit: ServiceUnit.point,
        quantity: 5,
        unitPriceCents: 8000,
      ),
    );
    await budgetsRepo.updateDiscount(budget.id, 5000);

    final result = await budgetsRepo.watchById(budget.id).first;
    expect(result!.totals.subtotalCents, 40000);
    expect(result.totals.discountCents, 5000);
    expect(result.totals.totalCents, 35000);
  });

  test('updates status through the retention lifecycle', () async {
    final client = await clientsRepo.create(name: 'João Gesseiro');
    final budget = await budgetsRepo.create(clientId: client.id);

    await budgetsRepo.updateStatus(budget.id, BudgetStatus.sent);
    var result = await budgetsRepo.watchById(budget.id).first;
    expect(result!.budget.status, BudgetStatus.sent);

    await budgetsRepo.updateStatus(budget.id, BudgetStatus.accepted);
    result = await budgetsRepo.watchById(budget.id).first;
    expect(result!.budget.status, BudgetStatus.accepted);
  });

  test(
      'watchById emits a new value when an item is added to an already-open '
      'subscription (regression: adding an item silently failed to update '
      'the screen — watchSingleOrNull() on budgets alone never noticed '
      'writes to the separate budget_items table)', () async {
    final client = await clientsRepo.create(name: 'Regressão Item');
    final budget = await budgetsRepo.create(clientId: client.id);

    final matcher = expectLater(
      budgetsRepo.watchById(budget.id).map((data) => data?.items.length),
      emitsInOrder([0, 1]),
    );

    // Dá tempo da subscription do expectLater se estabelecer antes do
    // addItem — senão a primeira emissão (0 itens) pode ser perdida e a
    // ordem esperada não bate.
    await Future<void>.delayed(Duration.zero);

    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Item de teste',
        unit: ServiceUnit.unit,
        quantity: 1,
        unitPriceCents: 1000,
      ),
    );

    await matcher.timeout(const Duration(seconds: 5));
  });

  test('duplicates a budget with its items and discount', () async {
    final client = await clientsRepo.create(name: 'Carla Azulejista');
    final original = await budgetsRepo.create(clientId: client.id, notes: 'Reforma banheiro');

    await budgetsRepo.addItem(
      original.id,
      const BudgetItemInput(
        description: 'Assentamento de piso',
        unit: ServiceUnit.squareMeter,
        quantity: 10,
        unitPriceCents: 4000,
      ),
    );
    await budgetsRepo.updateDiscount(original.id, 2000);

    final duplicated = await budgetsRepo.duplicate(original.id);

    expect(duplicated.id, isNot(original.id));
    expect(duplicated.status, BudgetStatus.draft);
    expect(duplicated.clientId, client.id);
    expect(duplicated.notes, 'Reforma banheiro');

    final result = await budgetsRepo.watchById(duplicated.id).first;
    expect(result!.items, hasLength(1));
    expect(result.items.first.totalCents, 40000);
    expect(result.totals.discountCents, 2000);
  });

  test('updateDetails saves notes and validUntil', () async {
    final client = await clientsRepo.create(name: 'Bruno Encanador');
    final budget = await budgetsRepo.create(clientId: client.id);
    final validUntil = DateTime(2026, 12, 31);

    await budgetsRepo.updateDetails(
      budget.id,
      notes: 'Pagamento em 2x',
      validUntil: validUntil,
    );

    final result = await budgetsRepo.watchById(budget.id).first;
    expect(result!.budget.notes, 'Pagamento em 2x');
    expect(result.budget.validUntil, validUntil);
  });

  test('soft delete excludes budget from watchByClient', () async {
    final client = await clientsRepo.create(name: 'Rafael Encanador');
    final budget = await budgetsRepo.create(clientId: client.id);
    await budgetsRepo.softDelete(budget.id);

    final budgets = await budgetsRepo.watchByClient(client.id).first;
    expect(budgets, isEmpty);
  });

  group('controle de pagamentos', () {
    test('totalPaidCents soma os pagamentos e pendingCents nunca fica negativo', () async {
      final client = await clientsRepo.create(name: 'Fernanda Pintora');
      final budget = await budgetsRepo.create(clientId: client.id);
      await budgetsRepo.addItem(
        budget.id,
        const BudgetItemInput(
          description: 'Pintura',
          unit: ServiceUnit.squareMeter,
          quantity: 10,
          unitPriceCents: 1000,
        ),
      ); // total: 10000

      await paymentsRepo.create(budgetId: budget.id, amountCents: 4000, notes: 'Entrada');
      var result = await budgetsRepo.watchById(budget.id).first;
      expect(result!.totalPaidCents, 4000);
      expect(result.pendingCents, 6000);

      // Pagou mais do que o total — pendente não pode virar negativo.
      await paymentsRepo.create(budgetId: budget.id, amountCents: 10000);
      result = await budgetsRepo.watchById(budget.id).first;
      expect(result!.totalPaidCents, 14000);
      expect(result.pendingCents, 0);
    });

    test(
        'watchById emits a new value when a payment is registered on an '
        'already-open subscription (mesma classe de bug corrigida pra itens: '
        'watchSingleOrNull() sozinho não observa a tabela payments)', () async {
      final client = await clientsRepo.create(name: 'Regressão Pagamento');
      final budget = await budgetsRepo.create(clientId: client.id);

      final matcher = expectLater(
        budgetsRepo.watchById(budget.id).map((data) => data?.totalPaidCents),
        emitsInOrder([0, 5000]),
      );

      await Future<void>.delayed(Duration.zero);
      await paymentsRepo.create(budgetId: budget.id, amountCents: 5000);

      await matcher.timeout(const Duration(seconds: 5));
    });

    test('softDelete remove um pagamento de watchByBudget', () async {
      final client = await clientsRepo.create(name: 'Gustavo Gesseiro');
      final budget = await budgetsRepo.create(clientId: client.id);
      final payment = await paymentsRepo.create(budgetId: budget.id, amountCents: 3000);

      await paymentsRepo.softDelete(payment.id);

      final payments = await paymentsRepo.watchByBudget(budget.id).first;
      expect(payments, isEmpty);
    });
  });

  group('resumo da Home', () {
    test('loadHomeSummary soma por status e ignora recusados', () async {
      final client = await clientsRepo.create(name: 'Fernanda Azulejista', phone: '11999998888');

      final sent = await budgetsRepo.create(clientId: client.id);
      await budgetsRepo.addItem(
        sent.id,
        const BudgetItemInput(
          description: 'Assentamento',
          unit: ServiceUnit.squareMeter,
          quantity: 10,
          unitPriceCents: 5000,
        ),
      );
      await budgetsRepo.updateStatus(sent.id, BudgetStatus.sent);

      final accepted = await budgetsRepo.create(clientId: client.id);
      await budgetsRepo.addItem(
        accepted.id,
        const BudgetItemInput(
          description: 'Reboco',
          unit: ServiceUnit.squareMeter,
          quantity: 4,
          unitPriceCents: 2500,
        ),
      );
      await budgetsRepo.updateStatus(accepted.id, BudgetStatus.accepted);
      await paymentsRepo.create(budgetId: accepted.id, amountCents: 5000);

      final declined = await budgetsRepo.create(clientId: client.id);
      await budgetsRepo.addItem(
        declined.id,
        const BudgetItemInput(
          description: 'Não vai contar',
          unit: ServiceUnit.unit,
          quantity: 1,
          unitPriceCents: 999999,
        ),
      );
      await budgetsRepo.updateStatus(declined.id, BudgetStatus.sent);
      await budgetsRepo.updateStatus(declined.id, BudgetStatus.declined);

      final summary = await budgetsRepo.loadHomeSummary();

      expect(summary.totalAwaitingCents, 50000);
      expect(summary.totalAcceptedCents, 10000);
      expect(summary.totalReceivedCents, 5000);
      expect(summary.totalOpenCents, 60000); // aguardando + aprovado, recusado fora
      expect(summary.pending, hasLength(1));
      expect(summary.pending.single.clientName, 'Fernanda Azulejista');
      expect(summary.pending.single.clientPhone, '11999998888');
      expect(summary.pending.single.totalCents, 50000);
    });
  });
}
