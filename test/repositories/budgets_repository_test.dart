import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';

void main() {
  late AppDatabase database;
  late ClientsRepository clientsRepo;
  late BudgetsRepository budgetsRepo;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    clientsRepo = ClientsRepository(database);
    budgetsRepo = BudgetsRepository(database);
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
}
