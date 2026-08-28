import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/repositories/budget_templates_repository.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';

void main() {
  late AppDatabase database;
  late ClientsRepository clientsRepo;
  late BudgetsRepository budgetsRepo;
  late BudgetTemplatesRepository templatesRepo;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    clientsRepo = ClientsRepository(database);
    budgetsRepo = BudgetsRepository(database);
    templatesRepo = BudgetTemplatesRepository(database);
  });

  tearDown(() => database.close());

  test('createFromBudget copia itens, desconto e condições do orçamento', () async {
    final client = await clientsRepo.create(name: 'Marcos Pintor');
    final budget = await budgetsRepo.create(clientId: client.id);

    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Pintura de parede',
        unit: ServiceUnit.squareMeter,
        quantity: 20,
        unitPriceCents: 2500,
      ),
    );
    await budgetsRepo.updateDiscount(budget.id, 5000);
    await budgetsRepo.updateDetails(
      budget.id,
      notes: 'Pagamento em 2x',
      jobDescription: 'Pintura da sala',
    );

    final template = await templatesRepo.createFromBudget(
      budgetId: budget.id,
      name: 'Pintura residencial',
    );

    expect(template.name, 'Pintura residencial');
    expect(template.discountCents, 5000);
    expect(template.notes, 'Pagamento em 2x');
    expect(template.jobDescription, 'Pintura da sala');

    final data = await templatesRepo.getWithItems(template.id);
    expect(data!.items, hasLength(1));
    expect(data.items.first.description, 'Pintura de parede');
    expect(data.items.first.quantity, 20);
    expect(data.items.first.unitPriceCents, 2500);
  });

  test('applyToBudget copia itens/condições do modelo pro orçamento novo', () async {
    final client = await clientsRepo.create(name: 'Ana Eletricista');
    final source = await budgetsRepo.create(clientId: client.id);
    await budgetsRepo.addItem(
      source.id,
      const BudgetItemInput(
        description: 'Ponto elétrico',
        unit: ServiceUnit.point,
        quantity: 5,
        unitPriceCents: 8000,
      ),
    );
    await budgetsRepo.updateDiscount(source.id, 1000);

    final template = await templatesRepo.createFromBudget(
      budgetId: source.id,
      name: 'Instalação elétrica',
    );

    // Orçamento novo, vazio — mesmo cenário do wizard na Etapa 1.
    final target = await budgetsRepo.create(clientId: client.id);
    await templatesRepo.applyToBudget(templateId: template.id, budgetId: target.id);

    final result = await budgetsRepo.watchById(target.id).first;
    expect(result!.items, hasLength(1));
    expect(result.items.first.description, 'Ponto elétrico');
    expect(result.items.first.unitPriceCents, 8000);
    expect(result.totals.discountCents, 1000);
  });

  test('watchAll exclui modelos excluídos logicamente', () async {
    final client = await clientsRepo.create(name: 'João Gesseiro');
    final budget = await budgetsRepo.create(clientId: client.id);
    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Reboco',
        unit: ServiceUnit.squareMeter,
        quantity: 10,
        unitPriceCents: 1500,
      ),
    );

    final template = await templatesRepo.createFromBudget(
      budgetId: budget.id,
      name: 'Reboco padrão',
    );

    var all = await templatesRepo.watchAll().first;
    expect(all, hasLength(1));

    await templatesRepo.softDelete(template.id);

    all = await templatesRepo.watchAll().first;
    expect(all, isEmpty);
  });
}
