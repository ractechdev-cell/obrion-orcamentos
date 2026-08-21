import 'package:drift/drift.dart';

import 'entity_mixin.dart';

/// Cliente do profissional (dono da conta) — dado pessoal de terceiro,
/// ver CLAUDE.md, "Segurança e LGPD". Tabela pensada para servir sem
/// alteração de schema aos próximos apps da família (Materiais, Diário...).
class Clients extends Table with EntityMixin {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
