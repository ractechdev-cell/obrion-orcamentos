import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';

// ignore: unused_import
import 'enums.dart';
import 'tables/app_settings_table.dart';
import 'tables/budgets_table.dart';
import 'tables/clients_table.dart';
import 'tables/measurements_table.dart';
import 'tables/projects_table.dart';
import 'tables/services_table.dart';

part 'database.g.dart';

/// Banco local (Drift/SQLite) — fonte da verdade do app (ver CLAUDE.md,
/// "Local-first: o banco local é a fonte da verdade"). Nenhuma tela deve
/// abrir conexão própria: sempre consumir via repositórios que recebem
/// esta instância (ver `lib/repositories/`).
@DriftDatabase(
  tables: [
    Clients,
    Projects,
    Measurements,
    MeasurementOpenings,
    Services,
    Budgets,
    BudgetItems,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Usado pelos testes para rodar em banco em memória (ver
  /// `test/repositories/`), sem depender de `path_provider`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'obrion_orcamentos');
  }
}
