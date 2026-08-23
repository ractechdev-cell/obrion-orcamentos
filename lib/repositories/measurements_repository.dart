import 'package:drift/drift.dart';

import '../database/database.dart';
import '../database/enums.dart';

/// Modelo completo de medição com seus vãos e grandezas derivadas.
class MeasurementWithDetails {
  const MeasurementWithDetails({
    required this.measurement,
    required this.openings,
  });

  final Measurement measurement;
  final List<MeasurementOpening> openings;
}

/// Repositório de medições e projetos/obras (ver CLAUDE.md,
/// "Medição guarda geometria bruta, não 'a área'").
class MeasurementsRepository {
  MeasurementsRepository(this._db);

  final AppDatabase _db;

  // --- PROJETOS/OBRAS ---

  /// Lista projetos/obras do cliente.
  Stream<List<Project>> watchProjectsByClient(String clientId) {
    return (_db.select(_db.projects)
          ..where((p) => p.clientId.equals(clientId) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  /// Cria um novo projeto/obra.
  Future<Project> createProject({
    required String clientId,
    required String name,
    String? address,
  }) {
    final now = DateTime.now();
    return _db.into(_db.projects).insertReturning(
          ProjectsCompanion.insert(
            clientId: clientId,
            name: name,
            address: Value(address),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  // --- MEDIÇÕES DE CÔMODO ---

  /// Observa todos os cômodos medidos em uma obra com seus vãos.
  Stream<List<MeasurementWithDetails>> watchByProject(String projectId) {
    final query = _db.select(_db.measurements)
      ..where((m) => m.projectId.equals(projectId) & m.deletedAt.isNull())
      ..orderBy([(m) => OrderingTerm.asc(m.name)]);

    return query.watch().asyncMap((measurements) async {
      final result = <MeasurementWithDetails>[];
      for (final m in measurements) {
        final openings = await (_db.select(_db.measurementOpenings)
              ..where((o) => o.measurementId.equals(m.id) & o.deletedAt.isNull()))
            .get();
        result.add(MeasurementWithDetails(measurement: m, openings: openings));
      }
      return result;
    });
  }

  /// Busca uma medição e seus vãos por ID (para carregar o formulário de
  /// edição). Retorna `null` se não existir/estiver deletada.
  Future<MeasurementWithDetails?> getById(String id) async {
    final measurement = await (_db.select(_db.measurements)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
    if (measurement == null) return null;
    final openings = await (_db.select(_db.measurementOpenings)
          ..where((o) => o.measurementId.equals(id) & o.deletedAt.isNull()))
        .get();
    return MeasurementWithDetails(measurement: measurement, openings: openings);
  }

  /// Cria uma medição de cômodo (comprimento, largura, altura) bruta.
  Future<Measurement> createMeasurement({
    required String projectId,
    required String name,
    required double lengthMeters,
    required double widthMeters,
    required double heightMeters,
  }) {
    final now = DateTime.now();
    return _db.into(_db.measurements).insertReturning(
          MeasurementsCompanion.insert(
            projectId: projectId,
            name: name,
            lengthMeters: lengthMeters,
            widthMeters: widthMeters,
            heightMeters: heightMeters,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Atualiza a geometria bruta de um cômodo já medido.
  Future<bool> updateMeasurement({
    required String id,
    Value<String> name = const Value.absent(),
    Value<double> lengthMeters = const Value.absent(),
    Value<double> widthMeters = const Value.absent(),
    Value<double> heightMeters = const Value.absent(),
  }) async {
    final now = DateTime.now();
    final companion = MeasurementsCompanion(
      name: name,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
      heightMeters: heightMeters,
      updatedAt: Value(now),
    );
    final count = await (_db.update(_db.measurements)..where((m) => m.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Adiciona um vão (porta/janela) a um cômodo medido.
  Future<MeasurementOpening> addOpening({
    required String measurementId,
    required OpeningType type,
    required double widthMeters,
    required double heightMeters,
  }) {
    final now = DateTime.now();
    return _db.into(_db.measurementOpenings).insertReturning(
          MeasurementOpeningsCompanion.insert(
            measurementId: measurementId,
            type: type,
            widthMeters: widthMeters,
            heightMeters: heightMeters,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Substitui todos os vãos de um cômodo pela lista informada — mais
  /// simples e igualmente correto que fazer diff (vão não tem histórico
  /// próprio que valha a pena preservar entre edições).
  Future<void> replaceOpenings({
    required String measurementId,
    required List<({OpeningType type, double widthMeters, double heightMeters})> openings,
  }) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.measurementOpenings)
            ..where((o) => o.measurementId.equals(measurementId) & o.deletedAt.isNull()))
          .write(MeasurementOpeningsCompanion(deletedAt: Value(now)));
      for (final opening in openings) {
        await _db.into(_db.measurementOpenings).insert(
              MeasurementOpeningsCompanion.insert(
                measurementId: measurementId,
                type: opening.type,
                widthMeters: opening.widthMeters,
                heightMeters: opening.heightMeters,
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  /// Remove logicamente uma medição de cômodo.
  Future<bool> softDeleteMeasurement(String id) async {
    final count = await (_db.update(_db.measurements)..where((m) => m.id.equals(id)))
        .write(MeasurementsCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }
}
