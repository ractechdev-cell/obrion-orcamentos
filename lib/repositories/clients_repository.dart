import 'package:drift/drift.dart';

import '../database/database.dart';

/// Repositório de clientes — camada de acesso a dados (ver CLAUDE.md,
/// "Database — nunca abrir conexão própria"). Telas nunca falam com o
/// banco direto; consomem este repositório injetado via Riverpod.
class ClientsRepository {
  ClientsRepository(this._db);

  final AppDatabase _db;

  /// Stream reativa de todos os clientes ativos (não deletados),
  /// ordenados por nome — usado na lista da UI.
  Stream<List<Client>> watchAll() {
    return (_db.select(_db.clients)
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Contagem de clientes ativos — usada no resumo da Home. Consulta
  /// única (não reativa): o resumo não precisa atualizar em tempo real
  /// enquanto a tela está aberta, então não vale manter mais um stream
  /// do banco vivo pelo tempo todo só pra isso.
  Future<int> countActive() async {
    final rows = await (_db.select(_db.clients)..where((c) => c.deletedAt.isNull())).get();
    return rows.length;
  }

  /// Clientes + quantos orçamentos cada um tem — a lista mostra esse
  /// número como selo, o que ajuda a distinguir de relance o cliente que
  /// já rendeu trabalho daquele que só foi cadastrado.
  ///
  /// Reage tanto a mudança de cliente quanto de orçamento: um orçamento
  /// novo precisa atualizar o selo sem sair e voltar da tela.
  Stream<List<ClientWithBudgetCount>> watchAllWithBudgetCount() {
    // `count` com filtro em vez de `COUNT(*)`: o join é externo, então
    // cliente sem orçamento traz uma linha de orçamento toda nula, que
    // `COUNT(*)` contaria como 1.
    final budgetCount = _db.budgets.id.count(
      filter: _db.budgets.deletedAt.isNull(),
    );

    final query = _db.select(_db.clients).join([
      leftOuterJoin(
        _db.budgets,
        _db.budgets.clientId.equalsExp(_db.clients.id),
      ),
    ])
      ..addColumns([budgetCount])
      ..where(_db.clients.deletedAt.isNull())
      ..groupBy([_db.clients.id])
      ..orderBy([OrderingTerm.asc(_db.clients.name)]);

    return query
        .map(
          (row) => ClientWithBudgetCount(
            client: row.readTable(_db.clients),
            budgetCount: row.read(budgetCount) ?? 0,
          ),
        )
        .watch();
  }

  /// Busca um cliente por ID (pode retornar nulo se deletado/inexistente).
  Future<Client?> getById(String id) {
    return (_db.select(_db.clients)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Cria um novo cliente. Retorna o registro inserido (inclui id gerado).
  Future<Client> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? document,
    String? street,
    String? streetNumber,
    String? neighborhood,
  }) {
    final now = DateTime.now();
    return _db.into(_db.clients).insertReturning(
          ClientsCompanion.insert(
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
            notes: Value(notes),
            document: Value(document),
            street: Value(street),
            streetNumber: Value(streetNumber),
            neighborhood: Value(neighborhood),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Atualiza campos do cliente. Retorna `true` se encontrou e atualizou.
  ///
  /// Cada campo usa `Value<T>` (não `T?` cru) para distinguir "não mexer
  /// neste campo" (`Value.absent()`, o padrão) de "limpar o campo"
  /// (`Value(null)`) — com `T?` cru essas duas intenções colapsam em
  /// `null` e o campo nunca é realmente apagado.
  Future<bool> update({
    required String id,
    Value<String> name = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> document = const Value.absent(),
    Value<String?> street = const Value.absent(),
    Value<String?> streetNumber = const Value.absent(),
    Value<String?> neighborhood = const Value.absent(),
  }) async {
    final now = DateTime.now();
    final companion = ClientsCompanion(
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      document: document,
      street: street,
      streetNumber: streetNumber,
      neighborhood: neighborhood,
      updatedAt: Value(now),
    );
    final count = await (_db.update(_db.clients)..where((c) => c.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Exclusão lógica (soft delete) — define `deletedAt`. Não remove do
  /// banco para permitir sincronização futura propagando a remoção.
  Future<bool> softDelete(String id) async {
    final count = await (_db.update(_db.clients)..where((c) => c.id.equals(id)))
        .write(ClientsCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }

  /// Busca clientes por termo (nome/telefone/endereço) — filtro local
  /// para a lista da UI.
  Future<List<Client>> search(String query) {
    final term = '%$query%';
    return (_db.select(_db.clients)
          ..where((c) => c.deletedAt.isNull() &
              (c.name.like(term) |
                  c.phone.like(term) |
                  c.address.like(term)))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }
}

/// Cliente com a contagem de orçamentos dele — ver
/// [ClientsRepository.watchAllWithBudgetCount].
class ClientWithBudgetCount {
  const ClientWithBudgetCount({
    required this.client,
    required this.budgetCount,
  });

  final Client client;
  final int budgetCount;
}
