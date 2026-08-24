import 'package:drift/drift.dart' show Value;
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

  test('populateDefaultServices filters by trade when informed', () async {
    await repository.populateDefaultServices(trades: {Trade.painter});

    final services = await repository.watchAll().first;
    expect(services.any((s) => s.name == 'Pintura acrílica (2 demãos)'), isTrue);
    expect(services.any((s) => s.name == 'Instalação de ponto elétrico'), isFalse);
    expect(services.length, lessThan(10));
  });

  test('populateDefaultServices with empty trades keeps old behavior (insere tudo)', () async {
    await repository.populateDefaultServices(trades: const {});

    final services = await repository.watchAll().first;
    expect(services.any((s) => s.name == 'Pintura acrílica (2 demãos)'), isTrue);
    expect(services.any((s) => s.name == 'Instalação de ponto elétrico'), isTrue);
  });

  test('bulkAdjustPrices reajusta só serviços com preço definido', () async {
    await repository.create(name: 'Com preço', unit: ServiceUnit.squareMeter, defaultPriceCents: 10000);
    await repository.create(name: 'Sem preço', unit: ServiceUnit.squareMeter);

    await repository.bulkAdjustPrices(10);

    final services = await repository.watchAll().first;
    expect(services.firstWhere((s) => s.name == 'Com preço').defaultPriceCents, 11000);
    expect(services.firstWhere((s) => s.name == 'Sem preço').defaultPriceCents, isNull);
  });

  test('bulkAdjustPrices aceita percentual negativo', () async {
    await repository.create(name: 'Serviço', unit: ServiceUnit.squareMeter, defaultPriceCents: 10000);

    await repository.bulkAdjustPrices(-10);

    final services = await repository.watchAll().first;
    expect(services.single.defaultPriceCents, 9000);
  });

  test('create and update persist category', () async {
    final created = await repository.create(
      name: 'Reboco',
      unit: ServiceUnit.squareMeter,
      category: 'Alvenaria',
    );
    expect(created.category, 'Alvenaria');

    await repository.update(id: created.id, category: const Value('Acabamento'));
    final updated = await repository.getById(created.id);
    expect(updated!.category, 'Acabamento');

    await repository.update(id: created.id, category: const Value(null));
    final cleared = await repository.getById(created.id);
    expect(cleared!.category, isNull);
  });
}
