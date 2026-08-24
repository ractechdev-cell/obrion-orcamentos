import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/measurements_repository.dart';

void main() {
  late AppDatabase database;
  late ClientsRepository clientsRepo;
  late MeasurementsRepository measurementsRepo;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    clientsRepo = ClientsRepository(database);
    measurementsRepo = MeasurementsRepository(database);
  });

  tearDown(() => database.close());

  test('creates room measurement with openings and watches details', () async {
    final client = await clientsRepo.create(name: 'José Empreiteiro');
    final project = await measurementsRepo.createProject(
      clientId: client.id,
      name: 'Reforma Cozinha',
    );

    final measurement = await measurementsRepo.createMeasurement(
      projectId: project.id,
      name: 'Cozinha Principal',
      lengthMeters: 4.0,
      widthMeters: 3.0,
      heightMeters: 2.8,
    );

    await measurementsRepo.addOpening(
      measurementId: measurement.id,
      type: OpeningType.door,
      widthMeters: 0.8,
      heightMeters: 2.1,
    );

    final details = await measurementsRepo.watchByProject(project.id).first;

    expect(details, hasLength(1));
    expect(details.first.measurement.name, 'Cozinha Principal');
    expect(details.first.openings, hasLength(1));
    expect(details.first.openings.first.type, OpeningType.door);
  });

  test('softDeleteMeasurement excludes measurement from watchByProject', () async {
    final client = await clientsRepo.create(name: 'José Empreiteiro');
    final project = await measurementsRepo.createProject(clientId: client.id, name: 'Reforma');
    final measurement = await measurementsRepo.createMeasurement(
      projectId: project.id,
      name: 'Sala',
      lengthMeters: 5.0,
      widthMeters: 4.0,
      heightMeters: 2.7,
    );

    final deleted = await measurementsRepo.softDeleteMeasurement(measurement.id);

    expect(deleted, isTrue);
    final details = await measurementsRepo.watchByProject(project.id).first;
    expect(details, isEmpty);
  });
}
