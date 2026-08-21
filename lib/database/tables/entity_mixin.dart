import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Colunas presentes em todo registro local-first (ver CLAUDE.md,
/// "Local-first: o banco local é a fonte da verdade"): `id` gerado no
/// cliente (para sincronizar sem depender do servidor gerar a chave),
/// `updatedAt` (base do "último a escrever vence" na sincronização
/// futura) e `deletedAt` (exclusão lógica, para propagar remoção).
///
/// Toda tabela de negócio deve usar este mixin — não recriar estas três
/// colunas manualmente em cada tabela.
mixin EntityMixin on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
