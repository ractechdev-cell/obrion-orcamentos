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

  /// Remove logicamente uma medição de cômodo.
  Future<bool> softDeleteMeasurement(String id) async {
    final count = await (_db.update(_db.measurements)..where((m) => m.id.equals(id)))
        .write(MeasurementsCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }
}
