import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/example_data_seeder.dart';

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

  test('seed creates one example client and one example budget with items, both marked [exemplo]', () async {
    await ExampleDataSeeder.seed(clientsRepo: clientsRepo, budgetsRepo: budgetsRepo);

    final clients = await clientsRepo.watchAll().first;
    expect(clients, hasLength(1));
    expect(clients.single.name, contains('[exemplo]'));

    final budgets = await budgetsRepo.watchByClient(clients.single.id).first;
    expect(budgets, hasLength(1));

    final data = await budgetsRepo.watchById(budgets.single.id).first;
    expect(data!.items, isNotEmpty);
    expect(data.items.every((i) => i.description.contains('[exemplo]')), isTrue);
  });

  test('seeded client and budget are soft-deletable like any real record', () async {
    await ExampleDataSeeder.seed(clientsRepo: clientsRepo, budgetsRepo: budgetsRepo);
    final client = (await clientsRepo.watchAll().first).single;

    await clientsRepo.softDelete(client.id);

    final clients = await clientsRepo.watchAll().first;
    expect(clients, isEmpty);
  });
}
