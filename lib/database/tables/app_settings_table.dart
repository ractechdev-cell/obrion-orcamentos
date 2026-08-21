import 'package:drift/drift.dart';

/// Preferências simples do app, persistidas localmente (ver CLAUDE.md,
/// módulo Settings do Core). Chave/valor para não exigir migração de
/// schema a cada nova preferência.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
