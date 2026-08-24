import 'package:drift/drift.dart';

import 'entity_mixin.dart';

/// Cliente do profissional (dono da conta) — dado pessoal de terceiro,
/// ver CLAUDE.md, "Segurança e LGPD". Tabela pensada para servir sem
/// alteração de schema aos próximos apps da família (Materiais, Diário...).
class Clients extends Table with EntityMixin {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  /// CPF/CNPJ — opcional, usado em recibo/contrato informal. Campos de
  /// endereço estruturado (complementam `address`, que continua livre
  /// pra quem não precisa detalhar) — ver feedback de teste manual: pedido
  /// pra ficar mais parecido com o formulário do concorrente (Documento,
  /// Rua, Número, Bairro).
  TextColumn get document => text().nullable()();
  TextColumn get street => text().nullable()();
  TextColumn get streetNumber => text().nullable()();
  TextColumn get neighborhood => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
