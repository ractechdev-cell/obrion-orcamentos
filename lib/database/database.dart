import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';

// ignore: unused_import
import 'enums.dart';
import 'tables/app_settings_table.dart';
import 'tables/budget_templates_table.dart';
import 'tables/budgets_table.dart';
import 'tables/clients_table.dart';
import 'tables/measurements_table.dart';
import 'tables/payments_table.dart';
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
    Payments,
    BudgetTemplates,
    BudgetTemplateItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Usado pelos testes para rodar em banco em memória (ver
  /// `test/repositories/`), sem depender de `path_provider`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  /// v1 → v2: adiciona `payments` (controle de pagamentos, ver CLAUDE.md,
  /// monetização). v2 → v3: adiciona `budgets.jobDescription` (descrição
  /// da obra no PDF, ver `budgets_table.dart`). v3 → v4: adiciona
  /// `clients.document`/`street`/`streetNumber`/`neighborhood` (formulário
  /// de cliente mais estruturado, ver `clients_table.dart`). v4 → v5:
  /// adiciona `clients.email`. v5 → v6: adiciona `services.category`
  /// (filtro por categoria na Lista de Preços). v6 → v7: adiciona
  /// `budget_templates`/`budget_template_items` (modelos de orçamento,
  /// ver `budget_templates_table.dart`). Instalações já existentes
  /// precisam dessas migrações pra não perder dado nenhum; um `onCreate`
  /// sozinho só resolveria instalações novas do zero.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(payments);
          }
          if (from < 3) {
            await m.addColumn(budgets, budgets.jobDescription);
          }
          if (from < 4) {
            await m.addColumn(clients, clients.document);
            await m.addColumn(clients, clients.street);
            await m.addColumn(clients, clients.streetNumber);
            await m.addColumn(clients, clients.neighborhood);
          }
          if (from < 5) {
            await m.addColumn(clients, clients.email);
          }
          if (from < 6) {
            await m.addColumn(services, services.category);
          }
          if (from < 7) {
            await m.createTable(budgetTemplates);
            await m.createTable(budgetTemplateItems);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'obrion_orcamentos');
  }
}
