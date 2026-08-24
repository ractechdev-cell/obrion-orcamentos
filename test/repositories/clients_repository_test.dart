import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
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
}
