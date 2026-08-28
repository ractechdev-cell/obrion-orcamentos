import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';

void main() {
  late AppDatabase database;
  late ClientsRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ClientsRepository(database);
  });

  tearDown(() => database.close());

  test('create and watch clients', () async {
    await repository.create(name: 'Carlos Construtor', phone: '11999998888');

    final clients = await repository.watchAll().first;
    expect(clients, hasLength(1));
    expect(clients.first.name, 'Carlos Construtor');
    expect(clients.first.phone, '11999998888');
  });

  test('soft delete excludes client from watchAll', () async {
    final client = await repository.create(name: 'Ana Pintora');
    await repository.softDelete(client.id);

    final clients = await repository.watchAll().first;
    expect(clients, isEmpty);
  });

  test('search filters by name, phone or address', () async {
    await repository.create(name: 'Pedro Pedreiro', phone: '11888887777', address: 'Rua A');
    await repository.create(name: 'Mariana Gesseiro', phone: '11777776666', address: 'Av B');

    final results = await repository.search('pedro');
    expect(results, hasLength(1));
    expect(results.first.name, 'Pedro Pedreiro');

    final resultsByPhone = await repository.search('77777');
    expect(resultsByPhone, hasLength(1));
    expect(resultsByPhone.first.name, 'Mariana Gesseiro');
  });

  test('create and update persist document and structured address fields', () async {
    final client = await repository.create(
      name: 'Roberto Alves',
      document: '123.456.789-00',
      street: 'Rua das Azaléias',
      streetNumber: '142',
      neighborhood: 'Jardim Paulista',
    );

    expect(client.document, '123.456.789-00');
    expect(client.street, 'Rua das Azaléias');
    expect(client.streetNumber, '142');
    expect(client.neighborhood, 'Jardim Paulista');

    await repository.update(id: client.id, streetNumber: const Value('142B'));
    final updated = await repository.getById(client.id);
    expect(updated!.streetNumber, '142B');
    expect(updated.street, 'Rua das Azaléias');
  });

  test('create and update persist email', () async {
    final client = await repository.create(name: 'Ana Pintora', email: 'ana@example.com');
    expect(client.email, 'ana@example.com');

    await repository.update(id: client.id, email: const Value('ana.pintora@example.com'));
    final updated = await repository.getById(client.id);
    expect(updated!.email, 'ana.pintora@example.com');
  });

  group('watchAllWithBudgetCount', () {
    test('conta orçamentos por cliente e devolve zero pra quem não tem',
        () async {
      final budgetsRepo = BudgetsRepository(database);
      final comOrcamento = await repository.create(name: 'Ana Pintora');
      final semOrcamento = await repository.create(name: 'Bruno Pedreiro');

      await budgetsRepo.create(clientId: comOrcamento.id);
      await budgetsRepo.create(clientId: comOrcamento.id);

      final rows = await repository.watchAllWithBudgetCount().first;

      // Ordenado por nome: Ana antes de Bruno.
      expect(rows.map((r) => r.client.id), [comOrcamento.id, semOrcamento.id]);
      expect(rows.first.budgetCount, 2);
      // O join é externo — sem o filtro no COUNT, cliente sem orçamento
      // viria com 1 (a linha nula do join) em vez de 0.
      expect(rows.last.budgetCount, 0);
    });

    test('não conta orçamento excluído', () async {
      final budgetsRepo = BudgetsRepository(database);
      final client = await repository.create(name: 'Carla Gesseira');
      final budget = await budgetsRepo.create(clientId: client.id);
      await budgetsRepo.create(clientId: client.id);

      await budgetsRepo.softDelete(budget.id);

      final rows = await repository.watchAllWithBudgetCount().first;
      expect(rows.single.budgetCount, 1);
    });
  });
}
