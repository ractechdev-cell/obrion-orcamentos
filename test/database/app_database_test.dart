import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('inserts and reads a client', () async {
    final client = await database.into(database.clients).insertReturning(
          ClientsCompanion.insert(name: 'João Pedreiro'),
        );

    expect(client.name, 'João Pedreiro');
    expect(client.deletedAt, isNull);
  });

  test('stores money in cents, never as double', () async {
    final client = await database.into(database.clients).insertReturning(
          ClientsCompanion.insert(name: 'Maria Pintora'),
        );
    final budget = await database.into(database.budgets).insertReturning(
          BudgetsCompanion.insert(clientId: client.id),
        );

    await database.into(database.budgetItems).insert(
          BudgetItemsCompanion.insert(
            budgetId: budget.id,
            description: 'Reboco de parede',
            unit: ServiceUnit.squareMeter,
            quantity: 12.5,
            unitPriceCents: 2500,
            totalCents: 31250,
          ),
        );

    final item = await database.select(database.budgetItems).getSingle();

    expect(item.unitPriceCents, isA<int>());
    expect(item.totalCents, 31250);
  });

  test('budget defaults to draft status', () async {
    final client = await database.into(database.clients).insertReturning(
          ClientsCompanion.insert(name: 'Cliente Teste'),
        );
    final budget = await database.into(database.budgets).insertReturning(
          BudgetsCompanion.insert(clientId: client.id),
        );

    expect(budget.status, BudgetStatus.draft);
  });

  test('measurement stores raw geometry, not a single area field', () async {
    final client = await database.into(database.clients).insertReturning(
          ClientsCompanion.insert(name: 'Cliente Obra'),
        );
    final project = await database.into(database.projects).insertReturning(
          ProjectsCompanion.insert(clientId: client.id, name: 'Reforma sala'),
        );

    final measurement =
        await database.into(database.measurements).insertReturning(
              MeasurementsCompanion.insert(
                projectId: project.id,
                name: 'Sala',
                lengthMeters: 4.0,
                widthMeters: 3.0,
                heightMeters: 2.7,
              ),
            );

    expect(measurement.lengthMeters, 4.0);
    expect(measurement.widthMeters, 3.0);
    expect(measurement.heightMeters, 2.7);

    await database.into(database.measurementOpenings).insert(
          MeasurementOpeningsCompanion.insert(
            measurementId: measurement.id,
            type: OpeningType.door,
            widthMeters: 0.8,
            heightMeters: 2.1,
          ),
        );

    final openings = await database.select(database.measurementOpenings).get();
    expect(openings, hasLength(1));
    expect(openings.single.type, OpeningType.door);
  });
}
