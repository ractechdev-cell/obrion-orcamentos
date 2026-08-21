import 'package:drift/drift.dart';

import 'clients_table.dart';
import 'entity_mixin.dart';

/// Obra/projeto — agrupa medições e orçamentos por cliente. Tabela pensada
/// para servir sem alteração de schema aos próximos apps da família
/// (ver CLAUDE.md, "Banco de dados (schema inicial)").
class Projects extends Table with EntityMixin {
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get address => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
