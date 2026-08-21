import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

/// Instância única do banco local para todo o app (ver CLAUDE.md,
/// "Database — nunca abrir conexão própria"). Repositórios e telas devem
/// ler o banco por aqui, nunca instanciar `AppDatabase` diretamente.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
