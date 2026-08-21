import 'package:drift/drift.dart';

import '../enums.dart';
import 'entity_mixin.dart';

/// Lista de preços pessoal do profissional — funcionalidade central do
/// MVP, não detalhe (ver CLAUDE.md, "Lista de preços pessoal é
/// funcionalidade central do MVP"). `defaultPriceCents` fica em branco
/// (nullable) até o profissional preencher: nunca sugerir valor de preço.
class Services extends Table with EntityMixin {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get unit => textEnum<ServiceUnit>()();
  IntColumn get defaultPriceCents => integer().nullable()();
  BoolColumn get includesMaterial =>
      boolean().withDefault(const Constant(false))();
  TextColumn get defaultNote => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
