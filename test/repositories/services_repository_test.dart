import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/repositories/services_repository.dart';

void main() {
  late AppDatabase database;
  late ServicesRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ServicesRepository(database);
  });

  tearDown(() => database.close());

  test('create and watch services', () async {
    await repository.create(
      name: 'Pintura',
      unit: ServiceUnit.squareMeter,
      defaultPriceCents: 2500, // R$ 25,00
      includesMaterial: true,
      defaultNote: 'Pintura padrão premium',
    );

    final services = await repository.watchAll().first;
    expect(services, hasLength(1));
    expect(services.first.name, 'Pintura');
    expect(services.first.unit, ServiceUnit.squareMeter);
    expect(services.first.defaultPriceCents, 2500);
    expect(services.first.includesMaterial, true);
    expect(services.first.defaultNote, 'Pintura padrão premium');
  });

  test('soft delete excludes service from watchAll', () async {
    final service = await repository.create(name: 'Reboco', unit: ServiceUnit.squareMeter);
    await repository.softDelete(service.id);

    final services = await repository.watchAll().first;
    expect(services, isEmpty);
  });

  test('search filters by name', () async {
    await repository.create(name: 'Instalação Elétrica', unit: ServiceUnit.point);
    await repository.create(name: 'Lustração', unit: ServiceUnit.linearMeter);

    final results = await repository.search('Elétrica');
    expect(results, hasLength(1));
    expect(results.first.name, 'Instalação Elétrica');
  });

  test('populateDefaultServices inserts seed list with null price', () async {
    await repository.populateDefaultServices();

    final services = await repository.watchAll().first;
    expect(services.length, greaterThan(15));
    expect(services.firstWhere((s) => s.name == 'Reboco de parede').unit, ServiceUnit.squareMeter);
    expect(services.every((s) => s.defaultPriceCents == null), isTrue);
  });
}
